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
