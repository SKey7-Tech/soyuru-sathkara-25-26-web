# Soyuru Sathkara — backend

There is **no custom backend server**. Supabase *is* the backend, and it is
shared by the Next.js website and the Flutter app. Three pieces:

| Piece | What it does |
| --- | --- |
| Postgres | subjects, units, videos, papers, profiles, watch progress, downloads |
| RLS policies | who may read/write what — this replaces server-side auth checks |
| Storage | the PDF files, in a bucket called `resources` |

Both clients talk to Supabase directly with the **anon key**. Nothing sits in
front of it, so the RLS policies in `migrations/002_rls_policies.sql` are the
only thing protecting the data. Read that file before changing anything.

---

## Current state of the project (checked against the live API)

| Thing | State |
| --- | --- |
| Publishable key | ✅ valid — `/auth/v1/health` returns 200 |
| Tables | ❌ **not created** — PostgREST reports `PGRST205` for subjects/units/videos/papers |
| Anonymous sign-ins | ❌ **disabled** — `/auth/v1/settings` reports `anonymous_users: false` |
| Email signup | enabled, with confirmation required (`mailer_autoconfirm: false`) |

So: run the migrations below, then enable anonymous sign-ins (step 7). Until the
migrations run, the app builds and launches but every screen shows
"Could not find the table 'public.subjects'".

---

## First-time setup

Run these **in order**, in the Supabase Dashboard → **SQL Editor**. Paste each
file, run, confirm success before moving on. Every script is safe to re-run.

| # | File | What it does |
| --- | --- | --- |
| 1 | `migrations/001_init_schema.sql` | tables, indexes, constraints |
| 2 | `migrations/002_rls_policies.sql` | row level security |
| 3 | `migrations/003_profile_trigger.sql` | auto-creates a `profiles` row at signup |
| 4 | `migrations/004_storage.sql` | creates the `resources` bucket |
| 5 | `seed/001_seed_content.sql` | the real content pulled off the website |

Step 5 ends with a count. You should see:

```
subjects 1 | units 3 | papers 6 | videos 53
```

### 6. Upload the PDFs

The seed writes `storage_path` values; the files themselves still have to go up.
From the repo root:

```powershell
$env:SUPABASE_URL = "https://atvpbxxzpnhjtsuuzmfu.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "<service_role key>"   # Settings > API
node scripts/upload_pdfs.mjs
```

No `npm install` needed — the script is dependency-free. It refuses to upload if
a file's size on disk disagrees with `size_bytes` in the seed, which catches a
PDF being swapped without the database being updated.

> The **service_role key bypasses RLS completely**. It belongs in your shell for
> the length of that command and nowhere else. Never in the Flutter app, never
> in the website, never in git.

### 7. Enable anonymous sign-ins

**Authentication → Sign In / Providers → Anonymous sign-ins → enabled.**

The app signs students in anonymously on first launch so watch progress works
without a signup screen. If this stays off, browsing still works — content is
readable by the anon role — but nothing saves. It fails quietly by design; check
the logcat for `AuthService` if progress is not sticking.

---

## Where the seed data came from

Nothing here is invented. It was extracted from the live website:

- **53 YouTube video IDs** — `web/app/data/papers.ts`
- **Trilingual titles** — `web/app/i18n/{en,si,ta}.ts`
- **PDF filenames and byte sizes** — `web/public/files/**`

## Known gaps in the content

- **Theory notes are not seeded.** The website lists three (`web/app/data/theory.ts`)
  but `web/public/files/theory/` does not exist and their video IDs are all the same
  placeholder. The rows are written out, commented, at the bottom of the seed —
  uncomment once real PDFs exist.
- **`prospectus.pdf`, `annual-report-2024.pdf`, `student-handbook-2025.pdf`** are
  all exactly 13,179 bytes, i.e. byte-identical placeholder stubs. Not seeded.
- **Two papers have no discussion videos yet** — Hard Level and Medium Level
  (Tamil). Their `videos[]` arrays on the website are empty. They appear in the
  app as downloads with no discussions, which is correct, and they are what the
  empty states get exercised against.

## Assumptions worth checking

- **Base papers are assumed Sinhala medium.** The site labels some papers
  "(Tamil Medium)" against an unlabelled base, so the base is taken to be `si`.
  If they are actually English medium, change `'si'` → `'en'` on the three rows
  marked `BASE` in the seed. Nothing else depends on it.
- **`paper_type` is `model`, not `past`.** The site calls these "practice
  questions and exercises", not sat papers.
- **`year` is 2026** for everything, from the site's footer and repo name.

## Two deviations from the original plan

Both are documented in full, with reasoning, inside `001_init_schema.sql`:

1. **`videos.paper_id`** (nullable) — the plan kept papers and videos fully
   independent, but on the real website every video is a discussion *of a
   specific paper*. Nullable, so the independence the plan wanted is preserved.
2. **`papers.title_si` / `title_ta`** (nullable) — `papers` was given a single
   `title` while `subjects` and `units` are trilingual. The app is trilingual and
   the translations already exist on the website.

`004_storage.sql` also makes the bucket **public** rather than using signed URLs.
The reasoning is in that file; flipping it back is one constant in the Dart code
(`Env.bucketIsPublic`), which already implements both paths.
