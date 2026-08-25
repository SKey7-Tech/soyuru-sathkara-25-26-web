# Admin panel

Lives at `/admin`, inside the same Next.js app. It is the only way content
reaches the database outside of the SQL seed.

## Access control

Two independent checks, because the panel runs under the service_role key and an
unauthenticated request reaching it can upload and delete content.

**Layer 1 — the proxy.** [`web/app/utils/supabase/middleware.ts`](../web/app/utils/supabase/middleware.ts)
redirects any `/admin/*` request without a session to `/admin/login`, carrying
`?redirectedFrom=`. A signed-in user who lands on the login page is sent on to
`/admin`. Refreshed auth cookies are copied onto both redirects — dropping them
would silently sign the user out on the next request.

**Layer 2 — the layout.** Being signed in is not the same as being an admin.
[`web/app/admin/(panel)/layout.tsx`](<../web/app/admin/(panel)/layout.tsx>) queries the
`admins` table using the **cookie-bound** client, so the `admins read own` policy
(`auth.uid() = id`) does the enforcing: a non-admin's query returns no row no
matter what they send. No row redirects to `/`.

### Why the route group

The login page lives at `app/admin/login/`, *outside* the `(panel)` group. If it
sat inside the guarded layout, an unauthenticated visit would redirect to a page
that redirects again, forever.

Route groups do not affect URLs — `/admin/papers` is still `/admin/papers`.
`actions.ts` sits inside the group too, which keeps the `from '../actions'`
imports in the pages valid.

```
app/admin/
├── login/            ← NOT guarded (page.tsx, actions.ts)
└── (panel)/          ← guarded by layout.tsx
    ├── layout.tsx    sidebar + requireAdmin()
    ├── page.tsx      dashboard
    ├── actions.ts    uploadPaper, uploadVideo, deleteVideo
    ├── papers/
    └── videos/
```

Admin accounts are ordinary Supabase Auth users **plus** a row in `admins`.
Create the user in the Dashboard under Authentication → Users, then insert the
matching row. Note `admins` is not yet in any migration — see
[known-issues.md](known-issues.md) issue 12.

## Pages

| Route | File | Rendering |
| --- | --- | --- |
| `/admin` | [(panel)/page.tsx](<../web/app/admin/(panel)/page.tsx>) | Dynamic — dashboard with two links |
| `/admin/papers` | [(panel)/papers/page.tsx](<../web/app/admin/(panel)/papers/page.tsx>) | Dynamic — upload form + list of all papers |
| `/admin/videos` | [(panel)/videos/page.tsx](<../web/app/admin/(panel)/videos/page.tsx>) | Dynamic — add form + 50 most recent videos |
| `/admin/login` | [login/page.tsx](../web/app/admin/login/page.tsx) | Static — email + password sign-in |

The three panel routes are dynamic rather than static because the guard calls
`cookies()`, which opts them out of static generation. That is also why a
production build succeeds with an empty `SUPABASE_SERVICE_ROLE_KEY` — they are
never prerendered.

[`(panel)/layout.tsx`](<../web/app/admin/(panel)/layout.tsx>) provides the sidebar shell
(Dashboard / Papers & PDFs / YouTube Videos / Back to Site). Note it sits *inside*
the root layout, so the public `Navbar` and `Footer` also render on admin pages.

## Supabase clients

Three clients plus a shared env reader, used deliberately:

| Helper | Used by | Key |
| --- | --- | --- |
| [`client.ts`](../web/app/utils/supabase/client.ts) | Public `/resources/*` pages (browser) | anon |
| [`server.ts`](../web/app/utils/supabase/server.ts) | `login` action, the admin guard | anon, cookie-bound — RLS applies |
| [`admin.ts`](../web/app/utils/supabase/admin.ts) | Admin pages and content actions | **service_role** — RLS bypassed |
| [`env.ts`](../web/app/utils/supabase/env.ts) | All three | — reads the vars, naming any that is missing |

Picking the wrong one is the easy mistake here. The guard deliberately uses the
**cookie-bound** client, not the service_role one: with service_role, RLS is
bypassed and the `admins` lookup would succeed for anybody.

`createAdminClient()` bypasses RLS. It must only ever be called from server
components and server actions — never imported into a `"use client"` file, or
the key ends up in the browser bundle.

## Server actions

All in [`(panel)/actions.ts`](<../web/app/admin/(panel)/actions.ts>) (`'use server'`).

### `uploadPaper(formData)`

Fields: `title`, `title_si`, `title_ta`, `subject_id`, `year`, `paper_type`,
`medium`, `file`.

1. Rejects a missing file.
2. Builds `storage_path` as `<folder>/<Date.now()>-<file.name>`, where folder is
   `theory` when `paper_type === 'notes'` and `papers` otherwise. The timestamp
   prefix avoids collisions on the `storage_path` unique constraint.
3. Uploads to the `resources` bucket.
4. Inserts into `papers` with `size_bytes` from the file and `has_answers: false`.
5. `revalidatePath('/resources/[slug]', 'page')` and `revalidatePath('/admin/papers')`.

> Note the folder choice means short notes uploaded through this form land under
> `theory/`, not `short-notes/` — the form has no way to distinguish them, since
> both are `paper_type = 'notes'`.

### `uploadVideo(formData)`

Fields: `unit_id`, `paper_id` (optional), `youtube_video_id` (exactly 11 chars,
enforced by the input's `minLength`/`maxLength`), `title`, `order_index`.

Derives `thumbnail_url` as `https://i.ytimg.com/vi/<id>/hqdefault.jpg`, inserts
into `videos`, then revalidates the resource pages and `/admin/videos`.

Linking a video to a paper is what makes it appear as a "discussion" on that
paper's card, on both the website and the app.

### `deleteVideo(formData)`

Takes `id`, deletes from `videos`, revalidates. Invoked from
[`DeleteVideoButton`](<../web/app/admin/(panel)/videos/DeleteVideoButton.tsx>), a small client
component that wraps the action in a form with a confirmation.

There is no delete action for papers, and no edit action for either — the panel
is create/read/delete-videos only.

### `login(formData)` — [app/admin/login/actions.ts](../web/app/admin/login/actions.ts)

Calls `supabase.auth.signInWithPassword`, redirects to `/admin/login?error=true`
on failure (the page does not yet render that error), then `revalidatePath('/', 'layout')`
and redirects to `/admin`.

Admin accounts are ordinary Supabase Auth users — create them in the Supabase
Dashboard under Authentication → Users. There is no role column and no
`is_admin` check anywhere.

## Error handling

Every action logs to the server console and throws a generic `Error`, which
surfaces as the Next.js error overlay in development and a 500 in production.
There is no toast or inline form feedback yet.

## Adding a field

1. Add the column in a new `supabase/migrations/00N_*.sql`.
2. Add the input to the form in the relevant admin page.
3. Read it from `formData` in the action and include it in the insert.
4. Add it to the query in the corresponding `/resources/*` page and to the Dart
   model + `_columns` list in the Flutter repository if the app needs it.
