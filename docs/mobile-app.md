# Mobile app (Flutter)

Lives in [`mobile/`](../mobile/). Trilingual, offline-tolerant,
talks to the same Supabase project as the website.

Its own [README](../mobile/README.md) carries the team-ownership rules;
this document covers how the code is put together.

## Stack

| Concern | Choice |
| --- | --- |
| State | `flutter_riverpod` ^2.6 |
| Navigation | `go_router` ^17.5 with `StatefulShellRoute.indexedStack` |
| Backend | `supabase_flutter` ^2.17 |
| Video | `youtube_player_iframe` ^6.0 |
| PDF | `syncfusion_flutter_pdfviewer` ^34.2 |
| Downloads | `dio` + `path_provider` |
| Persistence | `shared_preferences` |
| i18n | `flutter_localizations` + ARB (`flutter gen-l10n`) |

## Startup sequence

[`lib/main.dart`](../mobile/lib/main.dart), in order:

1. `Env.isConfigured` check — if the key resolved to an empty string, run
   `ConfigErrorApp` with an explanation instead of crashing deep inside the SDK.
2. `SharedPreferences.getInstance()` — awaited **before** `runApp` so
   `LocaleController.build()` is synchronous and the first frame is already in
   the right language. No English flash for a Sinhala or Tamil student.
3. `initSupabase()`.
4. `ProviderContainer` with `sharedPrefsProvider` overridden.
5. `authService.ensureSession()` — anonymous sign-in. Never throws.
6. `runApp(UncontrolledProviderScope(...))`.

[`lib/app.dart`](../mobile/lib/app.dart) builds `MaterialApp.router`.
The `GoRouter` is a `late final` field, **not** built in `build()` — rebuilding
it would reset the navigation stack. `themeMode` is `system`, matching the
website's `prefers-color-scheme` behaviour.

## Routing

[`lib/router.dart`](../mobile/lib/router.dart). Route names are
constants on `Routes`, used with `pushNamed`/`goNamed` so no screen builds a
path string by hand.

Three bottom-nav branches, each with its own navigation stack:

```
Tab 1  /                                   home
       /subject/:subjectId                 subject
       /subject/:subjectId/unit/:unitId    playlist
Tab 2  /papers                             papers   (global — every subject)
Tab 3  /profile                            profile
       /profile/downloads                  downloads
```

Two full-screen routes sit **outside** the shell on the root navigator:

```
/unit/:unitId/video/:videoId    player
/paper/:paperId/view            pdfViewer
```

Both are content-immersive: a bottom bar under a video player or a PDF page is
wasted vertical space on a 5-inch phone and invites a mis-tap that throws away
the student's place.

## Directory layout

```
lib/
  core/            env, colors, theme, app_language, locale_controller,
                   supabase_client, widgets/ (app_shell, async_view,
                   loading_view, error_view, empty_state, language_picker)
  models/          subject, unit, video, paper, profile, watch_progress,
                   download_record
  repositories/    video_repository.dart, paper_repository.dart
  services/        auth_service.dart
  features/        home/ subject/ units/ player/       (video side)
                   papers/ pdf_viewer/ profile/        (documents side)
  l10n/            generated — do not edit
l10n/              app_en.arb, app_si.arb, app_ta.arb  ← edit these
test/              models_test.dart
```

## Models

Plain immutable classes with `fromMap` constructors — no code generation.

| Model | Notable |
| --- | --- |
| `Subject` | `nameFor(AppLanguage)`; `_icons` maps the DB `icon` string to a `IconData` |
| `Unit` | `titleFor(...)`, plus `videoCount` / `completedCount` filled in by the repository, `copyWith` |
| `Video` | Bare row wrapper; `duration_sec` may be null |
| `Paper` | `PaperType` enum (`past`/`model`/`term`/`notes`) with `fromValue` fallback; `titleFor(...)` falls back to `title`; `cacheFileName` for on-disk storage |
| `Profile` | `displayName`, `medium`, `copyWith` |
| `WatchProgress` | `progressFraction(int? durationSec)` — handles a null duration without dividing by zero |
| `DownloadRecord` | A `downloads` row joined to its paper |

