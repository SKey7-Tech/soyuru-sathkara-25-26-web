// Unit tests for the pure logic in lib/models/ and lib/core/.
//
// Deliberately no widget tests here: every screen in this app talks to
// Supabase, and a widget test would need the whole client mocked to assert
// almost nothing. These cover the parts that are easy to get subtly wrong and
// that both devs depend on.
//
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soyuru_sathkara/core/app_language.dart';
import 'package:soyuru_sathkara/core/colors.dart';
import 'package:soyuru_sathkara/models/paper.dart';
import 'package:soyuru_sathkara/models/unit.dart';
import 'package:soyuru_sathkara/models/video.dart';
import 'package:soyuru_sathkara/models/watch_progress.dart';

void main() {
  group('AppColors.fromHex', () {
    test('parses the seeded subject colour', () {
      expect(AppColors.fromHex('#2563EB'), const Color(0xFF2563EB));
    });

    test('accepts a missing leading hash', () {
      expect(AppColors.fromHex('2563EB'), const Color(0xFF2563EB));
    });

    test('falls back instead of throwing on a content-entry typo', () {
      // The column is free text, so a bad value must not take down the whole
      // home screen.
      expect(AppColors.fromHex('not a colour'), AppColors.secondary);
      expect(AppColors.fromHex('#12345'), AppColors.secondary);
      expect(AppColors.fromHex(null), AppColors.secondary);
    });
  });

  group('AppLanguage', () {
    test('codes match the database check constraint', () {
      expect(AppLanguage.values.map((l) => l.code).toList(), ['si', 'en', 'ta']);
    });

    test('unknown code falls back to English', () {
      expect(AppLanguage.fromCode('fr'), AppLanguage.en);
      expect(AppLanguage.fromCode(null), AppLanguage.en);
    });

    test('device locale selects the matching language', () {
      expect(AppLanguage.fromLocale(const Locale('ta')), AppLanguage.ta);
    });
  });

  group('Paper', () {
    Paper build({String? titleSi, String? titleTa}) => Paper(
          id: 'p1',
          subjectId: 's1',
          title: 'Easy Level Paper',
          titleSi: titleSi,
          titleTa: titleTa,
          medium: AppLanguage.si,
          storagePath: 'papers/Easy-Level.pdf',
          sizeBytes: 6680967,
        );

    test('returns the requested translation', () {
      final paper = build(titleSi: 'පහසු මට්ටමේ ප්‍රශ්න පත්‍රය');
      expect(paper.titleFor(AppLanguage.si), 'පහසු මට්ටමේ ප්‍රශ්න පත්‍රය');
    });

    test('falls back to English when a translation is missing or blank', () {
      expect(build().titleFor(AppLanguage.ta), 'Easy Level Paper');
      expect(build(titleTa: '   ').titleFor(AppLanguage.ta), 'Easy Level Paper');
    });

    test('cacheFileName flattens the path and keeps the extension', () {
      // storage_path is unique in the database, so flattening cannot collide.
      expect(build().cacheFileName, 'papers_Easy-Level.pdf');
    });

    test('formattedSize is human readable', () {
      expect(build().formattedSize, '6.4 MB');
    });

    test('paper_type falls back to the column default', () {
      expect(PaperType.fromValue('nonsense'), PaperType.past);
      expect(PaperType.fromValue('notes'), PaperType.notes);
    });
  });

  group('Video', () {
    const video = Video(
      id: 'v1',
      unitId: 'u1',
      youtubeVideoId: 'Dj7ku0IeZN8',
      title: 'Discussion Part 1',
    );

    test('derives a thumbnail when the column is null', () {
      expect(
        video.effectiveThumbnailUrl,
        'https://i.ytimg.com/vi/Dj7ku0IeZN8/hqdefault.jpg',
      );
    });

    test('duration is null for seeded rows, not "0:00"', () {
      // Every seeded video has a null duration_sec, so the UI must handle it.
      expect(video.formattedDuration, isNull);
    });

    test('formats minutes and hours', () {
      expect(
        const Video(
          id: 'v',
          unitId: 'u',
          youtubeVideoId: 'x',
          title: 't',
          durationSec: 605,
        ).formattedDuration,
        '10:05',
      );
      expect(
        const Video(
          id: 'v',
          unitId: 'u',
          youtubeVideoId: 'x',
          title: 't',
          durationSec: 3725,
        ).formattedDuration,
        '1:02:05',
      );
    });
  });

  group('Unit.progress', () {
    Unit build(int videoCount, int completed) => Unit(
          id: 'u1',
          subjectId: 's1',
          titleEn: 'Easy Level Paper — Discussions',
          titleSi: 'si',
          titleTa: 'ta',
          videoCount: videoCount,
          completedCount: completed,
        );

    test('an empty unit is 0, not a division by zero', () {
      // Hard Level and Medium Level (Tamil) really have no videos.
      expect(build(0, 0).progress, 0.0);
      expect(build(0, 0).isComplete, isFalse);
    });

    test('is the completed fraction', () {
      expect(build(20, 5).progress, 0.25);
      expect(build(19, 19).isComplete, isTrue);
    });

    test('clamps if the counts ever disagree', () {
      expect(build(2, 5).progress, 1.0);
    });
  });

  group('WatchProgress', () {
    const progress = WatchProgress(
      userId: 'u',
      videoId: 'v',
      secondsWatched: 30,
      completed: true,
    );

    test('a completed video is a full ring even with no known duration', () {
      // duration_sec is null for every seeded row; without this the progress
      // ring would read 0% on a video the student has finished.
      expect(progress.progressFraction(null), 1.0);
    });

    test('unfinished video with unknown duration reads 0', () {
      expect(
        const WatchProgress(userId: 'u', videoId: 'v', secondsWatched: 30)
            .progressFraction(null),
        0.0,
      );
    });

    test('upsert map omits updated_at so the trigger owns it', () {
      // A phone with a wrong clock must not be able to poison ordering.
      expect(progress.toUpsertMap().containsKey('updated_at'), isFalse);
      expect(progress.toUpsertMap()['seconds_watched'], 30);
    });
  });
}
