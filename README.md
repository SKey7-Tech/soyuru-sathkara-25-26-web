# Soyuru Sathkara

Free, trilingual (Sinhala / English / Tamil) learning resources for Sri Lankan
G.C.E. students — video lessons, past and model papers, theory and short notes.
Built by the EFSU team at the University of Moratuwa.

**Live site:** https://ss.efsu-uom.lk

## What is in this repository

| Piece | Path | Stack |
| --- | --- | --- |
| Public website | [`app/`](app/) | Next.js 16 (App Router), React 19, Tailwind 4 |
| Admin panel | [`app/admin/`](app/admin/) | Next.js Server Actions + Supabase service role |
| Mobile app | [`soyuru_sathkara/`](soyuru_sathkara/) | Flutter, Riverpod, go_router |
| Backend | [`supabase/`](supabase/) | Postgres + RLS + Storage — no custom server |

There is no application server. Postgres *is* the backend, shared by the website
and the app, and the RLS policies in
[`supabase/migrations/002_rls_policies.sql`](supabase/migrations/002_rls_policies.sql)
are the only thing protecting the data.

## Documentation

Everything lives in [`docs/`](docs/):

| Document | Covers |
| --- | --- |
| [docs/README.md](docs/README.md) | Start here — index and one-paragraph overview |
| [docs/architecture.md](docs/architecture.md) | How the pieces fit together, data flow, trust model |
| [docs/setup.md](docs/setup.md) | Running the website, app and database locally |
| [docs/database.md](docs/database.md) | Tables, RLS, Storage, seed data |
| [docs/web-app.md](docs/web-app.md) | Routes, components, i18n, SEO |
| [docs/admin-panel.md](docs/admin-panel.md) | Content upload flows |
| [docs/mobile-app.md](docs/mobile-app.md) | Flutter screens, repositories, offline behaviour |
| [docs/known-issues.md](docs/known-issues.md) | **Read before running** — what is broken today |

## Quick start

> The web app does **not** build from a clean clone — `app/utils/supabase/` is
> missing. See [issue 1](docs/known-issues.md) for exactly what to recreate.

```powershell
# 1. Backend — run the migrations in supabase/ (see docs/setup.md)

# 2. Website
npm install
npm run dev            # http://localhost:3000

# 3. Mobile app
cd soyuru_sathkara
flutter pub get
flutter run
```

`.env.local` for the website:

```ini
NEXT_PUBLIC_SUPABASE_URL=https://atvpbxxzpnhjtsuuzmfu.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_...
SUPABASE_SERVICE_ROLE_KEY=<service_role key>    # server-only, bypasses RLS
```

| Script | Does |
| --- | --- |
| `npm run dev` | Dev server |
| `npm run build` / `npm run start` | Production build / serve |
| `npm run lint` | ESLint |
| `npm run analyze` | Bundle analysis |

## Contributing rules

**Every string needs three translations.** Add each new piece of UI text to
`app/i18n/en.ts`, `si.ts` **and** `ta.ts`. A missing key renders `undefined`, not
a fallback. For the Flutter app the equivalent files are
`soyuru_sathkara/l10n/app_{en,si,ta}.arb`.

**SEO** — add new public routes to [`app/sitemap.ts`](app/sitemap.ts), and keep
the domain consistent across `app/layout.tsx`, `app/sitemap.ts` and
`public/robots.txt`.

**Never commit the service_role key.** It bypasses RLS entirely. It belongs in
`.env.local`, in Vercel's environment settings, and in your shell for the length
of `node scripts/upload_pdfs.mjs` — nowhere else. The publishable/anon key is
safe to commit and is deliberately bundled in the Flutter app.

**Flutter code ownership** — the app has a per-developer ownership split; see
[`soyuru_sathkara/README.md`](soyuru_sathkara/README.md) before editing inside
someone else's `features/` folder.

## Open work

Tracked in [docs/known-issues.md](docs/known-issues.md). The headline items:
restore `app/utils/supabase/`, put an auth guard in front of `/admin`,
distinguish short notes from theory notes in the schema, and finish the SEO
setup (OG image, sitemap coverage, one canonical domain).
