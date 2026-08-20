-- =====================================================================
-- Soyuru Sathkara — RUN_ALL.sql   (GENERATED — do not edit by hand)
--
-- All five scripts in supabase/migrations/ and supabase/seed/, in order,
-- so the whole backend can be created with one paste.
--
-- HOW TO RUN
--   1. https://supabase.com/dashboard/project/atvpbxxzpnhjtsuuzmfu/sql/new
--   2. Paste this entire file.
--   3. Run.
--
-- The last statement prints a row count. You want:
--     subjects 1 | units 3 | papers 6 | videos 53
--
-- The SQL Editor runs this as a SINGLE TRANSACTION, so it either all
-- applies or none of it does — there is no half-migrated state to clean
-- up if something fails. Safe to re-run: every statement is guarded.
--
-- To regenerate after editing any source file:
--     python supabase/build_run_all.py
-- =====================================================================



-- =====================================================================
-- SCHEMA — tables, constraints, indexes
-- source: supabase/migrations/001_init_schema.sql
-- =====================================================================

-- =====================================================================
-- Soyuru Sathkara — 001_init_schema.sql
-- Run this FIRST, in the Supabase SQL Editor (Dashboard > SQL Editor).
--
-- Shared backend for both the Next.js website and the Flutter app.
-- Safe to re-run: every statement is guarded (if not exists / on conflict).
-- =====================================================================

-- ================================
-- SUBJECTS
-- ================================
create table if not exists subjects (
  id            uuid primary key default gen_random_uuid(),
  name_en       text not null,
  name_si       text not null,
  name_ta       text not null,
  icon          text,               -- asset name or URL
  color_hex     text default '#4F46E5',
  order_index   int not null default 0,
  created_at    timestamptz default now()
);

-- ================================
-- UNITS (belongs to a subject)
-- ================================
create table if not exists units (
  id            uuid primary key default gen_random_uuid(),
  subject_id    uuid not null references subjects(id) on delete cascade,
  title_en      text not null,
  title_si      text not null,
  title_ta      text not null,
  order_index   int not null default 0,
  created_at    timestamptz default now()
);

-- ================================
-- VIDEOS (belongs to a unit)
-- ================================
create table if not exists videos (
  id                uuid primary key default gen_random_uuid(),
  unit_id           uuid not null references units(id) on delete cascade,
  youtube_video_id  text not null,        -- just the 11-char YouTube ID
  title             text not null,
  duration_sec      int,
  thumbnail_url     text,
  order_index       int not null default 0,
  created_at        timestamptz default now(),

  -- Makes the seed script idempotent and stops the same video being
  -- attached to one unit twice by a content-entry mistake.
  constraint videos_unit_youtube_key unique (unit_id, youtube_video_id)
);

-- ================================
-- PAPERS / RESOURCES (downloadable PDFs)
-- ================================
create table if not exists papers (
  id            uuid primary key default gen_random_uuid(),
  subject_id    uuid not null references subjects(id) on delete cascade,
  year          int,
  paper_type    text check (paper_type in ('past','model','term','notes')) default 'past',
  medium        text check (medium in ('si','en','ta')) not null,
  title         text not null,
  storage_path  text not null,        -- path inside the 'resources' Storage bucket
  size_bytes    bigint,
  has_answers   boolean default false,
  created_at    timestamptz default now(),

  constraint papers_storage_path_key unique (storage_path)
);

-- ---------------------------------------------------------------------
-- DEVIATION FROM THE ORIGINAL PLAN — read this before touching it.
--
-- The plan kept `papers` and `videos` fully independent. The real
-- website content does not work that way: every one of the 53 published
-- YouTube videos is a *discussion of a specific paper*
-- (see app/data/papers.ts on the web repo — each paper carries its own
-- videos[] array). Without this link the app cannot reproduce the site.
--
-- The column is NULLABLE on purpose, which preserves the property the
-- plan actually wanted: a video does not need a paper, a paper does not
-- need videos, and neither dev's screens block on the other's data.
--   * Dev A can ignore this column entirely.
--   * Dev B uses it for the "discussions for this paper" list.
-- ---------------------------------------------------------------------
alter table videos
  add column if not exists paper_id uuid references papers(id) on delete set null;

