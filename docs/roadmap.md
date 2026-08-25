# Roadmap

What to build next, why, and what was deliberately left out.

This is the forward-looking companion to [known-issues.md](known-issues.md).
Rough rule: if something is *broken*, it belongs there; if something *does not
exist yet*, it belongs here. Items marked **(repo)** are already named as
deferred somewhere in the codebase — they are commitments, not suggestions.
Everything else is a recommendation.

---

## Now — blocking a real launch

### 1. Upload the PDFs

The single highest-impact item. Six `papers` rows point at storage paths that
hold no file, so **every download button on both the website and the app 404s**.
The script is written and the sizes check out; it needs one shell command with
the service_role key. Details in [known-issues.md](known-issues.md) issue 11.

Until this is done the product does not do the main thing it claims to do.

### 2. Write `admins` into a migration **(repo)**

The admin guard depends on a table that exists only in the live database. A
fresh environment — a Supabase branch, a rebuild, a new deployment — provisions
a schema the panel cannot authenticate against. Add
`supabase/migrations/005_admins.sql`, and fold in the three advisor fixes while
you are there (see [known-issues.md](known-issues.md) issue 12).

### 3. Separate short notes from theory notes

Both pages currently query `paper_type = 'notes'` and render identical lists,
and `uploadPaper` files every note under `theory/` regardless. This is a schema
gap, not a UI bug: there is no value in the `paper_type` check constraint that
distinguishes them.

Pick one and apply it in all four places — the constraint, `uploadPaper`'s folder
logic, both resource pages, and the Flutter `PaperType` enum:

- add a `note_kind` column (`short` | `theory`), or
- extend `paper_type` with `'short_notes'`.

### 4. Finish the SEO setup **(repo)**

Named as pending in the original README and still open: create an OG image and
uncomment the `openGraph.images` / `twitter.images` / `icons.icon` entries in
`layout.tsx`; extend `sitemap.ts` beyond its four URLs; and settle on one
canonical domain — the JSON-LD block still says `soyurusathkara.com` while
everything else says `ss.efsu-uom.lk`.

---

## Next — content and reach

### 5. Seed the remaining subjects **(repo)**

Only Mathematics has real content. Biology, Physics and Chemistry rows sit
commented at the bottom of the seed, waiting on PDFs that do not exist
(`public/files/theory/` was never created) and on real video IDs — the three
theory entries all share one placeholder. The app and site are both built to
handle N subjects; they are waiting on content, not code.

### 6. Ship the Schools Outreach section

Fully built in `web/app/components/SchoolsOutreach.tsx`, with translations,
images in `public/schoolOutreach/`, and a loading skeleton — and commented out of
`app/page.tsx`. Either finish the "Register Your School" flow behind it or
delete the component; leaving working code commented out invites someone to
delete the wrong half.

Note the `Navbar` scroll detection currently walks
`document.querySelector('section')?.nextElementSibling?.…` four levels deep to
find this section. Give it an `id` before re-enabling, or the highlight logic
will land on the wrong element.

### 7. About and Contact pages

The nav and footer point at `efsu-uom.lk/about` and `/contact` — off-site. The
original README lists both as pages to be implemented here. Decide deliberately:
owning them helps SEO and keeps students on the site; linking out is less to
maintain. Either way, remove the remaining `href="#"` placeholders in the footer
(Videos, Notes, Short Notes, Privacy, Terms).

### 8. Fix the Tamil "discussion" term on the website **(repo)**

The site renders *discussion* as **சர்ச்சை**, which means *controversy*. The
Flutter app already corrected this to **கலந்துரையாடல்**. One-word fix in
`web/app/i18n/ta.ts`, and the two products stop disagreeing.

---

## Admin panel maturity

The panel is create-only today. In rough priority:

