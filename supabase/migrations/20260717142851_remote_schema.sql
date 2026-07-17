drop extension if exists "pg_net";

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


  create policy "Avatars are publicly accessible"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'avatars'::text));



  create policy "Post images are publicly accessible"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'post-images'::text));



  create policy "Stories publicly accessible"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'stories'::text));



  create policy "Users can delete own story files"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'stories'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));



  create policy "Users can delete their own avatar"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'avatars'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));



  create policy "Users can delete their own post images"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'post-images'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));



  create policy "Users can update their own avatar"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'avatars'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));



  create policy "Users can update their own post images"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'post-images'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));



  create policy "Users can upload post images"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'post-images'::text));



  create policy "Users can upload stories"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'stories'::text));



  create policy "Users can upload their own avatar"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'avatars'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));



