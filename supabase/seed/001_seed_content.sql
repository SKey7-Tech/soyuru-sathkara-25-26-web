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