The trilingual fallback (`titleFor` / `nameFor`) is the app-side half of the
nullable `title_si` / `title_ta` decision in the schema.

## Repositories

Both are plain classes wrapping `SupabaseClient`, exposed through Riverpod
providers. Every query is also published as a `FutureProvider` so screens use
`ref.watch` and get loading/error states for free.

### `VideoRepository`

| Method | Purpose |
| --- | --- |
| `getSubjects()` | Ordered by `order_index` |
| `getUnits(subjectId)` | With per-unit video and completed counts |
| `getUnit(unitId)`, `getVideos(unitId)`, `getVideo(videoId)` | |
| `getVideosForPaper(paperId)` | The "discussions for this paper" list |
| `getVideoCountsByPaper()` | The "N discussions" badge |
| `getProgressForUnit(unitId)`, `getProgress(videoId)` | |
| `saveProgress(...)` | Upsert into `watch_progress` |
| `getContinueWatching({...})` | Home-screen resume row |

Providers: `subjectsProvider`, `subjectProvider(id)`, `unitsProvider(subjectId)`,
`unitProvider(id)`, `videosProvider(unitId)`, `videoProvider(id)`,
`unitProgressProvider(unitId)`, `continueWatchingProvider`,
`paperVideoCountsProvider`, `paperVideosProvider(paperId)`.

The last two are the one deliberate cross-boundary call: the Papers screen (owned
by Dev B) uses them rather than a second, differently shaped videos query
appearing in `PaperRepository`.

### `PaperRepository`

| Method | Purpose |
| --- | --- |
| `getPapers([PaperFilter])` | Filters on subject / medium / year / type |
| `getPaper(id)` | |
| `pdfUrl(paper)` | Public URL, or a signed URL when `Env.bucketIsPublic == false` |
| `logDownload(paperId)` | Best effort — the PDF is already on the phone, so a failed log row must not read as a failed download. Returns whether it wrote. |
| `getDownloads()`, `removeDownloadLog(paperId)` | The "My Downloads" screen |

Ordering is `year desc nulls last`, then `title asc` — a stable tiebreaker so the
list does not reshuffle between loads. (`supabase-dart`'s `.order()` defaults to
*descending*, hence the explicit `ascending: true`.)

Filtering state lives in `PaperFilterController` (a `FamilyNotifier` keyed by an
optional subject scope) with `setMedium` / `setYear` / `setType` / `clear`;
`filteredPapersProvider` and `paperFilterOptionsProvider` derive the visible list
and the available filter values from it.

## Auth

[`lib/services/auth_service.dart`](../mobile/lib/services/auth_service.dart).

- **`ensureSession()`** — signs in anonymously if there is no session. Never
  rethrows: everything except progress tracking works without one. On failure it
  logs (under the `AuthService` tag) that anonymous sign-ins are probably
  disabled in the dashboard.
- **`isGuest`** vs **`isAnonymous`** — `isAnonymous` is false when `currentUser`
  is null, so a screen branching on it alone would offer "Sign out" to someone
  with nothing to sign out of. `isGuest` covers both "anonymous" and "no session
  at all", which is reachable whenever `ensureSession` failed.
- **`signUp()`** upgrades an anonymous student with `updateUser` rather than
  `signUp`, keeping the *same* `auth.uid()`. Calling `signUp` would mint a new id
  and orphan every `watch_progress` row they already have.
- **`signOut()`** immediately takes a fresh anonymous session, so the student
  lands on a working app rather than a dead one.

Providers: `authServiceProvider`, `authStateProvider` (stream),
`currentUserIdProvider`, `profileProvider`.

Rationale for anonymous-by-default: watch progress is keyed on `auth.uid()` so a
session must exist, but a signup wall in front of a free app for underprivileged
students would be the wrong trade. Email sign-in is optional and only buys
cross-device sync.

## Localisation

Two-layer language handling.

**Strings** — ARB files in `l10n/` at the Flutter project root (not in `lib/`),
so the content team can edit them without touching Dart. `l10n.yaml` configures
generation into `lib/l10n/`; `flutter gen-l10n` regenerates, and a normal
`flutter run` does it too. Never edit `lib/l10n/*.dart`.