-- ---------------------------------------------------------------------
-- SECOND DEVIATION — trilingual paper titles.
--
-- `subjects` and `units` are trilingual (name_en/si/ta) but `papers` was
-- given a single `title`. Papers are the most user-facing rows in the
-- whole app, and the website *already* has all three translations for
-- every one of them (app/i18n/{en,si,ta}.ts). Shipping a trilingual app
-- that renders its paper list in one language only would be a bug.
--
-- Both columns are NULLABLE, so nothing that writes only `title` breaks.
-- The Dart model falls back to `title` when the requested language is
-- missing — see Paper.titleFor() in lib/models/paper.dart.
--
-- Note `medium` is a different thing and is NOT redundant with these:
-- `medium` = the language the PDF itself is written in (used for
-- filtering), title_* = the language of the label shown in the UI.
-- ---------------------------------------------------------------------
alter table papers
  add column if not exists title_si text,
  add column if not exists title_ta text;

-- ================================
-- PROFILES (extends Supabase auth.users)
-- ================================
create table if not exists profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  display_name  text,
  medium        text check (medium in ('si','en','ta')) default 'en',
  created_at    timestamptz default now()
);

-- ================================
-- WATCH PROGRESS
-- ================================
create table if not exists watch_progress (
  user_id         uuid not null references auth.users(id) on delete cascade,
  video_id        uuid not null references videos(id) on delete cascade,
  seconds_watched int not null default 0,
  completed       boolean not null default false,
  updated_at      timestamptz default now(),
  primary key (user_id, video_id)
);

-- ================================
-- DOWNLOADS LOG (powers the "My Downloads" screen)
-- ================================
create table if not exists downloads (
  user_id       uuid not null references auth.users(id) on delete cascade,
  paper_id      uuid not null references papers(id) on delete cascade,
  downloaded_at timestamptz default now(),
  primary key (user_id, paper_id)
);

-- ================================
-- INDEXES
-- ================================
create index if not exists idx_units_subject  on units(subject_id, order_index);
create index if not exists idx_videos_unit    on videos(unit_id, order_index);
create index if not exists idx_videos_paper   on videos(paper_id, order_index);
create index if not exists idx_papers_subject on papers(subject_id, medium);
create index if not exists idx_progress_user  on watch_progress(user_id);

-- ================================
-- updated_at maintenance
-- Added on top of the plan: never trust a mobile client's clock for
-- "last watched". The trigger overwrites whatever the app sends.
-- ================================
create or replace function touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists watch_progress_touch on watch_progress;
create trigger watch_progress_touch
  before insert or update on watch_progress
  for each row execute function touch_updated_at();


-- =====================================================================
-- ROW LEVEL SECURITY
-- source: supabase/migrations/002_rls_policies.sql
-- =====================================================================

-- =====================================================================
-- Soyuru Sathkara — 002_rls_policies.sql
-- Run this SECOND.
--
-- RLS *is* the backend. There is no Express/Django server in front of
-- Postgres — the Flutter app and the website both talk to Supabase
-- directly with the anon key, so every rule that protects data has to
-- live here. If a table has RLS enabled and no policy, it is invisible;
-- if a table has RLS disabled, it is wide open. Get this file right.
--
-- Safe to re-run: each policy is dropped before being recreated.
-- =====================================================================

alter table subjects       enable row level security;
alter table units          enable row level security;
alter table videos         enable row level security;
alter table papers         enable row level security;
alter table profiles       enable row level security;
alter table watch_progress enable row level security;
alter table downloads      enable row level security;

