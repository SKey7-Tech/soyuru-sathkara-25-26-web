# Admin panel

Lives at `/admin`, inside the same Next.js app. It is the only way content
reaches the database outside of the SQL seed.

> ⚠ **The panel is currently unprotected.** `web/app/admin/layout.tsx` renders its
> children with no session check, and `web/middleware.ts` refreshes the auth cookie
> without redirecting unauthenticated users away from `/admin`. Anyone who knows
> the URL can upload and delete content. See [known-issues.md](known-issues.md)
> for the fix.

## Pages

| Route | File | Rendering |
| --- | --- | --- |
| `/admin` | [app/admin/page.tsx](../web/app/admin/page.tsx) | Static dashboard with two links |
| `/admin/papers` | [app/admin/papers/page.tsx](../web/app/admin/papers/page.tsx) | Server — upload form + list of all papers |
| `/admin/videos` | [app/admin/videos/page.tsx](../web/app/admin/videos/page.tsx) | Server — add form + 50 most recent videos |
| `/admin/login` | [app/admin/login/page.tsx](../web/app/admin/login/page.tsx) | Email + password sign-in |

[`web/app/admin/layout.tsx`](../web/app/admin/layout.tsx) provides the sidebar shell
(Dashboard / Papers & PDFs / YouTube Videos / Back to Site). Note it sits *inside*
the root layout, so the public `Navbar` and `Footer` also render on admin pages.

## Supabase clients

Three different clients, used deliberately:

| Helper | Used by | Key |
| --- | --- | --- |
| `createClient()` from `web/app/utils/supabase/client` | Public `/resources/*` pages (browser) | anon |
| `createClient()` from `web/app/utils/supabase/server` | `login` server action | anon, cookie-bound |
| `createAdminClient()` from `web/app/utils/supabase/admin` | Admin pages and content server actions | **service_role** |

`createAdminClient()` bypasses RLS. It must only ever be called from server
components and server actions — never imported into a `"use client"` file, or
the key ends up in the browser bundle.

## Server actions

All in [`web/app/admin/actions.ts`](../web/app/admin/actions.ts) (`'use server'`).

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
[`DeleteVideoButton`](../web/app/admin/videos/DeleteVideoButton.tsx), a small client
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
