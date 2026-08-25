// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'சொயுரு சத்காரா';

  @override
  String get appTagline => 'எல்லைகளைக் கடந்த கல்வி';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navPapers => 'தேர்வுத் தாள்கள்';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get homeSubtitle =>
      'இலவச வீடியோ பாடங்கள், தாள்கள் மற்றும் குறிப்புகள்';

  @override
  String get homeSubjects => 'பாடங்கள்';

  @override
  String get homeContinueWatching => 'தொடர்ந்து பார்க்கவும்';

  @override
  String get subjectTabVideos => 'வீடியோக்கள்';

  @override
  String get subjectTabPapers => 'தாள்கள்';

  @override
  String get unitsTitle => 'பாட அலகுகள்';

  @override
  String unitVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count வீடியோக்கள்',
      one: '1 வீடியோ',
      zero: 'வீடியோக்கள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String unitCompletedOf(int done, int total) {
    return '$totalஇல் $done பார்க்கப்பட்டது';
  }

  @override
  String get playerUpNext => 'அடுத்து';

  @override
  String get playerRelatedVideos => 'சம்பந்தப்பட்ட வீடியோ பாடங்கள்';

  @override
  String get playerMarkComplete => 'பார்த்ததாகக் குறிக்கவும்';

  @override
  String get playerMarkedComplete => 'பார்க்கப்பட்டது';

  @override
  String get playerOpenInYouTube => 'YouTube இல் திறக்கவும்';

  @override
  String playerVideoOf(int index, int total) {
    return 'வீடியோ $index / $total';
  }

  @override
  String get playerNext => 'அடுத்து';

  @override
  String get playerPrevious => 'முந்தைய';

  @override
  String get playerProgressSaved => 'முன்னேற்றம் சேமிக்கப்பட்டது';

  @override
  String get papersSubtitle =>
      'தேர்வு தாள்கள் மற்றும் பயிற்சி கேள்விகளை பதிவிறக்கவும்';

  @override
  String get filterAll => 'அனைத்தும்';

  @override
  String get filterYear => 'ஆண்டு';

  @override
  String get filterMedium => 'ஊடகம்';

  @override
  String get filterType => 'வகை';

  @override
  String get filterClear => 'வடிகட்டிகளை அழிக்கவும்';

  @override
  String get paperTypePast => 'கடந்த தாள்';

  @override
  String get paperTypeModel => 'பயிற்சி தாள்';

  @override
  String get paperTypeTerm => 'தவணைத் தேர்வு';

  @override
  String get paperTypeNotes => 'குறிப்புகள்';

  @override
  String get mediumSi => 'சிங்களம்';

  @override
  String get mediumEn => 'ஆங்கிலம்';

  @override
  String get mediumTa => 'தமிழ்';

  @override
  String get paperWithAnswers => 'விடைகளுடன்';

  @override
  String get paperSeeVideos => 'வீடியோக்களைக் காண்க';

  @override
  String paperDiscussionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கலந்துரையாடல்கள்',
      one: '1 கலந்துரையாடல்',
      zero: 'கலந்துரையாடல்கள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get actionDownload => 'பதிவிறக்கவும்';

  @override
  String get actionOpen => 'திறக்கவும்';

  @override
  String get actionDownloadAgain => 'மீண்டும் பதிவிறக்கவும்';

  @override
  String downloadProgress(int percent) {
    return 'பதிவிறக்குகிறது… $percent%';
  }

  @override
  String get downloadStarting => 'பதிவிறக்கம் தொடங்குகிறது…';

  @override
  String get downloadComplete => 'பதிவிறக்கப்பட்டது';

  @override
  String get downloadFailed => 'பதிவிறக்கம் தோல்வியடைந்தது';

  @override
  String get downloadNeedsConnection =>
      'இந்தத் தாளைப் பதிவிறக்க இணைய இணைப்பு தேவை.';

  @override
  String pdfPageOf(int page, int total) {
    return 'பக்கம் $page / $total';
  }

  @override
  String get pdfOpenFailed =>
      'இந்த PDF ஐத் திறக்க முடியவில்லை. பதிவிறக்கம் முழுமையடையாமல் இருக்கலாம்.';

  @override
  String get profileTitle => 'சுயவிவரம்';

  @override
  String get profileStudent => 'மாணவர்';

  @override
  String get profileGuest => 'விருந்தினர்';

  @override
  String get profileGuestExplainer =>
      'நீங்கள் விருந்தினராக உலாவுகிறீர்கள். உங்கள் முன்னேற்றம் இந்தத் தொலைபேசியில் மட்டுமே சேமிக்கப்படுகிறது — தொலைபேசியை மாற்றும்போது அதைத் தக்கவைக்க உள்நுழையவும்.';

  @override
  String profileSignedInAs(String email) {
    return '$email என உள்நுழைந்துள்ளீர்கள்';
  }

  @override
  String get profileDisplayName => 'காட்சிப் பெயர்';

  @override
  String get profileLanguage => 'மொழி';

  @override
  String get profileMyDownloads => 'எனது பதிவிறக்கங்கள்';

  @override
  String get profileSignOut => 'வெளியேறு';

  @override
  String get profileSignOutConfirm =>
      'இந்தக் கணக்கிலிருந்து வெளியேறவா? இந்தத் தொலைபேசியில் விருந்தினர் முன்னேற்றம் தக்கவைக்கப்படும்.';

  @override
  String get profileSaved => 'சேமிக்கப்பட்டது';

  @override
  String get authSignIn => 'உள்நுழைக';

  @override
  String get authSignUp => 'கணக்கை உருவாக்கு';

  @override
  String get authEmail => 'மின்னஞ்சல்';

  @override
  String get authPassword => 'கடவுச்சொல்';

  @override
  String get authNoAccount => 'இன்னும் கணக்கு இல்லையா?';

  @override
  String get authHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா?';

  @override
  String get authContinueAsGuest => 'விருந்தினராகத் தொடரவும்';

  @override
  String get authWhySignIn =>
      'உள்நுழைவது, தொலைபேசியை மாற்றினாலும் உங்கள் பார்த்த முன்னேற்றத்தையும் பதிவிறக்கங்களையும் தக்கவைக்கும். இது கட்டாயமல்ல.';

  @override
  String get authInvalidEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get authPasswordTooShort =>
      'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get authCheckEmail =>
      'உங்கள் கணக்கை உறுதிப்படுத்த மின்னஞ்சலைச் சரிபார்க்கவும்.';

  @override
  String get downloadsTitle => 'எனது பதிவிறக்கங்கள்';

  @override
  String get downloadsEmptyTitle => 'இன்னும் பதிவிறக்கங்கள் இல்லை';

  @override
  String get downloadsEmptyMessage =>
      'நீங்கள் பதிவிறக்கும் தாள்கள், இணையம் இல்லாமல் படிக்க இங்கே தோன்றும்.';

  @override
  String get downloadsOnThisPhone => 'இந்தத் தொலைபேசியில் சேமிக்கப்பட்டது';

  @override
  String get downloadsNotOnThisPhone => 'இந்தத் தொலைபேசியில் இல்லை';

  @override
  String get downloadsRemove => 'தொலைபேசியிலிருந்து அகற்று';

  @override
  String get downloadsRemoved => 'இந்தத் தொலைபேசியிலிருந்து அகற்றப்பட்டது';

  @override
  String get emptyNoSubjectsTitle => 'இன்னும் பாடங்கள் இல்லை';

  @override
  String get emptyNoSubjectsMessage =>
      'படிப்புப் பொருள் இன்னும் வெளியிடப்படவில்லை. விரைவில் மீண்டும் பார்க்கவும்.';

  @override
  String get emptyNoVideosTitle => 'இன்னும் வீடியோக்கள் இல்லை';

  @override
  String get emptyNoVideosMessage =>
      'இந்தத் தாளுக்கான கலந்துரையாடல் வீடியோக்கள் இன்னும் வெளியிடப்படவில்லை.';

  @override
  String get emptyNoPapersTitle => 'தாள்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get emptyNoPapersMessage =>
      'இந்த வடிகட்டிகளுக்கு எந்தத் தாளும் பொருந்தவில்லை.';

  @override
  String get emptyNoProgressMessage =>
      'நீங்கள் பார்க்கத் தொடங்கும் வீடியோக்கள் இங்கே தோன்றும்.';

  @override
  String get commonRetry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get commonCancel => 'ரத்துசெய்';

  @override
  String get commonClose => 'மூடு';

  @override
  String get commonSave => 'சேமி';

  @override
  String get commonOk => 'சரி';

  @override
  String get errorGeneric => 'ஏதோ தவறு நடந்தது';

  @override
  String get errorNoConnection => 'இணைய இணைப்பு இல்லை';

  @override
  String get errorConfigMissingTitle => 'செயலி கட்டமைக்கப்படவில்லை';
}