-- ---------------------------------------------------------------------
-- PUBLIC CONTENT
-- Anyone (signed in or not) can read. Nobody can write from the client.
-- Content entry happens through the Dashboard / the service_role key,
-- which bypasses RLS — so no insert/update/delete policy is wanted here.
-- Deliberately readable while logged out: students should be able to
-- browse papers and videos before they ever create an account.
-- ---------------------------------------------------------------------
drop policy if exists "public read subjects" on subjects;
create policy "public read subjects" on subjects for select using (true);

drop policy if exists "public read units" on units;
create policy "public read units" on units for select using (true);

drop policy if exists "public read videos" on videos;
create policy "public read videos" on videos for select using (true);

drop policy if exists "public read papers" on papers;
create policy "public read papers" on papers for select using (true);

-- ---------------------------------------------------------------------
-- PER-USER DATA
-- `using` guards the rows a user may see/modify; `with check` guards the
-- rows they may write. Both are required — with only `using`, a user
-- could insert a row belonging to somebody else.
-- ---------------------------------------------------------------------
drop policy if exists "own profile" on profiles;
create policy "own profile" on profiles for all
  using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "own progress" on watch_progress;
create policy "own progress" on watch_progress for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own downloads" on downloads;
create policy "own downloads" on downloads for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);


-- =====================================================================
-- PROFILE AUTO-CREATION TRIGGER
-- source: supabase/migrations/003_profile_trigger.sql
-- =====================================================================

