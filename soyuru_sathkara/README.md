# Soyuru Sathkara — Flutter app

Free video lessons, papers and notes for Sri Lankan G.C.E. O/L students.
Trilingual: Sinhala, English, Tamil.

## Run it

The backend must be set up first — see [`../supabase/README.md`](../supabase/README.md).

```powershell
flutter pub get
flutter run
```

No `--dart-define` needed. The Supabase **publishable key** is bundled in
`lib/core/env.dart`, which is how publishable keys are meant to be used: the key
grants nothing by itself, and the RLS policies in
`../supabase/migrations/002_rls_policies.sql` are what actually protect the data.

That is *not* true of the **service_role** key, which bypasses RLS completely.
It must never appear in this app — it is only used by
`../scripts/upload_pdfs.mjs`, from a shell.

To target a different project (e.g. a Supabase branch):

```powershell
flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=<key> --dart-define=SUPABASE_URL=<url>
```

⚠ Never pass `--dart-define=SUPABASE_ANON_KEY=$env:SOMETHING` when the variable
is unset — an empty define overrides the bundled key and the app boots to the
config error screen. `.vscode/launch.json` deliberately passes no defines.

## Who owns what

Never edit inside the other person's `features/` folder without asking.

| Path | Owner |
| --- | --- |
| `lib/features/home/`, `subject/`, `units/`, `player/` | **Dev A** — video side |
| `lib/repositories/video_repository.dart` | **Dev A** |
| `lib/features/papers/`, `pdf_viewer/`, `profile/` | **Dev B** — documents side |
| `lib/repositories/paper_repository.dart` | **Dev B** |
| `lib/core/`, `lib/models/`, `lib/services/`, `router.dart`, `app.dart`, `l10n/` | **SHARED** — announce before changing |
| `pubspec.yaml` | **SHARED** — announce before adding a dependency |

`SubjectScreen` is a shell owned by Dev A; its two tab bodies are `UnitListView`
(Dev A) and `PapersListView` (Dev B). Neither dev needs to touch the shell to
work on their tab.

One deliberate cross-boundary call: the Papers screen shows "N discussions" and
opens a discussion list. Those are `videos` queries, so they live in
`VideoRepository` (`getVideosForPaper`, `getVideoCountsByPaper`) and Dev B calls
them, rather than a second differently-shaped videos query appearing in
`PaperRepository`.

## Decisions made in Phase 0

- **State management: Riverpod.** The plan left this open; it is decided.
- **Auth: anonymous by default.** Watch progress is keyed on `auth.uid()`, so a
  session must exist — but putting a signup wall in front of a free app for
  underprivileged students would be the wrong trade. Email sign-in is optional
  and only buys cross-device sync. Signing up from an anonymous session
  *upgrades* the same user id, so existing progress is kept.
- **PDF storage: public bucket.** Reasoning in `supabase/migrations/004_storage.sql`.
- **PDFs render from a local file, never streamed.** Downloading is what makes a
  paper readable offline; streaming an 8 MB file on every open would not be.
- **No custom font.** Roboto has no Sinhala or Tamil glyphs. Leaving
  `fontFamily` null lets Android resolve Noto Sans Sinhala/Tamil. If you ever
  bundle a font, you must bundle all three scripts or two thirds of the app
  renders as tofu boxes.

## Localisation

ARB files are in `l10n/` at the project root, so the content team can edit them
without touching Dart. `flutter gen-l10n` regenerates `lib/l10n/` (a normal
`flutter run` does it too).

Strings that also exist on the website were copied verbatim from
`app/i18n/{si,ta}.ts` so both products read the same. Everything else was
written for the app and is flagged in each ARB header as **needing a
native-speaker review before release** (plan Step 5).

One correction was made rather than copied: the website renders "discussion" in
Tamil as **சர்ச்சை**, which means *controversy*. The app uses
**கலந்துரையாடல்**. The website still has the wrong word.

## Tests

```powershell
flutter test
```

Covers the pure logic that is easy to get subtly wrong — trilingual fallback,
progress fractions with a null duration, empty-unit division, colour parsing
from free-text database values. There are no widget tests: every screen talks to
Supabase, and mocking the whole client to assert almost nothing is not worth it.

## Not built (deliberately out of v1 scope)

Search, admin panel, push notifications, bookmarks, notes. The plan calls these
out as v2; the schema has no tables for them.
