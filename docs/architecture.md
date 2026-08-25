# Architecture

## The shape of the system

```
                    ┌──────────────────────────────┐
                    │        SUPABASE PROJECT       │
                    │   ref: atvpbxxzpnhjtsuuzmfu   │
                    │                              │
   publishable      │  Postgres    ── RLS policies │
   (anon) key  ────►│  Auth        ── anon + email │
        │           │  Storage     ── 'resources'  │
        │           └──────────────────────────────┘
        │                    ▲              ▲
        │                    │ service_role │ service_role
        │                    │  (bypasses   │  (bypasses RLS)
        │                    │      RLS)    │
 ┌──────┴───────┐   ┌────────┴───────┐  ┌───┴──────────────────┐
 │  Public web  │   │  Admin panel   │  │ scripts/upload_pdfs  │
 │  app/        │   │  app/admin/    │  │ (one-off, from shell)│
 └──────────────┘   └────────────────┘  └──────────────────────┘
        ▲
        │ publishable key
 ┌──────┴───────┐
 │ Flutter app  │
 │ soyuru_...   │
 └──────────────┘

        YouTube ──► video playback (the DB stores only the 11-char video ID)
```

## Trust model — the thing to get right

There is no Express/Django/Nest layer in front of Postgres. Every authorisation
decision is a Row Level Security policy.

| Key | Where it lives | What it can do |
| --- | --- | --- |
| **Publishable / anon** | Bundled in the Flutter app (`lib/core/env.dart`), shipped to browsers via `NEXT_PUBLIC_*` | Nothing by itself. RLS decides everything. Safe to commit. |
| **service_role** | Server-only env var; the admin panel's server actions and `scripts/upload_pdfs.mjs` | **Bypasses RLS completely.** Never in the Flutter app, never in a browser bundle, never in git. |

Consequences worth internalising:

- All content tables (`subjects`, `units`, `videos`, `papers`) are **publicly
  readable while logged out** — deliberate, so students can browse before ever
  creating an account.
- No client can write to content tables. Writes only happen through the admin
  panel or the seed/upload scripts, both of which use the service_role key.
- Per-user tables (`profiles`, `watch_progress`, `downloads`) are locked to
  `auth.uid()` with both `using` and `with check`.

## Data flow, end to end

**Publishing a paper** (admin panel):
1. Admin submits the form at `/admin/papers`.
2. Server action `uploadPaper` uploads the file into Storage at
   `papers/<timestamp>-<name>.pdf` (or `theory/...` when `paper_type = 'notes'`).
3. It inserts the matching row into `papers` with `storage_path` and `size_bytes`.
4. `revalidatePath` refreshes the public resource pages.

**Reading a paper** (website):
1. `/resources/papers` queries `papers` (with a nested `videos` join) from the
   browser using the anon key.
2. `supabase.storage.from('resources').getPublicUrl(storage_path)` computes the
   download URL client-side — no round trip, because the bucket is public.
3. `Card` fetches the URL as a blob and triggers a browser download.

**Reading a paper** (Flutter):
1. `PaperRepository.getPapers()` → same tables, same anon key.
2. `pdfUrl()` returns a public URL, or a signed URL if `Env.bucketIsPublic` is
   flipped to `false` — both paths are implemented.
3. `PdfCacheService` downloads the file to local storage; the viewer always
   renders from disk, never streams. That is what makes papers work offline.

## Why the two clients don't share code

The website and app share the *database contract*, not code. The contract is:

- the table shapes in `001_init_schema.sql`,
- the trilingual column convention (`*_en` / `*_si` / `*_ta`, falling back to the
  base column when a translation is missing),
- `videos.paper_id` linking a discussion video to the paper it discusses,
- storage paths rooted at `papers/`, `short-notes/`, `theory/`.

Change any of those and both clients need updating. Everything else is local to
one product.

## Historical note: the website predates the database

The website originally shipped its content as hard-coded TypeScript arrays in
[`app/data/`](../app/data/) with PDFs served straight out of `public/files/`.
The Supabase schema was then seeded *from* those files — all 53 YouTube IDs came
out of `app/data/papers.ts`, and all trilingual titles out of `app/i18n/`.

The `/resources/*` pages have since been migrated to query Supabase, but the
`app/data/*.ts` files still exist and are still imported by `app/i18n/en.ts`.
See [known-issues.md](known-issues.md).
