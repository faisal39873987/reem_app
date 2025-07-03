revoke select on table "auth"."schema_migrations" from "postgres";


grant delete on table "storage"."s3_multipart_uploads" to "postgres";

grant insert on table "storage"."s3_multipart_uploads" to "postgres";

grant references on table "storage"."s3_multipart_uploads" to "postgres";

grant select on table "storage"."s3_multipart_uploads" to "postgres";

grant trigger on table "storage"."s3_multipart_uploads" to "postgres";

grant truncate on table "storage"."s3_multipart_uploads" to "postgres";

grant update on table "storage"."s3_multipart_uploads" to "postgres";

grant delete on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant insert on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant references on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant select on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant trigger on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant truncate on table "storage"."s3_multipart_uploads_parts" to "postgres";

grant update on table "storage"."s3_multipart_uploads_parts" to "postgres";

create policy "Allow users to manage own profile images"
on "storage"."objects"
as permissive
for all
to public
using (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])))
with check (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Give users authenticated access to folder 1ifhysk_0"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'products'::text) AND (auth.role() = 'authenticated'::text)));


create policy "Give users authenticated access to folder 1ifhysk_1"
on "storage"."objects"
as permissive
for delete
to public
using (((bucket_id = 'products'::text) AND (auth.role() = 'authenticated'::text)));


create policy "Give users authenticated access to folder 1oj01fe_0"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'avatars'::text) AND (auth.role() = 'authenticated'::text)));


create policy "Give users authenticated access to folder 1oj01fe_1"
on "storage"."objects"
as permissive
for delete
to public
using (((bucket_id = 'avatars'::text) AND (auth.role() = 'authenticated'::text)));


create policy "Give users authenticated access to folder 1rma4z_0"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'posts'::text) AND (auth.role() = 'authenticated'::text)));


create policy "Give users authenticated access to folder 1rma4z_1"
on "storage"."objects"
as permissive
for delete
to public
using (((bucket_id = 'posts'::text) AND (auth.role() = 'authenticated'::text)));



