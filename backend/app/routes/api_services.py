from fastapi import APIRouter, HTTPException, Query

from .. import repositories, schemas

router = APIRouter(prefix="/services", tags=["services"])

ALLOWED_STATUSES = {"draft", "active", "paused", "archived"}


@router.get("", response_model=schemas.ServiceListResponse)
async def list_services(status: str | None = Query(None, description="Filter on service status, e.g. active")):
    normalized_status: str | None = None
    if status:
        status_lower = status.lower()
        if status_lower not in ALLOWED_STATUSES:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid status '{status}'. Allowed values: {', '.join(sorted(ALLOWED_STATUSES))}",
            )
        normalized_status = status_lower

    items = [
        schemas.ServiceItem(
            id=row["id"],
            title=row["title"],
            description=row.get("description"),
            price_cents=row.get("price_cents") or 0,
            currency=row.get("currency") or "sek",
            status=row.get("status") or "draft",
            duration_minutes=row.get("duration_minutes"),
            requires_certification=bool(row.get("requires_certification")),
            certified_area=row.get("certified_area"),
            created_at=row["created_at"],
            updated_at=row["updated_at"],
        )
        for row in await _collect_services(normalized_status)
    ]
    return schemas.ServiceListResponse(items=items)


async def _collect_services(status: str | None):
    rows = []
    async for row in repositories.list_services(status=status):
        rows.append(row)
    return rows