Strings that also exist on the website were copied verbatim from
`web/app/i18n/{si,ta}.ts` so both products read the same. Everything else is flagged
in each ARB header as needing a native-speaker review before release.

One correction was made rather than copied: the website renders "discussion" in
Tamil as **சர்ச்சை**, which means *controversy*. The app uses
**கலந்துரையாடல்**. The website still has the wrong word.

**Current language** — [`LocaleController`](../mobile/lib/core/locale_controller.dart),
stored in two places on purpose:

| Store | Why |
| --- | --- |
| `SharedPreferences` (`app_language`) | Survives restarts, works offline and with no session |
| `profiles.medium` | Follows the student to a new phone once signed in |

The device copy wins on read. The server copy is adopted only when the device has
no stored choice (`adoptFromProfile`, called from an `app.dart` listener on
`profileProvider`) — exactly the "signed in on a new phone" case. The other way
round, a stale server value would silently override a choice just made.

With no stored choice the app follows the phone's own locale rather than
defaulting to English. Syncing the choice to the server is best effort and
swallows its error — a failed sync must not undo a change already on screen.

## PDF caching

[`PdfCacheService`](../mobile/lib/features/pdf_viewer/pdf_cache_service.dart).

- Files go in the **application support** directory, not the cache directory:
  Android may delete the cache dir under storage pressure, and a paper downloaded
  on school wifi must still be there that evening. Support dir is also not
  user-visible, so no storage permission is needed.
- `cachedFile()` treats a **zero-byte file as absent** and deletes it — an
  interrupted write would otherwise hand the viewer an empty file and produce a
  baffling "corrupt document" error instead of "not downloaded yet".
- `download()` writes to a `.part` file and renames only on success, so a
  connection dropping at 80% cannot leave a truncated file that looks ready.
- Progress is reported as `0.0–1.0`, or `null` when the server sends no
  `Content-Length`.

The viewer always renders from a local file, never streams. Downloading is what
makes a paper readable offline; streaming an 8 MB file on every open would not
be.

## Theming

`AppColors` mirrors the website palette (`primary #2563EB`, `secondary #4F46E5`,
`accent #16A34A`, danger, warning, light/dark surfaces and foregrounds), plus
`fromHex()` for parsing free-text `subjects.color_hex` values with a fallback.

**No custom font, deliberately.** Roboto has no Sinhala or Tamil glyphs; leaving
`fontFamily` null lets Android resolve Noto Sans Sinhala/Tamil. If you ever
bundle a font you must bundle all three scripts, or two thirds of the app renders
as tofu boxes.

## Shared UI widgets

`core/widgets/`: `AppShell` (bottom nav around the branch stacks), `AsyncView`
(maps a Riverpod `AsyncValue` onto loading/error/data), `LoadingView`,
`ErrorView`, `EmptyState`, `LanguagePicker`.

## Tests

```powershell
flutter test
```

`test/models_test.dart` covers the pure logic that is easy to get subtly wrong:
trilingual fallback, progress fractions with a null duration, empty-unit
division, colour parsing from free-text database values.

There are no widget tests — every screen talks to Supabase, and mocking the whole
client to assert almost nothing is not worth it.

## Code ownership

From the app README. **Never edit inside the other person's `features/` folder
without asking.**

| Path | Owner |
| --- | --- |
| `features/home/`, `subject/`, `units/`, `player/`, `repositories/video_repository.dart` | **Dev A** — video side |
| `features/papers/`, `pdf_viewer/`, `profile/`, `repositories/paper_repository.dart` | **Dev B** — documents side |
| `core/`, `models/`, `services/`, `router.dart`, `app.dart`, `l10n/`, `pubspec.yaml` | **SHARED** — announce before changing |

`SubjectScreen` is a shell owned by Dev A; its two tab bodies are `UnitListView`
(Dev A) and `PapersListView` (Dev B), so neither dev touches the shell to work on
their tab.

## Out of v1 scope, deliberately

Search, admin panel, push notifications, bookmarks, notes. The schema has no
tables for them.
