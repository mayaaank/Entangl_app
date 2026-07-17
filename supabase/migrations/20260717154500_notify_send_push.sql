-- Enable pg_net for async HTTP from triggers (FCM via Edge Function).
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Fires after each notifications INSERT.
-- Requires vault secret named `push_webhook_secret` (set once in production):
--   select vault.create_secret('<secret>', 'push_webhook_secret', 'send-push webhook');
-- And Edge Function secrets:
--   FIREBASE_PROJECT_ID, FIREBASE_SERVICE_ACCOUNT_JSON, PUSH_WEBHOOK_SECRET
CREATE OR REPLACE FUNCTION public.notify_send_push()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, net
AS $$
DECLARE
  webhook_secret text;
  req_id bigint;
  payload jsonb;
BEGIN
  SELECT decrypted_secret INTO webhook_secret
  FROM vault.decrypted_secrets
  WHERE name = 'push_webhook_secret'
  LIMIT 1;

  IF webhook_secret IS NULL OR webhook_secret = '' THEN
    RAISE WARNING 'push_webhook_secret not found in vault; skip FCM';
    RETURN NEW;
  END IF;

  payload := jsonb_build_object(
    'type', 'INSERT',
    'table', TG_TABLE_NAME,
    'schema', TG_TABLE_SCHEMA,
    'record', to_jsonb(NEW),
    'old_record', NULL
  );

  SELECT net.http_post(
    url := 'https://lmohyfcmiftvuluhyaqh.supabase.co/functions/v1/send-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', webhook_secret
    ),
    body := payload,
    timeout_milliseconds := 5000
  ) INTO req_id;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_notification_send_push ON public.notifications;
CREATE TRIGGER on_notification_send_push
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_send_push();

GRANT EXECUTE ON FUNCTION public.notify_send_push() TO postgres, service_role;
