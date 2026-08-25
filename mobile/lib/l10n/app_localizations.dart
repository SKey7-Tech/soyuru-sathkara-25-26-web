import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Soyuru Sathkara'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Education Beyond Boundaries'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPapers.
  ///
  /// In en, this message translates to:
  /// **'Papers'**
  String get navPapers;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free video lessons, papers and notes'**
  String get homeSubtitle;

  /// No description provided for @homeSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get homeSubjects;

  /// No description provided for @homeContinueWatching.
  ///
  /// In en, this message translates to:
  /// **'Continue watching'**
  String get homeContinueWatching;

  /// No description provided for @subjectTabVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get subjectTabVideos;

  /// No description provided for @subjectTabPapers.
  ///
  /// In en, this message translates to:
  /// **'Papers'**
  String get subjectTabPapers;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson units'**
  String get unitsTitle;

  /// No description provided for @unitVideoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No videos} =1{1 video} other{{count} videos}}'**
  String unitVideoCount(int count);

  /// No description provided for @unitCompletedOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} watched'**
  String unitCompletedOf(int done, int total);

  /// No description provided for @playerUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get playerUpNext;

  /// No description provided for @playerRelatedVideos.
  ///
  /// In en, this message translates to:
  /// **'Related video lessons'**
  String get playerRelatedVideos;

  /// No description provided for @playerMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as watched'**
  String get playerMarkComplete;

  /// No description provided for @playerMarkedComplete.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get playerMarkedComplete;

  /// No description provided for @playerOpenInYouTube.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get playerOpenInYouTube;

  /// No description provided for @playerVideoOf.
  ///
  /// In en, this message translates to:
  /// **'Video {index} of {total}'**
  String playerVideoOf(int index, int total);

  /// No description provided for @playerNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get playerNext;

  /// No description provided for @playerPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get playerPrevious;

  /// No description provided for @playerProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress saved'**
  String get playerProgressSaved;

  /// No description provided for @papersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download exam papers and practice questions'**
  String get papersSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filterYear;

  /// No description provided for @filterMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get filterMedium;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filterClear;

  /// No description provided for @paperTypePast.
  ///
  /// In en, this message translates to:
  /// **'Past paper'**
  String get paperTypePast;

  /// No description provided for @paperTypeModel.
  ///
  /// In en, this message translates to:
  /// **'Practice paper'**
  String get paperTypeModel;

  /// No description provided for @paperTypeTerm.
  ///
  /// In en, this message translates to:
  /// **'Term test'**
  String get paperTypeTerm;

  /// No description provided for @paperTypeNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get paperTypeNotes;

  /// No description provided for @mediumSi.
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get mediumSi;

  /// No description provided for @mediumEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get mediumEn;

  /// No description provided for @mediumTa.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get mediumTa;

  /// No description provided for @paperWithAnswers.
  ///
  /// In en, this message translates to:
  /// **'With answers'**
  String get paperWithAnswers;

  /// No description provided for @paperSeeVideos.
  ///
  /// In en, this message translates to:
  /// **'See videos'**
  String get paperSeeVideos;

  /// No description provided for @paperDiscussionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No discussions} =1{1 discussion} other{{count} discussions}}'**
  String paperDiscussionCount(int count);

  /// No description provided for @actionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actionDownload;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @actionDownloadAgain.
  ///
  /// In en, this message translates to:
  /// **'Download again'**
  String get actionDownloadAgain;

  /// No description provided for @downloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String downloadProgress(int percent);

  /// No description provided for @downloadStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting download…'**
  String get downloadStarting;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @downloadNeedsConnection.
  ///
  /// In en, this message translates to:
  /// **'You need an internet connection to download this paper.'**
  String get downloadNeedsConnection;

  /// No description provided for @pdfPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pdfPageOf(int page, int total);

  /// No description provided for @pdfOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'This PDF could not be opened. It may not have finished downloading.'**
  String get pdfOpenFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get profileStudent;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileGuestExplainer.
  ///
  /// In en, this message translates to:
  /// **'You are browsing as a guest. Your progress is saved on this phone only — sign in to keep it if you change phones.'**
  String get profileGuestExplainer;

  /// No description provided for @profileSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String profileSignedInAs(String email);

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileDisplayName;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileMyDownloads.
  ///
  /// In en, this message translates to:
  /// **'My downloads'**
  String get profileMyDownloads;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this account? Guest progress on this phone is kept.'**
  String get profileSignOutConfirm;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileSaved;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUp;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @authWhySignIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in keeps your watch progress and downloads if you change phones. It is optional.'**
  String get authWhySignIn;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account.'**
  String get authCheckEmail;

  /// No description provided for @downloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'My downloads'**
  String get downloadsTitle;

  /// No description provided for @downloadsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get downloadsEmptyTitle;

  /// No description provided for @downloadsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Papers you download appear here so you can read them without internet.'**
  String get downloadsEmptyMessage;

  /// No description provided for @downloadsOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone'**
  String get downloadsOnThisPhone;

  /// No description provided for @downloadsNotOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Not on this phone'**
  String get downloadsNotOnThisPhone;

  /// No description provided for @downloadsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from phone'**
  String get downloadsRemove;

  /// No description provided for @downloadsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from this phone'**
  String get downloadsRemoved;

  /// No description provided for @emptyNoSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get emptyNoSubjectsTitle;

  /// No description provided for @emptyNoSubjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Study material has not been published yet. Please check back soon.'**
  String get emptyNoSubjectsMessage;

  /// No description provided for @emptyNoVideosTitle.
  ///
  /// In en, this message translates to:
  /// **'No videos yet'**
  String get emptyNoVideosTitle;

  /// No description provided for @emptyNoVideosMessage.
  ///
  /// In en, this message translates to:
  /// **'Discussion videos for this paper have not been published yet.'**
  String get emptyNoVideosMessage;

  /// No description provided for @emptyNoPapersTitle.
  ///
  /// In en, this message translates to:
  /// **'No papers found'**
  String get emptyNoPapersTitle;

  /// No description provided for @emptyNoPapersMessage.
  ///
  /// In en, this message translates to:
  /// **'No papers match these filters.'**
  String get emptyNoPapersMessage;

  /// No description provided for @emptyNoProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Videos you start watching will appear here.'**
  String get emptyNoProgressMessage;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoConnection;

  /// No description provided for @errorConfigMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'App not configured'**
  String get errorConfigMissingTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
