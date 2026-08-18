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
