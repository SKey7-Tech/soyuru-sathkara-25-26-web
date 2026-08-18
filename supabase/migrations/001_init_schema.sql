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
