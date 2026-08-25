# Known issues & gaps

Verified against the working tree on branch `app-main`. Ordered roughly by
severity.

---

## 1. ✅ FIXED — `web/app/utils/supabase/` now exists

Five files, written against `@supabase/ssr` 0.12.4 / `supabase-js` 2.112.3:

| File | Role |
| --- | --- |
| [`env.ts`](../web/app/utils/supabase/env.ts) | Reads the three env vars, throwing a pointed error naming the missing one rather than failing deep inside the SDK |
| [`client.ts`](../web/app/utils/supabase/client.ts) | `createBrowserClient` — the `/resources/*` pages |
| [`server.ts`](../web/app/utils/supabase/server.ts) | `createServerClient` bound to `cookies()` — acts as the signed-in user, RLS applies |
| [`admin.ts`](../web/app/utils/supabase/admin.ts) | service_role client, RLS bypassed. Throws if called in a browser |
| [`middleware.ts`](../web/app/utils/supabase/middleware.ts) | `updateSession` — session refresh plus the `/admin` gate |

`web/.env.local` was created with the project URL and publishable key (both
already public — the same key ships inside the Flutter app). **You must paste
the service_role key into it** before the admin pages work; it is blank.

---

## 2. ✅ FIXED — `/admin` is guarded, in two layers

The panel was reachable by URL alone while running under the service_role key.
Now:

**Layer 1 — the proxy** ([`web/app/utils/supabase/middleware.ts`](../web/app/utils/supabase/middleware.ts)).
Any `/admin/*` request without a session redirects to `/admin/login`, carrying
`?redirectedFrom=`. A signed-in user landing on the login page is bounced to
`/admin`. Refreshed auth cookies are copied onto both redirects — dropping them
silently signs the user out on the next request.

**Layer 2 — the route group** ([`web/app/admin/(panel)/layout.tsx`](<../web/app/admin/(panel)/layout.tsx>)).
Being signed in is not the same as being an admin. The layout queries the
`admins` table through the **cookie-bound** client, so the `admins read own`
policy (`auth.uid() = id`) does the enforcing — a non-admin's query returns no
row regardless of what they send. No row means a redirect to `/`.

The panel moved into an `app/admin/(panel)/` route group so the login page sits
*outside* the guarded layout; inside it, an unauthenticated visit would redirect
to a page that redirects again, forever. Route groups do not affect URLs —
`/admin/papers` is still `/admin/papers`. `actions.ts` moved into the group too,
keeping the `from '../actions'` imports valid.

Note `admins` is **not in any migration** — it was created through the dashboard.
See issue 12.

---

## 3. 🟠 Short notes and theory pages return identical results

Both query the same thing:

