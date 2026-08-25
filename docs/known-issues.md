# Known issues & gaps

Verified against the working tree on branch `app-main`. Ordered roughly by
severity.

---

## 1. 🔴 `app/utils/supabase/` is missing — the web app does not build

Eight files import from it; the directory does not exist on disk and is not
tracked by git (`git ls-files app/utils` returns only `animations.ts`).

| Importer | Needs |
| --- | --- |
| [middleware.ts:2](../middleware.ts#L2) | `updateSession` from `app/utils/supabase/middleware` |
| [app/admin/actions.ts:4](../app/admin/actions.ts#L4) | `createAdminClient` from `app/utils/supabase/admin` |
| [app/admin/papers/page.tsx:1](../app/admin/papers/page.tsx#L1) | `createAdminClient` |
| [app/admin/videos/page.tsx:1](../app/admin/videos/page.tsx#L1) | `createAdminClient` |
| [app/admin/login/actions.ts:5](../app/admin/login/actions.ts#L5) | `createClient` from `app/utils/supabase/server` |
| [app/resources/papers/page.tsx:9](../app/resources/papers/page.tsx#L9) | `createClient` from `app/utils/supabase/client` |
| [app/resources/short-notes/page.tsx:9](../app/resources/short-notes/page.tsx#L9) | `createClient` |
| [app/resources/theory/page.tsx:9](../app/resources/theory/page.tsx#L9) | `createClient` |

`@supabase/ssr` and `@supabase/supabase-js` are already in `package.json`, so
only the four helper files are missing. They follow the standard `@supabase/ssr`
Next.js pattern:

- **`client.ts`** — `createBrowserClient(NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY)`.
- **`server.ts`** — `async createClient()` using `createServerClient` with
  `cookies()` from `next/headers` (`getAll` / `setAll`, with the `setAll`
  `try/catch` for Server Components).
- **`middleware.ts`** — `updateSession(request)`: build a `NextResponse`, create
  a server client wired to the request/response cookies, call
  `supabase.auth.getUser()` to refresh the session, return the response. This is
  also the right place to add the admin guard (issue 2).
- **`admin.ts`** — `createClient` from `@supabase/supabase-js` with
  `SUPABASE_SERVICE_ROLE_KEY` and `auth: { autoRefreshToken: false, persistSession: false }`.
  Server-only; never import it from a `"use client"` file.

Environment variables required (see [setup.md](setup.md)):
`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`,
`SUPABASE_SERVICE_ROLE_KEY`.

---

## 2. 🔴 `/admin` has no authentication guard

[`app/admin/layout.tsx`](../app/admin/layout.tsx) renders its children with no
session check, and `middleware.ts` refreshes the auth cookie without redirecting
anyone. A login page exists and works, but nothing requires you to use it —
anyone who knows the URL reaches the upload and delete forms, which run under
the **service_role** key.

Two things to add:

- In `updateSession`, redirect to `/admin/login` when the path starts with
  `/admin` (excluding `/admin/login`) and `supabase.auth.getUser()` returns no
  user.
- A defence-in-depth check in `app/admin/layout.tsx` itself, since middleware
  can be misconfigured.

There is also no notion of an admin *role* — any Supabase Auth user in the
project can sign in. Consider a `profiles.is_admin` column or a dedicated
`admins` table, checked in the layout.

`public/robots.txt` disallows `/api/` but not `/admin`.

---

## 3. 🟠 Short notes and theory pages return identical results

Both query the same thing:

- [app/resources/short-notes/page.tsx:37](../app/resources/short-notes/page.tsx#L37) — `.eq('paper_type', 'notes')`
- [app/resources/theory/page.tsx:38](../app/resources/theory/page.tsx#L38) — `.eq('paper_type', 'notes')`

Both source files carry a comment acknowledging the assumption. The schema's
`paper_type` check constraint has no value that distinguishes short notes from
theory notes, and `uploadPaper` files every `notes` upload under `theory/` in
Storage regardless.

Options: add a `note_kind` column (or extend the `paper_type` check with
`'short_notes'`), or filter on the `storage_path` prefix as an interim measure.
Whichever you pick, update `uploadPaper`'s folder logic and the Flutter
`PaperType` enum together.

---

## 4. 🟠 Broken static asset paths in `app/data/`

These matter only where the legacy data files are still rendered, but they are
wrong today:

- [app/data/papers.ts:66](../app/data/papers.ts#L66) points at
  `/files/papers/Medium-level.pdf`; the file on disk is `Medium-Level.pdf`.
  This works on Windows and breaks on a case-sensitive host (Vercel, Linux).
- Every `coverImage` in `app/data/*.ts` — `paper-cover.jpeg`,
  `handbook-cover.jpg`, `report-cover.jpg`, `prospectus-cover.jpg`,
  `notes-cover.jpg`, `theory-cover.jpg` — is missing. `public/gallery/` contains
  only `ss2.jpg` … `ss8.jpg`.
- `app/data/theory.ts` references `/files/theory/*.pdf`; that directory does not
  exist.

---

## 5. 🟠 `.gitignore` excludes three tracked-worthy directories

```
soyuru_sathkara/     ← the entire Flutter app
supabase/            ← migrations, seed, backend README
scripts/             ← upload_pdfs.mjs
```

They are present in the working tree and referenced throughout the docs, but a
fresh clone would not receive them unless they were force-added. Note the file
also ends without a trailing newline after `scripts/`.

The Flutter entry is presumably there to keep `.dart_tool/` and `build/` out —
those should be ignored specifically (`soyuru_sathkara/.dart_tool/`,
`soyuru_sathkara/build/`), not the whole project. `supabase/` and `scripts/`
appear to be collateral from an earlier "keep the backend out of the web repo"
decision that no longer holds.

Check `git status --ignored` before assuming a file is safe.

---

## 6. 🟡 Legacy data files still wired into i18n

The `/resources/*` pages now read from Supabase, but
[`app/i18n/en.ts`](../app/i18n/en.ts) still imports `papers` from
`app/data/papers.ts` and `theory` from `app/data/theory.ts`, so the hard-coded
arrays cannot simply be deleted. `app/data/pdfs.ts` and `app/data/shortNotes.ts`
have no remaining consumer.

`app/i18n/en.ts:1` also has a stray unused import:
`import { video } from "framer-motion/client"`.

`app/resources/page-old.tsx` is a retired pre-Supabase page kept for reference.
It is not routable but is still type-checked and bundled into lint runs.

---

## 7. 🟡 Domain inconsistency

The site's canonical domain is `https://ss.efsu-uom.lk`
([layout.tsx](../app/layout.tsx), [sitemap.ts](../app/sitemap.ts),
`public/robots.txt`), but the JSON-LD block in
[app/page.tsx](../app/page.tsx) declares `"url": "https://soyurusathkara.com"`.
Search engines get two different canonical claims.

---

## 8. 🟡 Incomplete SEO setup

Flagged in the original README and still open:

- No OG image — the `images` arrays in both `openGraph` and `twitter` are
  commented out in `layout.tsx`, as is the `icons.icon` entry, even though
  `app/favicon.ico` exists.
- `app/sitemap.ts` lists only four URLs.

---

## 9. 🟡 Content gaps in the database seed

Carried over from [`supabase/README.md`](../supabase/README.md):

- Theory notes are not seeded (no `public/files/theory/`, placeholder video IDs).
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
- `app/admin/*` sits inside the root layout, so the public `Navbar` and `Footer`
  render on every admin page alongside the admin sidebar.

---

## 11. 🟢 Smaller notes

- **Tamil terminology** — the website renders "discussion" as **சர்ச்சை**
  (*controversy*). The Flutter app corrected this to **கலந்துரையாடல்**; the
  website has not been updated.
- **Language flash** — `LanguageProvider` defaults to `en` and only reads
  `localStorage` in an effect, so a Sinhala or Tamil user may see one English
  frame. The Flutter app avoids this by awaiting `SharedPreferences` before
  `runApp`.
- **`SchoolsOutreach`** is fully built but commented out of
  [`app/page.tsx`](../app/page.tsx), along with its `ErrorBoundary` and skeleton.
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
