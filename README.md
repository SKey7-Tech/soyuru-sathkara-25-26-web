# Soyuru Sathkara

Free, trilingual (Sinhala / English / Tamil) learning resources for Sri Lankan
G.C.E. students — video lessons, past and model papers, theory and short notes.
Built by the EFSU team at the University of Moratuwa.

**Live site:** https://ss.efsu-uom.lk

## What is in this repository

| Piece | Path | Stack |
| --- | --- | --- |
| Public website | [`web/`](web/) | Next.js 16 (App Router), React 19, Tailwind 4 |
| Admin panel | [`web/app/admin/`](web/app/admin/) | Next.js Server Actions + Supabase service role |
| Mobile app | [`mobile/`](mobile/) | Flutter, Riverpod, go_router |
| Backend | [`supabase/`](supabase/) | Postgres + RLS + Storage — no custom server |
| Shared tooling | [`scripts/`](scripts/) | One-off PDF uploader (service_role, zero deps) |

```
web/        Next.js site + admin      →  npm commands run from here
mobile/     Flutter app               →  flutter commands run from here
supabase/   Shared backend            →  migrations + seed, paste into SQL Editor
scripts/    Shared tooling            →  run from the repo root
docs/       Documentation
```

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
| [docs/roadmap.md](docs/roadmap.md) | What to build next, and what was deferred on purpose |

## Quick start

> `web/.env.local` already has the URL and publishable key. Paste your
> **service_role key** into it before using `/admin`.

```powershell
# 1. Backend — run the migrations in supabase/ (see docs/setup.md)

# 2. Website
cd web
npm install
npm run dev            # http://localhost:3000

# 3. Mobile app
cd ../mobile
flutter pub get
flutter run
```

`web/.env.local` — note it lives in `web/`, not at the repo root:

```ini
NEXT_PUBLIC_SUPABASE_URL=https://atvpbxxzpnhjtsuuzmfu.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_...
SUPABASE_SERVICE_ROLE_KEY=<service_role key>    # server-only, bypasses RLS
```

Scripts, all run from `web/`:

| Script | Does |
| --- | --- |
| `npm run dev` | Dev server |
| `npm run build` / `npm run start` | Production build / serve |
| `npm run lint` | ESLint |
| `npm run analyze` | Bundle analysis |

## Contributing rules

**Every string needs three translations.** Add each new piece of UI text to
`web/app/i18n/en.ts`, `si.ts` **and** `ta.ts`. A missing key renders `undefined`, not
a fallback. For the Flutter app the equivalent files are
`mobile/l10n/app_{en,si,ta}.arb`.

**SEO** — add new public routes to [`web/app/sitemap.ts`](web/app/sitemap.ts), and keep
the domain consistent across `web/app/layout.tsx`, `web/app/sitemap.ts` and
`web/public/robots.txt`.

**Never commit the service_role key.** It bypasses RLS entirely. It belongs in
`.env.local`, in Vercel's environment settings, and in your shell for the length
of `node scripts/upload_pdfs.mjs` — nowhere else. The publishable/anon key is
safe to commit and is deliberately bundled in the Flutter app.

**Flutter code ownership** — the app has a per-developer ownership split; see
[`mobile/README.md`](mobile/README.md) before editing inside
someone else's `features/` folder.

## Open work

Two documents:

- [docs/known-issues.md](docs/known-issues.md) — defects and gaps in what exists.
  The headline item: **no PDFs are uploaded**, so every download 404s.
- [docs/roadmap.md](docs/roadmap.md) — what to build next, and what was
  deliberately deferred.
