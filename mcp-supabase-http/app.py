import os, re, json, asyncio, uuid, time, datetime
from typing import AsyncGenerator, Dict, Any, List
from fastapi import FastAPI, Header, HTTPException, Request, Response
from sse_starlette.sse import EventSourceResponse
from dotenv import load_dotenv
import psycopg
from psycopg.rows import dict_row

load_dotenv()

API_KEY = os.getenv("MCP_API_KEY", "")
DATABASE_URL = os.getenv("DATABASE_URL", "")
PROJECT_REF = os.getenv("SUPABASE_PROJECT_REF", "")

ALLOW_WRITE = os.getenv("ALLOW_WRITE", "false").lower() == "true"
BLOCK_DDL = os.getenv("BLOCK_DDL", "false").lower() == "true"
SQL_DENYLIST = [s.strip() for s in os.getenv("SQL_DENYLIST", "").split(",") if s.strip()]

if not API_KEY or not DATABASE_URL or not PROJECT_REF:
    raise RuntimeError("MCP_API_KEY, DATABASE_URL, SUPABASE_PROJECT_REF måste vara satta i .env")

DDL_REGEX = re.compile(r"\b(create|alter|drop|truncate|grant|revoke)\b", re.I)

app = FastAPI(title="Supabase MCP (HTTP, FULL SQL)")

SESSIONS: Dict[str, Dict[str, Any]] = {}

async def init_audit():
    async with await psycopg.AsyncConnection.connect(DATABASE_URL) as conn:
        async with conn.cursor() as cur:
            await cur.execute("""
            create table if not exists public.mcp_audit_log (
                id bigserial primary key,
                ts timestamptz not null default now(),
                session_id text,
                caller_ip text,
                statement text,
                ok boolean,
                error text
            );
            """)
            await conn.commit()

@app.on_event("startup")
async def startup():
    await init_audit()

def auth_or_403(auth_header: str | None):
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = auth_header.split(" ", 1)[1].strip()
    if token != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid token")

def check_policies(sql: str):
    # Dödmansgrepp: om ALLOW_WRITE är false → blockera allt som inte är SELECT
    if not ALLOW_WRITE:
        # Tillåt SELECT, SHOW, EXPLAIN, WITH (SELECT ...)
        if not re.match(r"^\s*(select|show|explain|with)\b", sql, re.I):
            raise HTTPException(status_code=403, detail="Write blocked (ALLOW_WRITE=false)")
    if BLOCK_DDL and DDL_REGEX.search(sql):
        raise HTTPException(status_code=403, detail="DDL blocked (BLOCK_DDL=true)")
    for pat in SQL_DENYLIST:
        if re.search(pat, sql, flags=re.I):
            raise HTTPException(status_code=403, detail=f"Statement denied by SQL_DENYLIST: {pat}")

async def db_exec(sql: str, params: List[Any] | None = None, fetch: bool = True):
    async with await psycopg.AsyncConnection.connect(DATABASE_URL) as conn:
        async with conn.cursor(row_factory=dict_row) as cur:
            await cur.execute(sql, params or [])
            rows = []
            if fetch:
                try:
                    rows = await cur.fetchall()
                except psycopg.ProgrammingError:
                    rows = []
            else:
                await conn.commit()
            return rows

async def audit_log(session_id: str | None, caller_ip: str | None, statement: str, ok: bool, error: str | None):
    try:
        async with await psycopg.AsyncConnection.connect(DATABASE_URL) as conn:
            async with conn.cursor() as cur:
                await cur.execute(
                    "insert into public.mcp_audit_log (session_id, caller_ip, statement, ok, error) values (%s,%s,%s,%s,%s)",
                    (session_id, caller_ip, statement, ok, error)
                )
                await conn.commit()
    except Exception:
        # sista utvägen: svälj audit-fel (ska inte stoppa huvudflödet)
        pass

def mcp_ok(id: str, result: Any) -> Dict[str, Any]:
    return {"id": id, "type": "result", "result": result}

def mcp_error(id: str, message: str, code: int = 400) -> Dict[str, Any]:
    return {"id": id, "type": "error", "error": {"message": message, "code": code}}

TOOLS = {
    "execute_sql": {
        "name": "execute_sql",
        "description": "Execute arbitrary SQL (FULL POWER). Returns rows for queries; commits otherwise.",
        "input_schema": {"type":"object","properties":{"sql":{"type":"string"}},"required":["sql"]}
    }
}

@app.get("/mcp")
async def mcp_sse(request: Request, authorization: str | None = Header(default=None)):
    auth_or_403(authorization)
    session_id = request.headers.get("mcp-session-id") or str(uuid.uuid4())
    SESSIONS.setdefault(session_id, {"created": time.time()})
    async def event_gen():
        while True:
            if await request.is_disconnected():
                break
            await asyncio.sleep(10)
    headers = {"mcp-session-id": session_id}
    return EventSourceResponse(event_gen(), headers=headers)

@app.delete("/mcp")
async def mcp_close(request: Request, authorization: str | None = Header(default=None)):
    auth_or_403(authorization)
    session_id = request.headers.get("mcp-session-id")
    if session_id:
        SESSIONS.pop(session_id, None)
    return Response(status_code=204)

@app.post("/mcp")
async def mcp_post(request: Request, authorization: str | None = Header(default=None), x_forwarded_for: str | None = Header(default=None)):
    auth_or_403(authorization)
    body = await request.json()
    responses: List[dict] = []
    caller_ip = (x_forwarded_for or request.client.host if request.client else None)
    session_id = request.headers.get("mcp-session-id")

    for msg in body.get("messages", []):
        if msg.get("type") != "request":
            continue
        rid = msg.get("id") or str(uuid.uuid4())
        method = msg.get("method")
        try:
            if method == "tools/list":
                result = {"tools": [
                    {"name": TOOLS["execute_sql"]["name"], "description": TOOLS["execute_sql"]["description"], "inputSchema": TOOLS["execute_sql"]["input_schema"]},
                ]}
                responses.append(mcp_ok(rid, result))
            elif method == "tools/call":
                params = msg.get("params", {})
                name = params.get("name")
                arguments = params.get("arguments", {})
                if name == "execute_sql":
                    sql = arguments.get("sql", "")
                    check_policies(sql)
                    # Heuristik: fetch = True för SELECT/SHOW/EXPLAIN/WITH, annars commit
                    fetch = bool(re.match(r"^\s*(select|show|explain|with)\b", sql, re.I))
                    try:
                        rows = await db_exec(sql, fetch=fetch)
                        await audit_log(session_id, caller_ip, sql, True, None)
                        if fetch:
                            responses.append(mcp_ok(rid, {"content":[{"type":"text","text": json.dumps(rows)}]}))
                        else:
                            responses.append(mcp_ok(rid, {"content":[{"type":"text","text":"OK"}]}))
                    except Exception as e:
                        await audit_log(session_id, caller_ip, sql, False, str(e))
                        raise
                else:
                    responses.append(mcp_error(rid, f"Unknown tool: {name}", 404))
            else:
                responses.append(mcp_error(rid, f"Unknown method: {method}", 404))
        except HTTPException as he:
            responses.append(mcp_error(rid, he.detail, he.status_code))
        except Exception as e:
            responses.append(mcp_error(rid, str(e), 500))
    return {"messages": responses}

@app.get("/")
def health():
    return {"ok": True, "project_ref": PROJECT_REF, "mode": "FULL_SQL", "allow_write": ALLOW_WRITE, "block_ddl": BLOCK_DDL}
