import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/widgets/app_shell.dart';
import 'features/home/home_screen.dart';
import 'features/papers/papers_screen.dart';
import 'features/pdf_viewer/pdf_viewer_screen.dart';
import 'features/player/player_screen.dart';
import 'features/profile/downloads_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/subject/subject_screen.dart';
import 'features/units/playlist_screen.dart';

/// SHARED — frozen after Phase 0. Announce in chat before changing.
///
/// Route names are used with context.pushNamed / goNamed so no screen has to
/// build a path string by hand.
class Routes {
  const Routes._();

  static const home = 'home';
  static const subject = 'subject';
  static const playlist = 'playlist';
  static const player = 'player';
  static const papers = 'papers';
  static const pdfViewer = 'pdfViewer';
  static const profile = 'profile';
  static const downloads = 'downloads';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // ---------------------------------------------------------------
      // The three bottom-nav tabs, each with its own navigation stack.
      // ---------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // ---- Tab 1: Home — DEV A ----
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: Routes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'subject/:subjectId',
                    name: Routes.subject,
                    builder: (context, state) => SubjectScreen(
                      subjectId: state.pathParameters['subjectId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'unit/:unitId',
                        name: Routes.playlist,
                        builder: (context, state) => PlaylistScreen(
                          unitId: state.pathParameters['unitId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ---- Tab 2: Papers — DEV B ----
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/papers',
                name: Routes.papers,
                // No subjectId: the global tab lists every subject's papers.
                builder: (context, state) => const PapersScreen(),
              ),
            ],
          ),

          // ---- Tab 3: Profile — DEV B ----
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'downloads',
                    name: Routes.downloads,
                    builder: (context, state) => const DownloadsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ---------------------------------------------------------------
      // Full-screen routes, deliberately OUTSIDE the shell.
      //
      // Both of these are content-immersive: a bottom navigation bar under a
      // video player or a PDF page is wasted vertical space on a 5-inch phone,
      // and it invites a mis-tap that throws away the student's place.
      // ---------------------------------------------------------------
      GoRoute(
        path: '/unit/:unitId/video/:videoId',
        name: Routes.player,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PlayerScreen(
          unitId: state.pathParameters['unitId']!,
          videoId: state.pathParameters['videoId']!,
        ),
      ),
      GoRoute(
        path: '/paper/:paperId/view',
        name: Routes.pdfViewer,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PdfViewerScreen(
          paperId: state.pathParameters['paperId']!,
        ),
      ),
    ],
  );
}