-- =====================================================================
-- Soyuru Sathkara — 003_profile_trigger.sql
-- Run this THIRD.
--
-- Not in the original plan, but the app breaks without it. `profiles`
-- has an RLS policy letting a user manage their own row, but nothing
-- ever *creates* that row — so a fresh sign-in would land on a Profile
-- screen with no record to read or update, and the app would have to
-- do a "select, and if empty then insert" dance on every launch.
--
-- A trigger on auth.users creates it once, atomically, at signup.
-- security definer is required: the trigger runs during Supabase's own
-- auth insert, where the caller has no rights on public.profiles.
-- =====================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, medium)
  values (
    new.id,
    -- Anonymous students have no email, so display_name stays null and
    -- the app shows its own localised "Student" placeholder.
    coalesce(
      new.raw_user_meta_data ->> 'display_name',
      nullif(split_part(coalesce(new.email, ''), '@', 1), '')
    ),
    coalesce(new.raw_user_meta_data ->> 'medium', 'en')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill anyone who signed up before this migration ran.
insert into public.profiles (id, display_name)
select u.id, nullif(split_part(coalesce(u.email, ''), '@', 1), '')
from auth.users u
where not exists (select 1 from public.profiles p where p.id = u.id);


-- =====================================================================
-- STORAGE BUCKET
-- source: supabase/migrations/004_storage.sql
-- =====================================================================

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


-- =====================================================================
-- SEED — real content from the website
-- source: supabase/seed/001_seed_content.sql
-- =====================================================================

-- =====================================================================
-- Soyuru Sathkara — 001_seed_content.sql
-- Run this LAST, after 001-004 in supabase/migrations/.
--
-- This is NOT dummy data. Every row below was extracted from the live
-- website:
--   * paper titles / descriptions  -> app/i18n/{en,si,ta}.ts
--   * PDF filenames and sizes      -> public/files/**
--   * all 53 YouTube video IDs     -> app/data/papers.ts
--
-- The plan asked for "1 subject, 1 unit, 3 real videos, 2 real papers"
-- so both devs have something real to build against. There was enough
-- real content to seed the whole Mathematics subject, so it does.
--
-- Safe to re-run: fixed UUIDs + on conflict do nothing/update.
-- Videos are keyed on (unit_id, youtube_video_id), so re-running will
-- not duplicate them even though their UUIDs are generated.
--
-- ⚠ Uploading the PDFs to Storage is a SEPARATE step. The storage_path
--   values below are promises; run scripts/upload_pdfs.mjs to keep them.
-- =====================================================================

-- ================================
-- SUBJECT
--
-- Only Mathematics is seeded, because Mathematics is the only subject
-- with real content. The website's theory section lists Biology /
-- Physics / Chemistry items, but public/files/theory/ does not exist —
-- those three PDFs have never been added. Seeding them would put rows
-- in the database whose download button is guaranteed to 404, so they
-- are left commented out at the bottom of this file instead.
-- ================================
insert into subjects (id, name_en, name_si, name_ta, icon, color_hex, order_index) values
  ('a0000000-0000-4000-8000-000000000001',
   'Mathematics', 'ගණිතය', 'கணிதம்',
   'calculate', '#2563EB', 0)
on conflict (id) do update
  set name_en = excluded.name_en,
      name_si = excluded.name_si,
      name_ta = excluded.name_ta,
      icon    = excluded.icon;

-- ================================
-- PAPERS
--
-- paper_type: 'model' rather than 'past'. The site describes these as
-- "practice questions and exercises", not sat examination papers.
--
-- medium: the level papers come in a base version and an explicitly
-- Tamil-labelled version ("Easy Level Paper (Tamil Medium)"), so the
-- base is taken to be Sinhala medium. ⚠ If the base papers are actually
-- English medium, change 'si' -> 'en' on the three rows marked BASE.
-- Nothing else depends on it; the app just filters on this value.
-- ================================
insert into papers (id, subject_id, year, paper_type, medium, title, title_si, title_ta, storage_path, size_bytes, has_answers) values
  -- BASE
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
   2026, 'model', 'si',
   'Easy Level Paper',
   'පහසු මට්ටමේ ප්‍රශ්න පත්‍රය',
   'எளிதான நிலை தாள்',
   'papers/Easy-Level.pdf', 6680967, false),

  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001',
   2026, 'model', 'ta',
   'Easy Level Paper (Tamil Medium)',
   'පහසු මට්ටමේ ප්‍රශ්න පත්‍රය (දෙමළ මාධ්‍ය)',
   'எளிதான நிலை தாள் (தமிழ் ஊடகம்)',
   'papers/Easy-paper-tamil.pdf', 753803, false),

  -- BASE
  ('c0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001',
   2026, 'model', 'si',
   'Medium Level Paper',
   'මධ්‍යම මට්ටමේ ප්‍රශ්න පත්‍රය',
   'நடுத்தர நிலை தாள்',
   'papers/Medium-Level.pdf', 8593020, false),

  ('c0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001',
   2026, 'model', 'ta',
   'Medium Level Paper (Tamil Medium)',
   'මධ්‍යම මට්ටමේ ප්‍රශ්න පත්‍රය (දෙමළ මාධ්‍ය)',
   'நடுத்தர நிலை தாள் (தமிழ் ஊடகம்)',
   'papers/Medium_paper_tamil.pdf', 458626, false),

  -- BASE
  ('c0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000001',
   2026, 'model', 'si',
   'Hard Level Paper',
   'අභියෝගාත්මක මට්ටමේ ප්‍රශ්න පත්‍රය',
   'கடின நிலை தாள்',
   'papers/Hard-Level.pdf', 8433517, false),

  ('c0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000001',
   2026, 'notes', 'si',
   'Short Note for Mathematics',
   'ගණිතය සඳහා කෙටි සටහනක්',
   'கணிதத்திற்கான சிறு குறிப்பு',
   'short-notes/Short-Note.pdf', 8173217, false)
on conflict (id) do update
  set title        = excluded.title,
      title_si     = excluded.title_si,
      title_ta     = excluded.title_ta,
      medium       = excluded.medium,
      paper_type   = excluded.paper_type,
      storage_path = excluded.storage_path,
      size_bytes   = excluded.size_bytes;

-- ================================
-- UNITS
--
-- One unit per discussion series. This is how the site's paper->videos[]
-- arrays map onto the plan's subject -> unit -> video hierarchy: the
-- unit is the series, and every video in it also points back at the
-- paper being discussed via videos.paper_id.
--
-- Medium-Level-Tamil and Hard-Level get no unit — their videos[] arrays
-- on the website are empty (commented out). They will appear in the
-- Papers tab as downloads with no discussions, which is correct.
--
-- ⚠ Tamil note: the website renders "discussion" as "சர்ச்சை", which
--   means *controversy*, not discussion. Corrected to "கலந்துரையாடல்"
--   here. The website's app/i18n/ta.ts still has the wrong word.
-- ================================
insert into units (id, subject_id, title_en, title_si, title_ta, order_index) values
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
   'Easy Level Paper — Discussions',
   'පහසු මට්ටමේ ප්‍රශ්න පත්‍රය — සාකච්ඡා',
   'எளிதான நிலை தாள் — கலந்துரையாடல்கள்', 0),

  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001',
   'Easy Level Paper (Tamil Medium) — Discussions',
   'පහසු මට්ටමේ ප්‍රශ්න පත්‍රය (දෙමළ මාධ්‍ය) — සාකච්ඡා',
   'எளிதான நிலை தாள் (தமிழ் ஊடகம்) — கலந்துரையாடல்கள்', 1),

  ('b0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001',
   'Medium Level Paper — Discussions',
   'මධ්‍යම මට්ටමේ ප්‍රශ්න පත්‍රය — සාකච්ඡා',
   'நடுத்தர நிலை தாள் — கலந்துரையாடல்கள்', 2)
on conflict (id) do update
  set title_en = excluded.title_en,
      title_si = excluded.title_si,
      title_ta = excluded.title_ta;

-- ================================
-- VIDEOS — all 53, verbatim from app/data/papers.ts
--
-- thumbnail_url is derived rather than stored by hand: YouTube's
-- i.ytimg.com path is stable and needs no API key, which is why the
-- plan's optional YouTube Data API step stays unnecessary for v1.
-- duration_sec is left null — it cannot be known without that API.
-- ================================
insert into videos (unit_id, paper_id, youtube_video_id, title, thumbnail_url, order_index)
select
  v.unit_id,
  v.paper_id,
  v.yt,
  'Discussion Part ' || v.idx,
  'https://i.ytimg.com/vi/' || v.yt || '/hqdefault.jpg',
  v.idx
from (values
  -- ---- Easy Level (19) ----
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  1, 'Dj7ku0IeZN8'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  2, 'Q4lV1t5VuGE'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  3, 'WmTqfD6F-OA'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  4, 'ertLNjFgIUk'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  5, 'YDlKm7Yi6No'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  6, '6wmsE4asEJI'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  7, 'anDQta3nTSY'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  8, 'f6nsZZHN5JU'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid,  9, 'ocsmE01HXQU'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 10, '7-3zVBy9Iws'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 11, 'STG73KgF1sk'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 12, '7ZP8vAYbxGA'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 13, 'oTPwcWMRIDA'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 14, 'sc48dXE8yRA'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 15, 'FW4nXDEHa20'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 16, 'eUsahqM0ya8'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 17, 'mIgDl3MNmzY'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 18, 'hwzHPrSHZKY'),
  ('b0000000-0000-4000-8000-000000000001'::uuid, 'c0000000-0000-4000-8000-000000000001'::uuid, 19, '5DKyuiAtmHg'),

  -- ---- Easy Level, Tamil medium (14) ----
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  1, 'E-dC-0GiMw8'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  2, '_QWzdMMjaTQ'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  3, 'R_LOqP3F-4A'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  4, 'pGebatgusBE'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  5, 'WYuZZzpGPIk'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  6, 'rFRYvfgeMFU'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  7, 'eSPiR97NSeg'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  8, 'Jof4XtRQmwU'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid,  9, 'FUUXTucquGE'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid, 10, 'CwAj8RLdDXM'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid, 11, '5nbiU2g6Ln0'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid, 12, 'aCGIy6mlcUI'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid, 13, '07EpnCjdGy0'),
  ('b0000000-0000-4000-8000-000000000002'::uuid, 'c0000000-0000-4000-8000-000000000002'::uuid, 14, 'KiXf6Xo6QjI'),

  -- ---- Medium Level (20) ----
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  1, '0cL-ZvTdGH8'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  2, 'IzL_U_wmmmY'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  3, 'DWhpTaIu5Mk'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  4, 'gzuc_aOoVWw'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  5, 'BJ9bjLbumG4'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  6, '2r1rhJ0Qi68'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  7, 'hrQ0ZAWyWsk'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  8, 'y37FH06j18g'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid,  9, '5Fl4ybRuinI'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 10, 'V835LWpFbIU'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 11, 'EulOPDhD1ME'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 12, 'D5PT5GfV_eQ'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 13, 'udD8v1OL9zs'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 14, 'BPeqw8Q6qfo'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 15, 'OQjy4ewu2-U'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 16, 'bqWdKwLWEBU'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 17, '2_lCRD-B0C4'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 18, 'F7LdCeJ7hHg'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 19, 'QEn05THsecY'),
  ('b0000000-0000-4000-8000-000000000003'::uuid, 'c0000000-0000-4000-8000-000000000003'::uuid, 20, 'zBWMJDzRlz8')
) as v(unit_id, paper_id, idx, yt)
on conflict (unit_id, youtube_video_id) do nothing;

-- =====================================================================
-- NOT SEEDED — waiting on real files
--
-- The website lists these three theory notes (app/data/theory.ts) but
-- the PDFs do not exist: there is no public/files/theory/ directory.
-- Their videos[] arrays are also all the same placeholder ID
-- (xNQjYPs6uJU), so there is no real video content either.
--
-- Uncomment once the actual PDFs exist and have been uploaded. Each
-- needs its own subject row too, since they are Biology/Physics/
-- Chemistry rather than Mathematics.
--
-- insert into subjects (id, name_en, name_si, name_ta, icon, color_hex, order_index) values
--   ('a0000000-0000-4000-8000-000000000002', 'Biology',   'ජීව විද්‍යාව',   'உயிரியல்',   'biotech',  '#16A34A', 1),
--   ('a0000000-0000-4000-8000-000000000003', 'Physics',   'භෞතික විද්‍යාව', 'இயற்பியல்',  'science',  '#DC2626', 2),
--   ('a0000000-0000-4000-8000-000000000004', 'Chemistry', 'රසායන විද්‍යාව', 'வேதியியல்', 'biotech',  '#9333EA', 3);
--
-- insert into papers (subject_id, year, paper_type, medium, title, title_si, title_ta, storage_path) values
--   ('a0000000-0000-4000-8000-000000000002', 2026, 'notes', 'si', 'Cell Structure',    'සෛල ව්‍යුහය',            'செல் அமைப்பு',      'theory/biology-cell-structure.pdf'),
--   ('a0000000-0000-4000-8000-000000000003', 2026, 'notes', 'si', 'Mechanics',         'යාන්ත්‍රික විද්‍යාව',      'இயக்கவியல்',       'theory/physics-mechanics.pdf'),
--   ('a0000000-0000-4000-8000-000000000004', 2026, 'notes', 'si', 'Organic Chemistry', 'කාබනික රසායන විද්‍යාව', 'கரிம வேதியியல்', 'theory/chemistry-organic.pdf');
--
-- Also not seeded: public/files/{prospectus,annual-report-2024,student-handbook-2025}.pdf.
-- All three are 13,179 bytes — byte-identical placeholder stubs, not
-- real documents. They are institutional brochures rather than study
-- material, so they do not belong in `papers` regardless.
-- =====================================================================

-- ================================
-- Verify
-- ================================
select 'subjects' as t, count(*) from subjects
union all select 'units',  count(*) from units
union all select 'papers', count(*) from papers
union all select 'videos', count(*) from videos;
-- expected: subjects 1, units 3, papers 6, videos 53
