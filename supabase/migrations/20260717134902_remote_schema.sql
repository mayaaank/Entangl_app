


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."create_notification"("p_user_id" "uuid", "p_actor_id" "uuid", "p_type" "text", "p_post_id" "uuid" DEFAULT NULL::"uuid", "p_comment_id" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Don't create notification if user is acting on their own content
    IF p_user_id != p_actor_id THEN
        INSERT INTO public.notifications (user_id, actor_id, type, post_id, comment_id)
        VALUES (p_user_id, p_actor_id, p_type, p_post_id, p_comment_id);
    END IF;
END;
$$;


ALTER FUNCTION "public"."create_notification"("p_user_id" "uuid", "p_actor_id" "uuid", "p_type" "text", "p_post_id" "uuid", "p_comment_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_dislike_count"("post_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.dislikes WHERE post_id = post_id);
END;
$$;


ALTER FUNCTION "public"."get_dislike_count"("post_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_feed_posts"("user_id" "uuid", "page_limit" integer DEFAULT 10, "page_offset" integer DEFAULT 0) RETURNS TABLE("post_id" "uuid", "post_content" "text", "post_image_url" "text", "post_created_at" timestamp with time zone, "author_id" "uuid", "author_username" "text", "author_full_name" "text", "author_avatar_url" "text", "like_count" bigint, "comment_count" bigint, "is_liked" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as post_id,
        p.content as post_content,
        p.image_url as post_image_url,
        p.created_at as post_created_at,
        prof.id as author_id,
        prof.username as author_username,
        prof.full_name as author_full_name,
        prof.avatar_url as author_avatar_url,
        COUNT(DISTINCT l.id) as like_count,
        COUNT(DISTINCT c.id) as comment_count,
        EXISTS(SELECT 1 FROM public.likes WHERE post_id = p.id AND likes.user_id = user_id) as is_liked
    FROM public.posts p
    INNER JOIN public.profiles prof ON p.user_id = prof.id
    LEFT JOIN public.likes l ON p.id = l.post_id
    LEFT JOIN public.comments c ON p.id = c.post_id
    WHERE p.user_id IN (
        SELECT following_id FROM public.follows WHERE follower_id = user_id
        UNION
        SELECT user_id
    )
    GROUP BY p.id, prof.id
    ORDER BY p.created_at DESC
    LIMIT page_limit
    OFFSET page_offset;
END;
$$;


ALTER FUNCTION "public"."get_feed_posts"("user_id" "uuid", "page_limit" integer, "page_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_follower_count"("profile_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.follows WHERE following_id = profile_id);
END;
$$;


ALTER FUNCTION "public"."get_follower_count"("profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_followers"("profile_id" "uuid") RETURNS TABLE("user_id" "uuid", "username" "text", "full_name" "text", "avatar_url" "text", "is_following" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        prof.id as user_id,
        prof.username,
        prof.full_name,
        prof.avatar_url,
        EXISTS(SELECT 1 FROM public.follows WHERE follower_id = auth.uid() AND following_id = prof.id) as is_following
    FROM public.profiles prof
    INNER JOIN public.follows f ON prof.id = f.follower_id
    WHERE f.following_id = profile_id
    ORDER BY prof.full_name;
END;
$$;


ALTER FUNCTION "public"."get_followers"("profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_following"("profile_id" "uuid") RETURNS TABLE("user_id" "uuid", "username" "text", "full_name" "text", "avatar_url" "text", "is_following" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        prof.id as user_id,
        prof.username,
        prof.full_name,
        prof.avatar_url,
        true as is_following
    FROM public.profiles prof
    INNER JOIN public.follows f ON prof.id = f.following_id
    WHERE f.follower_id = profile_id
    ORDER BY prof.full_name;
END;
$$;


ALTER FUNCTION "public"."get_following"("profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_following_count"("profile_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.follows WHERE follower_id = profile_id);
END;
$$;


ALTER FUNCTION "public"."get_following_count"("profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_like_count"("post_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.likes WHERE post_id = post_id);
END;
$$;


ALTER FUNCTION "public"."get_like_count"("post_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_post_count"("profile_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.posts WHERE user_id = profile_id);
END;
$$;


ALTER FUNCTION "public"."get_post_count"("profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.notifications WHERE user_id = p_user_id AND is_read = false);
END;
$$;


ALTER FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.profiles (id, username, full_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_on_comment"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    post_owner_id UUID;
    parent_comment_owner_id UUID;
BEGIN
    SELECT user_id INTO post_owner_id FROM public.posts WHERE id = NEW.post_id;
    
    -- If it's a reply, notify the parent comment owner
    IF NEW.parent_id IS NOT NULL THEN
        SELECT user_id INTO parent_comment_owner_id FROM public.comments WHERE id = NEW.parent_id;
        PERFORM create_notification(
            parent_comment_owner_id,
            NEW.user_id,
            'reply',
            NEW.post_id,
            NEW.id
        );
    ELSE
        -- If it's a top-level comment, notify the post owner
        PERFORM create_notification(
            post_owner_id,
            NEW.user_id,
            'comment',
            NEW.post_id,
            NEW.id
        );
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_on_comment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_on_dislike"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    post_owner_id UUID;
BEGIN
    SELECT user_id INTO post_owner_id FROM public.posts WHERE id = NEW.post_id;
    
    PERFORM create_notification(
        post_owner_id,
        NEW.user_id,
        'dislike',
        NEW.post_id
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_on_dislike"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_on_follow"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM create_notification(
        NEW.following_id,
        NEW.follower_id,
        'follow'
    );
    
    -- You'll need to call your API endpoint here using pg_net or similar
    -- For now, the push will be triggered from the client side
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_on_follow"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_on_like"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    post_owner_id UUID;
BEGIN
    SELECT user_id INTO post_owner_id FROM public.posts WHERE id = NEW.post_id;
    
    PERFORM create_notification(
        post_owner_id,
        NEW.user_id,
        'like',
        NEW.post_id
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_on_like"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_dislikes_post"("post_id" "uuid", "user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS(SELECT 1 FROM public.dislikes WHERE post_id = post_id AND user_id = user_id);
END;
$$;


ALTER FUNCTION "public"."user_dislikes_post"("post_id" "uuid", "user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_follows"("follower_id" "uuid", "following_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS(SELECT 1 FROM public.follows WHERE follower_id = follower_id AND following_id = following_id);
END;
$$;


ALTER FUNCTION "public"."user_follows"("follower_id" "uuid", "following_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_likes_post"("post_id" "uuid", "user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS(SELECT 1 FROM public.likes WHERE post_id = post_id AND user_id = user_id);
END;
$$;


ALTER FUNCTION "public"."user_likes_post"("post_id" "uuid", "user_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."comments" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "post_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "parent_id" "uuid"
);


ALTER TABLE "public"."comments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."dislikes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "post_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."dislikes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."follows" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "follower_id" "uuid" NOT NULL,
    "following_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "no_self_follow" CHECK (("follower_id" <> "following_id"))
);


ALTER TABLE "public"."follows" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."likes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "post_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "actor_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "post_id" "uuid",
    "comment_id" "uuid",
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "notifications_type_check" CHECK (("type" = ANY (ARRAY['follow'::"text", 'like'::"text", 'dislike'::"text", 'comment'::"text", 'reply'::"text"])))
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."posts" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "image_url" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "content_length" CHECK (("char_length"("content") > 0))
);


ALTER TABLE "public"."posts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "username" "text" NOT NULL,
    "full_name" "text" NOT NULL,
    "bio" "text",
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    CONSTRAINT "profiles_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text"]))),
    CONSTRAINT "username_length" CHECK (("char_length"("username") >= 3))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."push_subscriptions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "endpoint" "text" NOT NULL,
    "p256dh" "text" NOT NULL,
    "auth" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."push_subscriptions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stories" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "media_url" "text" NOT NULL,
    "media_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "stories_media_type_check" CHECK (("media_type" = ANY (ARRAY['image'::"text", 'video'::"text"])))
);


ALTER TABLE "public"."stories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."story_likes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "story_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."story_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."story_views" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "story_id" "uuid" NOT NULL,
    "viewer_id" "uuid" NOT NULL,
    "viewed_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."story_views" OWNER TO "postgres";


ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dislikes"
    ADD CONSTRAINT "dislikes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dislikes"
    ADD CONSTRAINT "dislikes_user_id_post_id_key" UNIQUE ("user_id", "post_id");



ALTER TABLE ONLY "public"."follows"
    ADD CONSTRAINT "follows_follower_id_following_id_key" UNIQUE ("follower_id", "following_id");



ALTER TABLE ONLY "public"."follows"
    ADD CONSTRAINT "follows_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_user_id_post_id_key" UNIQUE ("user_id", "post_id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."push_subscriptions"
    ADD CONSTRAINT "push_subscriptions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."push_subscriptions"
    ADD CONSTRAINT "push_subscriptions_user_id_endpoint_key" UNIQUE ("user_id", "endpoint");



ALTER TABLE ONLY "public"."stories"
    ADD CONSTRAINT "stories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."story_likes"
    ADD CONSTRAINT "story_likes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."story_likes"
    ADD CONSTRAINT "story_likes_story_id_user_id_key" UNIQUE ("story_id", "user_id");



ALTER TABLE ONLY "public"."story_views"
    ADD CONSTRAINT "story_views_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."story_views"
    ADD CONSTRAINT "story_views_story_id_viewer_id_key" UNIQUE ("story_id", "viewer_id");



CREATE INDEX "idx_comments_parent_id" ON "public"."comments" USING "btree" ("parent_id");



CREATE INDEX "idx_comments_post_id" ON "public"."comments" USING "btree" ("post_id");



CREATE INDEX "idx_dislikes_post_id" ON "public"."dislikes" USING "btree" ("post_id");



CREATE INDEX "idx_dislikes_user_id" ON "public"."dislikes" USING "btree" ("user_id");



CREATE INDEX "idx_follows_follower_id" ON "public"."follows" USING "btree" ("follower_id");



CREATE INDEX "idx_follows_following_id" ON "public"."follows" USING "btree" ("following_id");



CREATE INDEX "idx_likes_post_id" ON "public"."likes" USING "btree" ("post_id");



CREATE INDEX "idx_likes_user_id" ON "public"."likes" USING "btree" ("user_id");



CREATE INDEX "idx_notifications_created_at" ON "public"."notifications" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_notifications_is_read" ON "public"."notifications" USING "btree" ("is_read");



CREATE INDEX "idx_notifications_user_id" ON "public"."notifications" USING "btree" ("user_id");



CREATE INDEX "idx_posts_created_at" ON "public"."posts" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_posts_user_id" ON "public"."posts" USING "btree" ("user_id");



CREATE INDEX "idx_push_subscriptions_user_id" ON "public"."push_subscriptions" USING "btree" ("user_id");



CREATE INDEX "idx_stories_created_at" ON "public"."stories" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_stories_user_id" ON "public"."stories" USING "btree" ("user_id");



CREATE INDEX "idx_story_likes_story_id" ON "public"."story_likes" USING "btree" ("story_id");



CREATE INDEX "idx_story_views_story_id" ON "public"."story_views" USING "btree" ("story_id");



CREATE INDEX "idx_story_views_viewer_id" ON "public"."story_views" USING "btree" ("viewer_id");



CREATE OR REPLACE TRIGGER "trigger_notify_on_comment" AFTER INSERT ON "public"."comments" FOR EACH ROW EXECUTE FUNCTION "public"."notify_on_comment"();



CREATE OR REPLACE TRIGGER "trigger_notify_on_dislike" AFTER INSERT ON "public"."dislikes" FOR EACH ROW EXECUTE FUNCTION "public"."notify_on_dislike"();



CREATE OR REPLACE TRIGGER "trigger_notify_on_follow" AFTER INSERT ON "public"."follows" FOR EACH ROW EXECUTE FUNCTION "public"."notify_on_follow"();



CREATE OR REPLACE TRIGGER "trigger_notify_on_like" AFTER INSERT ON "public"."likes" FOR EACH ROW EXECUTE FUNCTION "public"."notify_on_like"();



CREATE OR REPLACE TRIGGER "update_comments_updated_at" BEFORE UPDATE ON "public"."comments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_posts_updated_at" BEFORE UPDATE ON "public"."posts" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."comments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."comments"
    ADD CONSTRAINT "comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."dislikes"
    ADD CONSTRAINT "dislikes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."dislikes"
    ADD CONSTRAINT "dislikes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."follows"
    ADD CONSTRAINT "follows_follower_id_fkey" FOREIGN KEY ("follower_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."follows"
    ADD CONSTRAINT "follows_following_id_fkey" FOREIGN KEY ("following_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_comment_id_fkey" FOREIGN KEY ("comment_id") REFERENCES "public"."comments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts"
    ADD CONSTRAINT "posts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."push_subscriptions"
    ADD CONSTRAINT "push_subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stories"
    ADD CONSTRAINT "stories_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."story_likes"
    ADD CONSTRAINT "story_likes_story_id_fkey" FOREIGN KEY ("story_id") REFERENCES "public"."stories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."story_likes"
    ADD CONSTRAINT "story_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."story_views"
    ADD CONSTRAINT "story_views_story_id_fkey" FOREIGN KEY ("story_id") REFERENCES "public"."stories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."story_views"
    ADD CONSTRAINT "story_views_viewer_id_fkey" FOREIGN KEY ("viewer_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



CREATE POLICY "Admin can update any profile" ON "public"."profiles" FOR UPDATE USING (true) WITH CHECK (true);



CREATE POLICY "Comments are viewable by everyone" ON "public"."comments" FOR SELECT USING (true);



CREATE POLICY "Dislikes are viewable by everyone" ON "public"."dislikes" FOR SELECT USING (true);



CREATE POLICY "Follows are viewable by everyone" ON "public"."follows" FOR SELECT USING (true);



CREATE POLICY "Likes are viewable by everyone" ON "public"."likes" FOR SELECT USING (true);



CREATE POLICY "Posts are viewable by everyone" ON "public"."posts" FOR SELECT USING (true);



CREATE POLICY "Public profiles are viewable by everyone" ON "public"."profiles" FOR SELECT USING (true);



CREATE POLICY "Stories visible to followers and owner" ON "public"."stories" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."follows"
  WHERE (("follows"."follower_id" = "auth"."uid"()) AND ("follows"."following_id" = "stories"."user_id"))))));



CREATE POLICY "Story likes visible to all authenticated" ON "public"."story_likes" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Story views visible to story owner and viewer" ON "public"."story_views" FOR SELECT USING ((("viewer_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."stories"
  WHERE (("stories"."id" = "story_views"."story_id") AND ("stories"."user_id" = "auth"."uid"()))))));



CREATE POLICY "Users can create comments" ON "public"."comments" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can create own stories" ON "public"."stories" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can create their own posts" ON "public"."posts" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete own stories" ON "public"."stories" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own comments" ON "public"."comments" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own notifications" ON "public"."notifications" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own posts" ON "public"."posts" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can dislike posts" ON "public"."dislikes" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can follow others" ON "public"."follows" FOR INSERT WITH CHECK (("auth"."uid"() = "follower_id"));



CREATE POLICY "Users can insert own views" ON "public"."story_views" FOR INSERT WITH CHECK (("auth"."uid"() = "viewer_id"));



CREATE POLICY "Users can insert their own profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can like posts" ON "public"."likes" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can like stories" ON "public"."story_likes" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own subscriptions" ON "public"."push_subscriptions" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can remove dislikes" ON "public"."dislikes" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can unfollow others" ON "public"."follows" FOR DELETE USING (("auth"."uid"() = "follower_id"));



CREATE POLICY "Users can unlike posts" ON "public"."likes" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can unlike stories" ON "public"."story_likes" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own comments" ON "public"."comments" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own notifications" ON "public"."notifications" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own posts" ON "public"."posts" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can view their own notifications" ON "public"."notifications" FOR SELECT USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."comments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."dislikes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."follows" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."posts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."push_subscriptions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."stories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."story_likes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."story_views" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."create_notification"("p_user_id" "uuid", "p_actor_id" "uuid", "p_type" "text", "p_post_id" "uuid", "p_comment_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_notification"("p_user_id" "uuid", "p_actor_id" "uuid", "p_type" "text", "p_post_id" "uuid", "p_comment_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_notification"("p_user_id" "uuid", "p_actor_id" "uuid", "p_type" "text", "p_post_id" "uuid", "p_comment_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_dislike_count"("post_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_dislike_count"("post_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_dislike_count"("post_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_feed_posts"("user_id" "uuid", "page_limit" integer, "page_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_feed_posts"("user_id" "uuid", "page_limit" integer, "page_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_feed_posts"("user_id" "uuid", "page_limit" integer, "page_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_follower_count"("profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_follower_count"("profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_follower_count"("profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_followers"("profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_followers"("profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_followers"("profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_following"("profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_following"("profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_following"("profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_following_count"("profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_following_count"("profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_following_count"("profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_like_count"("post_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_like_count"("post_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_like_count"("post_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_post_count"("profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_post_count"("profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_post_count"("profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_unread_notification_count"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_on_comment"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_on_comment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_on_comment"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_on_dislike"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_on_dislike"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_on_dislike"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_on_follow"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_on_follow"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_on_follow"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_on_like"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_on_like"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_on_like"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_dislikes_post"("post_id" "uuid", "user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_dislikes_post"("post_id" "uuid", "user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_dislikes_post"("post_id" "uuid", "user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_follows"("follower_id" "uuid", "following_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_follows"("follower_id" "uuid", "following_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_follows"("follower_id" "uuid", "following_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."user_likes_post"("post_id" "uuid", "user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_likes_post"("post_id" "uuid", "user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_likes_post"("post_id" "uuid", "user_id" "uuid") TO "service_role";


















GRANT ALL ON TABLE "public"."comments" TO "anon";
GRANT ALL ON TABLE "public"."comments" TO "authenticated";
GRANT ALL ON TABLE "public"."comments" TO "service_role";



GRANT ALL ON TABLE "public"."dislikes" TO "anon";
GRANT ALL ON TABLE "public"."dislikes" TO "authenticated";
GRANT ALL ON TABLE "public"."dislikes" TO "service_role";



GRANT ALL ON TABLE "public"."follows" TO "anon";
GRANT ALL ON TABLE "public"."follows" TO "authenticated";
GRANT ALL ON TABLE "public"."follows" TO "service_role";



GRANT ALL ON TABLE "public"."likes" TO "anon";
GRANT ALL ON TABLE "public"."likes" TO "authenticated";
GRANT ALL ON TABLE "public"."likes" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."posts" TO "anon";
GRANT ALL ON TABLE "public"."posts" TO "authenticated";
GRANT ALL ON TABLE "public"."posts" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."push_subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."push_subscriptions" TO "authenticated";
GRANT ALL ON TABLE "public"."push_subscriptions" TO "service_role";



GRANT ALL ON TABLE "public"."stories" TO "anon";
GRANT ALL ON TABLE "public"."stories" TO "authenticated";
GRANT ALL ON TABLE "public"."stories" TO "service_role";



GRANT ALL ON TABLE "public"."story_likes" TO "anon";
GRANT ALL ON TABLE "public"."story_likes" TO "authenticated";
GRANT ALL ON TABLE "public"."story_likes" TO "service_role";



GRANT ALL ON TABLE "public"."story_views" TO "anon";
GRANT ALL ON TABLE "public"."story_views" TO "authenticated";
GRANT ALL ON TABLE "public"."story_views" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