- [app/resources/short-notes/page.tsx:37](../web/app/resources/short-notes/page.tsx#L37) — `.eq('paper_type', 'notes')`
- [app/resources/theory/page.tsx:38](../web/app/resources/theory/page.tsx#L38) — `.eq('paper_type', 'notes')`

Both source files carry a comment acknowledging the assumption. The schema's
`paper_type` check constraint has no value that distinguishes short notes from
theory notes, and `uploadPaper` files every `notes` upload under `theory/` in
Storage regardless.

Options: add a `note_kind` column (or extend the `paper_type` check with
`'short_notes'`), or filter on the `storage_path` prefix as an interim measure.
Whichever you pick, update `uploadPaper`'s folder logic and the Flutter
`PaperType` enum together.

---

## 4. 🟠 Broken static asset paths in `web/app/data/`

These matter only where the legacy data files are still rendered, but they are
wrong today:

- [app/data/papers.ts:66](../web/app/data/papers.ts#L66) points at
  `/files/papers/Medium-level.pdf`; the file on disk is `Medium-Level.pdf`.
  This works on Windows and breaks on a case-sensitive host (Vercel, Linux).
- Every `coverImage` in `web/app/data/*.ts` — `paper-cover.jpeg`,
  `handbook-cover.jpg`, `report-cover.jpg`, `prospectus-cover.jpg`,
  `notes-cover.jpg`, `theory-cover.jpg` — is missing. `web/public/gallery/` contains
  only `ss2.jpg` … `ss8.jpg`.
- `web/app/data/theory.ts` references `/files/theory/*.pdf`; that directory does not
  exist.

---

## 5. ✅ FIXED — `.gitignore` no longer excludes tracked directories

It previously ignored `soyuru_sathkara/`, `supabase/` and `scripts/` while all
three were tracked (119, 8 and 1 files respectively). Those entries are gone, and
the file now targets the split layout (`web/.next/`, `node_modules/`, `.env.*`).
Flutter build artifacts stay covered by `mobile/.gitignore`, which ignores
`.dart_tool/` and `/build/` specifically rather than the whole project.

Kept here as a record of what changed. Check `git status --ignored` before
assuming a file is safe.

---

## 6. 🟡 Legacy data files still wired into i18n

The `/resources/*` pages now read from Supabase, but
[`web/app/i18n/en.ts`](../web/app/i18n/en.ts) still imports `papers` from
`web/app/data/papers.ts` and `theory` from `web/app/data/theory.ts`, so the hard-coded
arrays cannot simply be deleted. `web/app/data/pdfs.ts` and `web/app/data/shortNotes.ts`
have no remaining consumer.

`web/app/i18n/en.ts:1` also has a stray unused import:
`import { video } from "framer-motion/client"`.

`web/app/resources/page-old.tsx` is a retired pre-Supabase page kept for reference.
It is not routable but is still type-checked and bundled into lint runs.

---

## 7. 🟡 Domain inconsistency

The site's canonical domain is `https://ss.efsu-uom.lk`
([layout.tsx](../web/app/layout.tsx), [sitemap.ts](../web/app/sitemap.ts),
`web/public/robots.txt`), but the JSON-LD block in
[app/page.tsx](../web/app/page.tsx) declares `"url": "https://soyurusathkara.com"`.
Search engines get two different canonical claims.

---

## 8. 🟡 Incomplete SEO setup

Flagged in the original README and still open:

- No OG image — the `images` arrays in both `openGraph` and `twitter` are
  commented out in `layout.tsx`, as is the `icons.icon` entry, even though
  `web/app/favicon.ico` exists.
- `web/app/sitemap.ts` lists only four URLs.

---

## 9. 🟡 Content gaps in the database seed

Carried over from [`supabase/README.md`](../supabase/README.md):

- Theory notes are not seeded (no `web/public/files/theory/`, placeholder video IDs).
  Rows sit commented at the bottom of the seed.
- `prospectus.pdf`, `annual-report-2024.pdf` and `student-handbook-2025.pdf` are
  all exactly 13,179 bytes — byte-identical placeholder stubs.
- Two papers legitimately have no discussion videos (Hard Level, Medium Level
  Tamil).
- Only Mathematics is seeded; Biology / Physics / Chemistry subject rows are
  commented out.

---

## 10. 🟡 Admin panel functional gaps

- No delete or edit for papers (videos can be deleted; nothing can be edited).
- Deleting a paper row would not remove its file from Storage.
- `login` redirects to `/admin/login?error=true` on failure, but the login page
  never reads or displays that parameter.
- Errors surface as thrown exceptions — no toast or inline form feedback.
- `web/app/admin/*` sits inside the root layout, so the public `Navbar` and `Footer`
  render on every admin page alongside the admin sidebar.

---

## 11. 🔴 No PDFs are uploaded to Storage — every download 404s

Confirmed live via the Supabase MCP server. All six `papers` rows carry a
`storage_path`; the `resources` bucket contains **zero objects**.

```
papers/Easy-Level.pdf            6.7 MB   missing
papers/Easy-paper-tamil.pdf      754 KB   missing
papers/Hard-Level.pdf            8.4 MB   missing
papers/Medium_paper_tamil.pdf    459 KB   missing
papers/Medium-Level.pdf          8.6 MB   missing
short-notes/Short-Note.pdf       8.2 MB   missing
```

Everything else in the backend is provisioned: all 7 tables, all 9 RLS
policies, the profile trigger, and the bucket itself (public, 50 MB,
`application/pdf`). The seed ran correctly — `subjects 1 · units 3 · papers 6 ·
videos 53`, exactly the documented expectation.

Fix — from the **repo root**, not `web/`:

```powershell
$env:SUPABASE_URL = "https://atvpbxxzpnhjtsuuzmfu.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "<service_role key>"
node scripts/upload_pdfs.mjs
```

The script verifies each file's size against `size_bytes` in the seed before
uploading; all six currently match.

> The stale "tables not created" table in [`supabase/README.md`](../supabase/README.md)
> predates the admin panel and is wrong. It should be deleted.

---

## 12. 🟠 Schema drift — `admins` exists in the database but in no migration

The `admins` table was created through the dashboard and is not in
`supabase/migrations/`:

```sql
admins ( id uuid not null references auth.users,
         email text not null,
         created_at timestamptz default now() )
policy "admins read own"  for select using (auth.uid() = id)
```

One row, matching the single auth user. The admin guard added in issue 2 depends
on it, so it needs to be written into a migration —
`supabase/migrations/005_admins.sql` — or a fresh environment will provision a
database the app cannot authenticate against.

Related: `list_migrations` returns empty, because every migration was pasted
into the SQL Editor rather than applied through the CLI. That is the documented
workflow, but it means no drift detection — which is exactly how this table
slipped in unrecorded.

Also worth fixing while you are there, from `get_advisors`:

- `touch_updated_at` has a mutable `search_path` (001 sets it on
  `handle_new_user` but not on this one).
- `handle_new_user()` is `SECURITY DEFINER` and callable by `anon` and
  `authenticated` via `/rest/v1/rpc/handle_new_user`. Low exploitability — it is
  a trigger function and errors on `new` outside a trigger — but
  `revoke execute … from anon, authenticated` is the right hygiene.
- Leaked-password protection is disabled in Auth settings. Worth enabling, since
  admin login is email + password.

---

## 13. 🟢 Smaller notes

- **Tamil terminology** — the website renders "discussion" as **சர்ச்சை**
  (*controversy*). The Flutter app corrected this to **கலந்துரையாடல்**; the
  website has not been updated.
- **Language flash** — `LanguageProvider` defaults to `en` and only reads
  `localStorage` in an effect, so a Sinhala or Tamil user may see one English
  frame. The Flutter app avoids this by awaiting `SharedPreferences` before
  `runApp`.
- **`SchoolsOutreach`** is fully built but commented out of
  [`web/app/page.tsx`](../web/app/page.tsx), along with its `ErrorBoundary` and skeleton.
- **Hash-link placeholders** — the footer still has `href="#"` for Videos, Notes,
  Short Notes, Privacy and Terms.
- **`Card` uses `alert()`** for download failures — acceptable, but a toast would
  match the rest of the UI.
- **`Navbar` scroll detection** walks the DOM with
  `document.querySelector('section')?.nextElementSibling?.…` four levels deep to
  find the outreach section. That breaks the moment a section is added, removed
  or reordered — which has already happened, since `SchoolsOutreach` is
  commented out. An `id` and `getElementById` would be sturdier.
- **`supabase/build_run_all.py`** parses the existing `RUN_ALL.sql` header by
  splitting on a literal string, so it must be run from the repo root and the
  header format must not change.