| Gap | Why it matters |
| --- | --- |
| No edit for papers or videos | A typo in a trilingual title currently means delete-and-re-upload, and deleting a paper is not possible either |
| No delete for papers | Only videos can be deleted |
| Orphaned storage objects | Deleting a paper row would leave its PDF in the bucket forever — delete both, in that order |
| Login errors are invisible | `login` redirects with `?error=true`; the page never reads it |
| No sign-out | Once signed in there is no way out from inside the panel |
| Errors are thrown exceptions | No toast, no inline form feedback |
| Public chrome on admin pages | `app/admin/*` sits inside the root layout, so the public `Navbar` and `Footer` render alongside the admin sidebar |

The last one is worth doing early and is cheap: give the admin section its own
root layout so it stops inheriting the marketing chrome.

---

## Mobile app — deferred v2 scope **(repo)**

`mobile/README.md` names these as deliberately out of v1, and the schema has no
tables for them:

- **Search** — across subjects, units, videos and papers
- **Bookmarks** — save a video or paper for later
- **Notes** — student's own notes against a video or paper
- **Push notifications** — new content alerts

Each needs a table plus RLS policies following the existing per-user pattern
(`using (auth.uid() = user_id) with check (auth.uid() = user_id)`). Bookmarks and
notes are the natural first pair: same shape as `downloads`, and they make the
Profile tab worth visiting.

Also open on mobile:

- **Native-speaker review of the ARB strings.** Every string written for the app
  rather than copied from the website is flagged in its ARB header as needing
  review before release. Treat this as release-blocking for a trilingual product.
- **Widget tests.** Deliberately skipped — every screen talks to Supabase and
  mocking the client to assert little was judged not worth it. If the feature set
  grows, revisit with a fake repository layer rather than a mocked client.

---

## Technical debt worth scheduling

### Retire the legacy `app/data/` files

`web/app/data/*.ts` were the pre-Supabase content source and seeded the database.
They are half-retired: the `/resources/*` pages read from Supabase, but
`app/i18n/en.ts` still imports `papers` and `theory`, so the arrays cannot simply
be deleted. `pdfs.ts` and `shortNotes.ts` already have no consumer.

Untangle the i18n import, then delete all four plus `app/resources/page-old.tsx`.
While they remain, they carry broken paths — a case-mismatched
`Medium-level.pdf` that would 404 on Linux, and six `coverImage` files that do
not exist.

### Migrate `middleware.ts` → `proxy.ts`

Next 16 deprecates the `middleware` file convention; every build and dev boot
warns. It still works, so this is not urgent, but it is a mechanical change:

```powershell
cd web
npx @next/codemod@canary middleware-to-proxy .
```

### Adopt CLI-managed migrations

Every migration so far was pasted into the SQL Editor, so
`supabase_migrations.schema_migrations` is empty and there is no drift
detection — which is precisely how the `admins` table entered the database
unrecorded. Moving to `supabase db push` / `supabase migration new` would make
drift visible. Weigh it against the current workflow's virtue: it needs no local
Docker and no CLI login, which matters for a volunteer team.

### Fix the language flash

`LanguageProvider` defaults to `en` and reads `localStorage` in an effect, so a
Sinhala or Tamil student sees one English frame on every cold load. The Flutter
app avoids this by awaiting `SharedPreferences` before `runApp`. On the web the
equivalent is a cookie read during SSR, or a tiny blocking inline script before
hydration.

---

## Deliberately not planned

Recorded so nobody re-proposes them without new information:

- **A custom API server.** Postgres plus RLS *is* the backend. Adding a server
  would mean re-implementing every policy in
  `002_rls_policies.sql` in application code.
- **A bundled font.** Roboto has no Sinhala or Tamil glyphs. Leaving
  `fontFamily` null lets Android resolve Noto Sans Sinhala/Tamil. Bundling one
  script without the other two renders two thirds of the app as tofu boxes.
- **Signed URLs for the current PDFs.** The content is already public, and a
  signed URL costs a network round trip before the download starts and can
  expire mid-transfer — the wrong failure mode on 2G. If genuinely restricted
  content ever ships (answer sheets released after an exam), flip the bucket to
  private and set `Env.bucketIsPublic = false`; the Dart side already implements
  both paths.
- **A signup wall on the mobile app.** Watch progress needs a session, so
  students are signed in anonymously. Email sign-in stays optional and only buys
  cross-device sync.
