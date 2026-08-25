# Setup & running

> Before you start, read [known-issues.md](known-issues.md). The web app does
> **not** currently build from a clean clone — `web/app/utils/supabase/` is missing
> and has to be recreated. That file explains exactly what to write.

## Prerequisites

| Tool | Version |
| --- | --- |
| Node.js | 18+ (20+ recommended; `scripts/upload_pdfs.mjs` needs built-in `fetch`) |
| Flutter | 3.13+ (Dart SDK `^3.13.0`) |
| Python | 3.x — only to regenerate `supabase/RUN_ALL.sql` |
| Supabase project | ref `atvpbxxzpnhjtsuuzmfu`, or your own |

## 1. Backend first

Everything else fails without it. Full instructions in
[`supabase/README.md`](../supabase/README.md); summary:

Run these in order in the Supabase Dashboard → **SQL Editor**. All are
re-runnable.

| # | File |
| --- | --- |
| 1 | `supabase/migrations/001_init_schema.sql` |
| 2 | `supabase/migrations/002_rls_policies.sql` |
| 3 | `supabase/migrations/003_profile_trigger.sql` |
| 4 | `supabase/migrations/004_storage.sql` |
| 5 | `supabase/seed/001_seed_content.sql` |

Or paste the bundled `supabase/RUN_ALL.sql` (regenerate it with
`python supabase/build_run_all.py` after editing any migration).

The seed ends with a count. Expect: `subjects 1 | units 3 | papers 6 | videos 53`.

Then upload the PDFs — the seed writes `storage_path` values but not the files:

```powershell
$env:SUPABASE_URL = "https://atvpbxxzpnhjtsuuzmfu.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "<service_role key>"   # Settings > API
node scripts/upload_pdfs.mjs
```

The script is dependency-free and refuses to upload if a file's size on disk
disagrees with `size_bytes` in the seed — that catches a PDF being swapped
without the database being updated.

Finally, enable **Authentication → Sign In / Providers → Anonymous sign-ins**.
The Flutter app signs students in anonymously so watch progress works without a
signup wall. If it stays off, browsing works but nothing saves — silently.

## 2. Website

```powershell
cd web
npm install
npm run dev          # http://localhost:3000
```

Create `.env.local` in **`web/`** (next to `package.json`, not at the repo root):

```ini
# Browser-exposed — safe, RLS protects the data
NEXT_PUBLIC_SUPABASE_URL=https://atvpbxxzpnhjtsuuzmfu.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_...

# Server-only. NEVER prefix with NEXT_PUBLIC_. Bypasses RLS.
SUPABASE_SERVICE_ROLE_KEY=<service_role key>
```

`.env*` files are gitignored.

All npm scripts run from `web/`:

| Script | Does |
| --- | --- |
| `npm run dev` | Dev server with hot reload |
| `npm run build` | Production build |
| `npm run start` | Serve a production build |
| `npm run lint` | ESLint (`eslint-config-next`) |
| `npm run analyze` | `ANALYZE=true next build` — bundle inspection |

## 3. Flutter app

```powershell
cd mobile
flutter pub get
flutter run
```

No `--dart-define` needed: the publishable key is bundled in
[`lib/core/env.dart`](../mobile/lib/core/env.dart), which is how
publishable keys are meant to be used.

To target a different project (e.g. a Supabase branch):

```powershell
flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=<key> --dart-define=SUPABASE_URL=<url>
```

⚠ Never pass a define whose environment variable is unset — an empty define
overrides the bundled key and the app boots to the config-error screen.
`.vscode/launch.json` deliberately passes no defines.

Tests: `flutter test` (pure logic only — trilingual fallback, progress fractions
with a null duration, empty-unit division, hex colour parsing).

Localisation: ARB files live in `l10n/` at the Flutter project root so the
content team can edit them without touching Dart. `flutter gen-l10n` regenerates
`lib/l10n/`; a normal `flutter run` does it too.

## 4. Deployment

The site targets **https://ss.efsu-uom.lk** — that domain is hard-coded in
[`web/app/layout.tsx`](../web/app/layout.tsx) (`metadataBase`, canonical, OG),
[`web/app/sitemap.ts`](../web/app/sitemap.ts), and `web/public/robots.txt`. Change all three
together if the domain moves.

Vercel is the assumed host. **Set the project's Root Directory to `web`** —
without that, the build cannot find `package.json` and fails immediately.

Set the three environment variables above in the
project settings; `SUPABASE_SERVICE_ROLE_KEY` must not carry the `NEXT_PUBLIC_`
prefix or it ends up in the client bundle.

`web/next.config.ts` already sets `X-Frame-Options: SAMEORIGIN`,
`X-Content-Type-Options: nosniff`, a `Referrer-Policy`, immutable one-year
caching for images, AVIF/WebP conversion, and strips `X-Powered-By`.

## Repository layout

The two apps are separated; the backend and shared tooling sit at root because
both apps consume them.

```
web/                     Next.js — public website + admin panel
  app/                   App Router
    admin/               Admin panel (service-role writes)
    components/          Shared React components
    contexts/            LanguageContext (en/si/ta, localStorage-backed)
    data/                Legacy hard-coded content — source of the seed
    i18n/                en.ts / si.ts / ta.ts translation dictionaries
    resources/           Public /resources/* pages
    utils/               animations.ts (+ the missing supabase/ helpers)
  public/                Static assets, PDFs, gallery images, robots.txt
  middleware.ts          Supabase session refresh
  package.json           All npm scripts live here — run them from web/
  next.config.ts  tsconfig.json  postcss.config.mjs  eslint.config.mjs

mobile/                  Flutter app (Dart package name: soyuru_sathkara)
  lib/                   core/ models/ repositories/ services/ features/
  l10n/                  app_{en,si,ta}.arb — edit these, not lib/l10n/
  test/

supabase/                Shared backend — migrations, seed, RUN_ALL, README
scripts/upload_pdfs.mjs  One-off PDF uploader (service_role, zero deps)
docs/                    This documentation
```

Two consequences of the split worth remembering:

- **npm commands run from `web/`**, not the repo root.
- **`node scripts/upload_pdfs.mjs` runs from the repo root** — it resolves PDFs
  at `web/public/files/**` relative to the repo, not to `web/`.
