// supabase/functions/signed-upload/index.ts
// Deno deploy: Service role används automatiskt (env var SUPABASE_SERVICE_ROLE_KEY)
// Skapar en signed upload-url för en given bucket + path.
// Clienten laddar sedan upp med uploadToSignedUrl (ingen RLS krävs för INSERT).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(SUPABASE_URL, SERVICE_ROLE, { auth: { persistSession: false } });

interface Body {
    bucket: string;           // t.ex. "course-media" eller "media"
    objectPath: string;       // t.ex. "<courseId>/cover_1699999999.jpg"
    expiresIn?: number;       // sekunder (default 120)
}

Deno.serve(async (req) => {
    try {
        if (req.method !== "POST") {
            return new Response("Method Not Allowed", { status: 405 });
        }
        const body = (await req.json()) as Body;
        if (!body?.bucket || !body?.objectPath) {
            return new Response("Missing bucket or objectPath", { status: 400 });
        }
        const expiresIn = body.expiresIn ?? 120;

        // Skapa signed upload-url
        const { data, error } = await supabase
            .storage
            .from(body.bucket)
            .createSignedUploadUrl(body.objectPath, { upsert: true });
        if (error) {
            return new Response(JSON.stringify({ error: error.message }), { status: 400 });
        }
        // data = { signedUrl, token, path }
        return new Response(JSON.stringify({ ok: true, ...data, bucket: body.bucket }), {
            headers: { "Content-Type": "application/json" },
        });
    } catch (e) {
        return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
    }
});
