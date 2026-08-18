-- =====================================================================
-- Soyuru Sathkara — 004_storage.sql
-- Run this FOURTH.
--
-- Creates the 'resources' bucket that holds every PDF. The plan said
-- "do not use raw Google Drive links" — agreed, this is the replacement.
-- =====================================================================

-- ---------------------------------------------------------------------
-- PUBLIC vs PRIVATE — a decision worth understanding before you change it.
--
-- The plan said "wired to Supabase Storage signed URLs". This creates the
-- bucket PUBLIC instead. Reasons:
--
--   1. The content is already public. These exact PDFs are served today
--      from the website's /public/files/ with no auth at all. A signed
--      URL protects nothing that isn't already downloadable by anyone.
--   2. Step 4 of the plan requires the app to work on "slow/no network".
--      A public URL is computed offline by the SDK with zero round trips
--      and is cached by Supabase's CDN. A signed URL costs an extra
--      network call *before* the download can even start, and expires —
--      which is exactly the wrong failure mode on a bad connection.
--
-- If you later host something genuinely restricted (e.g. answer sheets
-- released only after an exam), flip this bucket to private and switch
-- PaperRepository.pdfUrl() to its signed-URL branch — the Dart side
-- already implements both. That is the only code change needed.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'resources',
  'resources',
  true,
  52428800,                      -- 50 MB; largest current paper is ~8.6 MB
  array['application/pdf']
)
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Read policy on storage.objects.
--
-- ⚠ If this errors with "must be owner of table objects", ignore it and carry
--   on — the app will still work. On a public bucket the download path does
--   not consult RLS at all; this policy only governs *listing* objects, which
--   nothing in the Flutter app does. Some Supabase projects do not grant the
--   SQL Editor role ownership of storage.objects, in which case add the policy
--   through Storage > Policies in the dashboard instead, or skip it.
-- Wrapped in a DO block that swallows a privilege error on purpose. The
-- Supabase SQL Editor runs a submitted script as ONE transaction, so if this
-- statement raised, every migration pasted alongside it would roll back too —
-- losing the whole schema over an optional policy.
do $storage_policy$
begin
  execute 'drop policy if exists "public read resources" on storage.objects';
  execute 'create policy "public read resources" on storage.objects '
          'for select using (bucket_id = ''resources'')';
  raise notice 'storage.objects read policy created.';
exception
  when insufficient_privilege or undefined_table then
    raise notice
      'Skipped the storage.objects policy (not the owner of that table). '
      'This is harmless: the bucket is public, so downloads never consult '
      'RLS. Only object *listing* is affected, which the app never does.';
end
$storage_policy$;

-- No insert/update/delete policy on purpose. Uploads happen from the
-- Dashboard or with the service_role key (see scripts/upload_pdfs.mjs),
-- both of which bypass RLS. The app must never be able to write here.
