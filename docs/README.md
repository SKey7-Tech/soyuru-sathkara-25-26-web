# Soyuru Sathkara — Documentation

Free trilingual (Sinhala / English / Tamil) learning resources for Sri Lankan
G.C.E. students, built by the EFSU team at the University of Moratuwa.

The repository holds **three products that share one backend**:

| Product | Path | Stack |
| --- | --- | --- |
| Public website | [`web/app/`](../web/app/) | Next.js 16 (App Router), React 19, Tailwind 4 |
| Admin panel | [`web/app/admin/`](../web/app/admin/) | Next.js Server Actions + Supabase service role |
| Mobile app | [`mobile/`](../mobile/) | Flutter 3.13+, Riverpod, go_router |
| Backend | [`supabase/`](../supabase/) | Postgres + RLS + Storage (no custom server) |

## Read in this order

| # | Document | What it covers |
| --- | --- | --- |
| 1 | [architecture.md](architecture.md) | How the four pieces fit together, data flow, trust model |
| 2 | [setup.md](setup.md) | Getting the website, app and database running locally |
| 3 | [database.md](database.md) | Tables, RLS policies, Storage bucket, seed data |
| 4 | [web-app.md](web-app.md) | Routes, components, i18n, SEO, animations |
| 5 | [admin-panel.md](admin-panel.md) | Content upload flows and their server actions |
| 6 | [mobile-app.md](mobile-app.md) | Flutter screens, repositories, models, offline behaviour |
| 7 | [known-issues.md](known-issues.md) | **Read before running** — what is broken or missing today |
| 8 | [roadmap.md](roadmap.md) | What to build next, and what was deferred on purpose |

## The one-paragraph version

There is no application server. Postgres *is* the backend. Both the website and
the Flutter app talk to Supabase directly with a publishable (anon) key, so the
RLS policies in [`supabase/migrations/002_rls_policies.sql`](../supabase/migrations/002_rls_policies.sql)
are the only thing protecting data. Content (papers, videos, notes) lives in
Postgres; the PDF files live in a public Storage bucket called `resources`;
YouTube hosts the video content and the database only stores the 11-character
video IDs.
