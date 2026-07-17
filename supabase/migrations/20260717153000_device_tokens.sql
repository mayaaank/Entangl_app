-- FCM device tokens (one row per physical device token; multi-device per user).
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    token text NOT NULL,
    platform text NOT NULL CHECK (platform = ANY (ARRAY['android'::text, 'ios'::text, 'web'::text])),
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT device_tokens_token_key UNIQUE (token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id
    ON public.device_tokens USING btree (user_id);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own device tokens"
    ON public.device_tokens FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own device tokens"
    ON public.device_tokens FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own device tokens"
    ON public.device_tokens FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own device tokens"
    ON public.device_tokens FOR DELETE
    USING (auth.uid() = user_id);

GRANT ALL ON TABLE public.device_tokens TO anon;
GRANT ALL ON TABLE public.device_tokens TO authenticated;
GRANT ALL ON TABLE public.device_tokens TO service_role;
