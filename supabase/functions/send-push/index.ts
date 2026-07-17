// Supabase Edge Function: send FCM push for a notifications row insert.
// Secrets (set via `supabase secrets set`):
//   FIREBASE_SERVICE_ACCOUNT_JSON  — full service account JSON string
//   FIREBASE_PROJECT_ID            — e.g. entangl-c11b2
//
// Invoke: Database Webhook on public.notifications INSERT → this function URL
// Or: POST { record: { id, user_id, actor_id, type, post_id, comment_id } }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

interface NotificationRecord {
  id: string;
  user_id: string;
  actor_id: string;
  type: string;
  post_id?: string | null;
  comment_id?: string | null;
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id?: string;
}

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return json({ error: "Method not allowed" }, 405);
    }

    // Optional shared secret (Database Webhook / callers should send header).
    const expectedSecret = Deno.env.get("PUSH_WEBHOOK_SECRET");
    if (expectedSecret) {
      const provided =
        req.headers.get("x-webhook-secret") ??
        req.headers.get("X-Webhook-Secret") ??
        "";
      if (provided !== expectedSecret) {
        return json({ error: "Unauthorized" }, 401);
      }
    }

    const body = await req.json();
    // Database Webhooks wrap the row as `record`; allow raw too.
    const record = (body.record ?? body) as NotificationRecord;
    if (!record?.user_id || !record?.type || !record?.actor_id) {
      return json({ error: "Missing notification fields" }, 400);
    }

    const projectId =
      Deno.env.get("FIREBASE_PROJECT_ID") ?? "entangl-c11b2";
    const saRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
    if (!saRaw) {
      return json({ error: "FIREBASE_SERVICE_ACCOUNT_JSON not set" }, 500);
    }

    const serviceAccount = JSON.parse(saRaw) as ServiceAccount;
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Actor display for title/body
    const { data: actor } = await supabase
      .from("profiles")
      .select("username, full_name")
      .eq("id", record.actor_id)
      .maybeSingle();

    const actorName =
      actor?.full_name ||
      (actor?.username ? `@${actor.username}` : "Someone");

    const { title, body: notifBody } = buildCopy(
      record.type,
      actorName,
    );

    const { data: tokens, error: tokenErr } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", record.user_id);

    if (tokenErr) {
      return json({ error: tokenErr.message }, 500);
    }
    if (!tokens?.length) {
      return json({ sent: 0, reason: "no_tokens" });
    }

    const accessToken = await getGoogleAccessToken(serviceAccount);
    const dataPayload: Record<string, string> = {
      type: record.type,
      notification_id: record.id ?? "",
      actor_id: record.actor_id,
      post_id: record.post_id ?? "",
      comment_id: record.comment_id ?? "",
      user_id: record.user_id,
      title,
      body: notifBody,
    };

    let sent = 0;
    const stale: string[] = [];

    for (const row of tokens) {
      const token = row.token as string;
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title, body: notifBody },
              data: dataPayload,
              android: {
                priority: "HIGH",
                notification: {
                  channel_id: "entangl_push",
                },
              },
              apns: {
                payload: {
                  aps: {
                    sound: "default",
                    badge: 1,
                  },
                },
              },
            },
          }),
        },
      );

      if (res.ok) {
        sent++;
        continue;
      }

      const errBody = await res.text();
      // Prune unregistered / invalid tokens
      if (
        res.status === 404 ||
        errBody.includes("UNREGISTERED") ||
        errBody.includes("NOT_FOUND") ||
        errBody.includes("INVALID_ARGUMENT")
      ) {
        stale.push(token);
      }
    }

    if (stale.length) {
      await supabase.from("device_tokens").delete().in("token", stale);
    }

    return json({ sent, stale_removed: stale.length });
  } catch (e) {
    return json(
      { error: e instanceof Error ? e.message : String(e) },
      500,
    );
  }
});

function buildCopy(type: string, actorName: string): {
  title: string;
  body: string;
} {
  switch (type) {
    case "follow":
      return { title: "New follower", body: `${actorName} started following you` };
    case "like":
      return { title: "New like", body: `${actorName} liked your post` };
    case "dislike":
      return { title: "New reaction", body: `${actorName} disliked your post` };
    case "comment":
      return { title: "New comment", body: `${actorName} commented on your post` };
    case "reply":
      return { title: "New reply", body: `${actorName} replied to your comment` };
    default:
      return { title: "Entangl", body: `${actorName} interacted with you` };
  }
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

/** JWT + OAuth2 access token for FCM HTTP v1 */
async function getGoogleAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim = {
    iss: sa.client_email,
    scope: FCM_SCOPE,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const enc = (obj: unknown) =>
    base64Url(new TextEncoder().encode(JSON.stringify(obj)));

  const unsigned = `${enc(header)}.${enc(claim)}`;
  const key = await importPrivateKey(sa.private_key);
  const sig = await crypto.subtle.sign(
    { name: "RSASSA-PKCS1-v1_5" },
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64Url(new Uint8Array(sig))}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenRes.ok) {
    throw new Error(`OAuth token failed: ${await tokenRes.text()}`);
  }
  const tokenJson = await tokenRes.json();
  return tokenJson.access_token as string;
}

function base64Url(bytes: Uint8Array): string {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pemContents = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const binary = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    "pkcs8",
    binary.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
}
