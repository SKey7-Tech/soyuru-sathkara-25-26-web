# Database

Source of truth: [`supabase/migrations/`](../supabase/migrations/). Every file is
guarded (`if not exists` / `on conflict`) and safe to re-run.

## Tables

### `subjects` — top-level subject (Mathematics, Biology, …)

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid PK | `gen_random_uuid()` |
| `name_en` / `name_si` / `name_ta` | text NOT NULL | trilingual |
| `icon` | text | Material icon name, mapped in `Subject._icons` (Dart) |
| `color_hex` | text | default `#4F46E5`; parsed by `AppColors.fromHex` |
| `order_index` | int | display order |
| `created_at` | timestamptz | |

### `units` — a series of videos inside a subject

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid PK | |
| `subject_id` | uuid → `subjects` | `on delete cascade` |
| `title_en` / `title_si` / `title_ta` | text NOT NULL | |
| `order_index` | int | |

### `videos` — a YouTube lesson

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid PK | |
| `unit_id` | uuid → `units` | cascade |
| `paper_id` | uuid → `papers` | **nullable**, `on delete set null` |
| `youtube_video_id` | text NOT NULL | the bare 11-char ID, not a URL |
| `title` | text NOT NULL | |
| `duration_sec` | int | nullable — progress maths handles null |
| `thumbnail_url` | text | admin derives `https://i.ytimg.com/vi/<id>/hqdefault.jpg` |
| `order_index` | int | |

Unique on `(unit_id, youtube_video_id)` — makes the seed idempotent and stops the
same video being attached to a unit twice.

### `papers` — a downloadable PDF (past paper, model paper, notes)

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid PK | |
| `subject_id` | uuid → `subjects` | cascade |
| `year` | int | |
| `paper_type` | text | check: `past` \| `model` \| `term` \| `notes` |
| `medium` | text NOT NULL | check: `si` \| `en` \| `ta` — the language the **PDF itself** is written in |
| `title` | text NOT NULL | base / English title |
| `title_si` / `title_ta` | text | **nullable** — clients fall back to `title` |
| `storage_path` | text NOT NULL UNIQUE | path inside the `resources` bucket |
| `size_bytes` | bigint | |
| `has_answers` | boolean | default false |

`medium` and `title_*` are different things: `medium` filters by the PDF's own
language, `title_*` picks the label shown in the UI.

### `profiles` — extends `auth.users`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid PK → `auth.users` | cascade |
| `display_name` | text | null for anonymous students; UI shows a localised placeholder |
| `medium` | text | `si` \| `en` \| `ta`, default `en` — preferred language |

Created automatically by a trigger (below), never by the client.

### `watch_progress` — per-user, per-video

PK `(user_id, video_id)`. Columns: `seconds_watched`, `completed`, `updated_at`.

A `before insert or update` trigger (`touch_updated_at`) overwrites `updated_at`
with `now()` — **never trust a phone's clock** for "last watched".

### `downloads` — powers the app's "My Downloads" screen

PK `(user_id, paper_id)`, plus `downloaded_at`.

### Indexes

```
idx_units_subject   (subject_id, order_index)
idx_videos_unit     (unit_id, order_index)
idx_videos_paper    (paper_id, order_index)
idx_papers_subject  (subject_id, medium)
idx_progress_user   (user_id)
```

## Row Level Security

RLS is enabled on all seven tables. From `002_rls_policies.sql`:

| Table | Policy | Rule |
| --- | --- | --- |
| `subjects`, `units`, `videos`, `papers` | `public read <table>` | `for select using (true)` — readable while signed out |
| `profiles` | `own profile` | `for all using (auth.uid() = id) with check (auth.uid() = id)` |
| `watch_progress` | `own progress` | same, on `user_id` |
| `downloads` | `own downloads` | same, on `user_id` |

No insert/update/delete policy exists on the content tables **on purpose**.
Writes go through the service_role key, which bypasses RLS entirely.

`using` guards which rows a user may see or modify; `with check` guards which
rows they may write. Both are required — with `using` alone a user could insert a
row belonging to somebody else.

## Profile auto-creation trigger

`003_profile_trigger.sql` adds `public.handle_new_user()`, an `after insert on
auth.users` trigger. Without it a fresh sign-in lands on a Profile screen with no
row to read, and every client would need a "select, and if empty then insert"
dance on each launch.

