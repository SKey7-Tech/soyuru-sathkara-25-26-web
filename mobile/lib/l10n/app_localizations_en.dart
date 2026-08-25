// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Soyuru Sathkara';

  @override
  String get appTagline => 'Education Beyond Boundaries';

  @override
  String get navHome => 'Home';

  @override
  String get navPapers => 'Papers';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeSubtitle => 'Free video lessons, papers and notes';

  @override
  String get homeSubjects => 'Subjects';

  @override
  String get homeContinueWatching => 'Continue watching';

  @override
  String get subjectTabVideos => 'Videos';

  @override
  String get subjectTabPapers => 'Papers';

  @override
  String get unitsTitle => 'Lesson units';

  @override
  String unitVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
      zero: 'No videos',
    );
    return '$_temp0';
  }

  @override
  String unitCompletedOf(int done, int total) {
    return '$done of $total watched';
  }

  @override
  String get playerUpNext => 'Up next';

  @override
  String get playerRelatedVideos => 'Related video lessons';

  @override
  String get playerMarkComplete => 'Mark as watched';

  @override
  String get playerMarkedComplete => 'Watched';

  @override
  String get playerOpenInYouTube => 'Open in YouTube';

  @override
  String playerVideoOf(int index, int total) {
    return 'Video $index of $total';
  }

  @override
  String get playerNext => 'Next';

  @override
  String get playerPrevious => 'Previous';

  @override
  String get playerProgressSaved => 'Progress saved';

  @override
  String get papersSubtitle => 'Download exam papers and practice questions';

  @override
  String get filterAll => 'All';

  @override
  String get filterYear => 'Year';

  @override
  String get filterMedium => 'Medium';

  @override
  String get filterType => 'Type';

  @override
  String get filterClear => 'Clear filters';

  @override
  String get paperTypePast => 'Past paper';

  @override
  String get paperTypeModel => 'Practice paper';

  @override
  String get paperTypeTerm => 'Term test';

  @override
  String get paperTypeNotes => 'Notes';

  @override
  String get mediumSi => 'Sinhala';

  @override
  String get mediumEn => 'English';

  @override
  String get mediumTa => 'Tamil';

  @override
  String get paperWithAnswers => 'With answers';

  @override
  String get paperSeeVideos => 'See videos';

  @override
  String paperDiscussionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count discussions',
      one: '1 discussion',
      zero: 'No discussions',
    );
    return '$_temp0';
  }

  @override
  String get actionDownload => 'Download';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionDownloadAgain => 'Download again';

  @override
  String downloadProgress(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get downloadStarting => 'Starting download…';

  @override
  String get downloadComplete => 'Downloaded';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get downloadNeedsConnection =>
      'You need an internet connection to download this paper.';

  @override
  String pdfPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get pdfOpenFailed =>
      'This PDF could not be opened. It may not have finished downloading.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileStudent => 'Student';

  @override
  String get profileGuest => 'Guest';

  @override
  String get profileGuestExplainer =>
      'You are browsing as a guest. Your progress is saved on this phone only — sign in to keep it if you change phones.';

  @override
  String profileSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileMyDownloads => 'My downloads';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignOutConfirm =>
      'Sign out of this account? Guest progress on this phone is kept.';

  @override
  String get profileSaved => 'Saved';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authNoAccount => 'No account yet?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authWhySignIn =>
      'Signing in keeps your watch progress and downloads if you change phones. It is optional.';

  @override
  String get authInvalidEmail => 'Enter a valid email address';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get authCheckEmail => 'Check your email to confirm your account.';

  @override
  String get downloadsTitle => 'My downloads';

  @override
  String get downloadsEmptyTitle => 'No downloads yet';

  @override
  String get downloadsEmptyMessage =>
      'Papers you download appear here so you can read them without internet.';

  @override
  String get downloadsOnThisPhone => 'Saved on this phone';

  @override
  String get downloadsNotOnThisPhone => 'Not on this phone';

  @override
  String get downloadsRemove => 'Remove from phone';

  @override
  String get downloadsRemoved => 'Removed from this phone';

  @override
  String get emptyNoSubjectsTitle => 'No subjects yet';

  @override
  String get emptyNoSubjectsMessage =>
      'Study material has not been published yet. Please check back soon.';

  @override
  String get emptyNoVideosTitle => 'No videos yet';

  @override
  String get emptyNoVideosMessage =>
      'Discussion videos for this paper have not been published yet.';

  @override
  String get emptyNoPapersTitle => 'No papers found';

  @override
  String get emptyNoPapersMessage => 'No papers match these filters.';

  @override
  String get emptyNoProgressMessage =>
      'Videos you start watching will appear here.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonOk => 'OK';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNoConnection => 'No internet connection';

  @override
  String get errorConfigMissingTitle => 'App not configured';
}