- `security definer` is required — the trigger runs inside Supabase's own auth
  insert, where the caller has no rights on `public.profiles`.
- `display_name` falls back from `raw_user_meta_data.display_name` to the local
  part of the email, and stays null for anonymous users.
- The migration also backfills anyone who signed up before it ran.

## Storage

One bucket: **`resources`**, created by `004_storage.sql`.

| Setting | Value |
| --- | --- |
| Public | **yes** |
| Size limit | 50 MB (largest current paper ≈ 8.6 MB) |
| Allowed MIME | `application/pdf` only |

Folder convention: `papers/`, `short-notes/`, `theory/`.

**Why public rather than signed URLs** (the plan originally said signed):

1. The content is already public — these exact PDFs are served today from the
   website's `web/public/files/` with no auth. A signed URL protects nothing.
2. The app must work on slow/no network. A public URL is computed offline by the
   SDK with zero round trips and is CDN-cached. A signed URL costs an extra
   network call *before* the download starts, and expires — the wrong failure
   mode on a bad connection.

To host something genuinely restricted (answer sheets released post-exam), flip
the bucket to private and set `Env.bucketIsPublic = false` in the Flutter app;
`PaperRepository.pdfUrl()` already implements the signed-URL branch. That is the
only code change needed.

> If `004_storage.sql` prints "Skipped the storage.objects policy (not the owner
> of that table)" — that is harmless and expected on some projects. On a public
> bucket the download path never consults RLS; the policy only governs object
> *listing*, which no client does. The statement is deliberately wrapped in a
> `DO` block that swallows the privilege error, because the SQL Editor runs a
> submitted script as one transaction and a raise would roll back the whole
> schema alongside it.

## Seed data

`seed/001_seed_content.sql` is **not dummy data**. It was extracted from the live
website:

| Seeded | Source |
| --- | --- |
| 53 YouTube video IDs | `web/app/data/papers.ts` |
| Trilingual titles | `web/app/i18n/{en,si,ta}.ts` |
| PDF filenames and byte sizes | `web/public/files/**` |

Result: `subjects 1 | units 3 | papers 6 | videos 53`. Fixed UUIDs plus
`on conflict` make it re-runnable.

### Assumptions baked into the seed

- **Base papers are assumed Sinhala medium.** The site labels some papers
  "(Tamil Medium)" against an unlabelled base, so the base is taken as `si`. If
  they are actually English, change `'si'` to `'en'` on the three rows marked
  `BASE`. Nothing else depends on it.
- **`paper_type` is `model`, not `past`** — the site calls these "practice
  questions and exercises", not sat papers.
- **`year` is 2026** for everything, from the site footer and repo name.

### Known content gaps

- **Theory notes are not seeded.** The website lists three
  (`web/app/data/theory.ts`) but `web/public/files/theory/` does not exist and their
  video IDs are all the same placeholder. The rows sit commented at the bottom
  of the seed; uncomment once real PDFs exist. Each needs its own subject row
  too, since they are Biology / Physics / Chemistry rather than Mathematics.
- **`prospectus.pdf`, `annual-report-2024.pdf`, `student-handbook-2025.pdf`** are
  all exactly 13,179 bytes — byte-identical placeholder stubs. Not seeded, and
  they are institutional brochures rather than study material anyway.
- **Two papers have no discussion videos** — Hard Level and Medium Level
  (Tamil). Correct as-is; they are what the app's empty states are tested
  against.

## Two documented deviations from the original plan

Both are explained at length inside `001_init_schema.sql`:

1. **`videos.paper_id`** — the plan kept papers and videos independent, but on
   the real site every video is a discussion *of a specific paper*. Made
   nullable so the independence the plan wanted is preserved: a video needs no
   paper, a paper needs no videos, and neither developer's screens block on the
   other's data.
2. **`papers.title_si` / `title_ta`** — `papers` was given a single `title` while
   `subjects` and `units` are trilingual. Papers are the most user-facing rows in
   the app; shipping a trilingual product that renders its paper list in one
   language would be a bug. Nullable, so anything writing only `title` keeps
   working.

## Regenerating the bundle

`supabase/RUN_ALL.sql` is a convenience concatenation for pasting into the SQL
Editor. The files in `migrations/` and `seed/` remain the source of truth — edit
those, then:

```powershell
python supabase/build_run_all.py    # run from the repo root
```
