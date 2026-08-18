// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'සොයුරු සත්කාර';

  @override
  String get appTagline => 'සීමාවන් ඉක්මවා අධ්‍යාපනය';

  @override
  String get navHome => 'මුල් පිටුව';

  @override
  String get navPapers => 'ප්‍රශ්න පත්‍ර';

  @override
  String get navProfile => 'පැතිකඩ';

  @override
  String get homeSubtitle => 'නොමිලේ වීඩියෝ පාඩම්, ප්‍රශ්න පත්‍ර සහ සටහන්';

  @override
  String get homeSubjects => 'විෂයයන්';

  @override
  String get homeContinueWatching => 'දිගටම නරඹන්න';

  @override
  String get subjectTabVideos => 'වීඩියෝ';

  @override
  String get subjectTabPapers => 'ප්‍රශ්න පත්‍ර';

  @override
  String get unitsTitle => 'පාඩම් ඒකක';

  @override
  String unitVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'වීඩියෝ $count',
      one: 'වීඩියෝ 1',
      zero: 'වීඩියෝ නැත',
    );
    return '$_temp0';
  }

  @override
  String unitCompletedOf(int done, int total) {
    return '$totalන් $done නරඹා ඇත';
  }

  @override
  String get playerUpNext => 'ඊළඟට';

  @override
  String get playerRelatedVideos => 'සම්බන්ධිත වීඩියෝ පාඩම්';

  @override
  String get playerMarkComplete => 'නරඹා ඇති බව සලකුණු කරන්න';

  @override
  String get playerMarkedComplete => 'නරඹා ඇත';

  @override
  String get playerOpenInYouTube => 'YouTube හි විවෘත කරන්න';

  @override
  String playerVideoOf(int index, int total) {
    return 'වීඩියෝ $index / $total';
  }

  @override
  String get playerNext => 'ඊළඟ';

  @override
  String get playerPrevious => 'පෙර';

  @override
  String get playerProgressSaved => 'ප්‍රගතිය සුරකින ලදි';

  @override
  String get papersSubtitle => 'විභාග ප්‍රශ්න පත්‍ර සහ පුහුණු ප්‍රශ්න බාගන්න';

  @override
  String get filterAll => 'සියල්ල';

  @override
  String get filterYear => 'වර්ෂය';

  @override
  String get filterMedium => 'මාධ්‍යය';

  @override
  String get filterType => 'වර්ගය';

  @override
  String get filterClear => 'පෙරහන් ඉවත් කරන්න';

  @override
  String get paperTypePast => 'පසුගිය ප්‍රශ්න පත්‍රය';

  @override
  String get paperTypeModel => 'පුහුණු ප්‍රශ්න පත්‍රය';

  @override
  String get paperTypeTerm => 'වාර පරීක්ෂණය';

  @override
  String get paperTypeNotes => 'සටහන්';

  @override
  String get mediumSi => 'සිංහල';

  @override
  String get mediumEn => 'ඉංග්‍රීසි';

  @override
  String get mediumTa => 'දෙමළ';

  @override
  String get paperWithAnswers => 'පිළිතුරු සමඟ';

  @override
  String get paperSeeVideos => 'වීඩියෝ බලන්න';

  @override
  String paperDiscussionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'සාකච්ඡා $count',
      one: 'සාකච්ඡා 1',
      zero: 'සාකච්ඡා නැත',
    );
    return '$_temp0';
  }

  @override
  String get actionDownload => 'බාගන්න';

  @override
  String get actionOpen => 'විවෘත කරන්න';

  @override
  String get actionDownloadAgain => 'නැවත බාගන්න';

  @override
  String downloadProgress(int percent) {
    return 'බාගත වෙමින්… $percent%';
  }

  @override
  String get downloadStarting => 'බාගැනීම ආරම්භ වෙමින්…';

  @override
  String get downloadComplete => 'බාගත කර ඇත';

  @override
  String get downloadFailed => 'බාගැනීම අසාර්ථක විය';

  @override
  String get downloadNeedsConnection =>
      'මෙම ප්‍රශ්න පත්‍රය බාගැනීමට අන්තර්ජාල සම්බන්ධතාවයක් අවශ්‍යයි.';

  @override
  String pdfPageOf(int page, int total) {
    return 'පිටුව $page / $total';
  }

  @override
  String get pdfOpenFailed =>
      'මෙම PDF විවෘත කළ නොහැකි විය. බාගැනීම සම්පූර්ණ නොවී තිබිය හැක.';

  @override
  String get profileTitle => 'පැතිකඩ';

  @override
  String get profileStudent => 'සිසුවා';

  @override
  String get profileGuest => 'අමුත්තා';

  @override
  String get profileGuestExplainer =>
      'ඔබ අමුත්තෙකු ලෙස බලමින් සිටී. ඔබේ ප්‍රගතිය මෙම දුරකථනයේ පමණක් සුරැකේ — දුරකථනය මාරු කරන විට එය රැක ගැනීමට පිවිසෙන්න.';

  @override
  String profileSignedInAs(String email) {
    return '$email ලෙස පිවිසී ඇත';
  }

  @override
  String get profileDisplayName => 'දර්ශන නාමය';

  @override
  String get profileLanguage => 'භාෂාව';

  @override
  String get profileMyDownloads => 'මගේ බාගැනීම්';

  @override
  String get profileSignOut => 'ඉවත් වන්න';

  @override
  String get profileSignOutConfirm =>
      'මෙම ගිණුමෙන් ඉවත් වන්නද? මෙම දුරකථනයේ අමුත්තාගේ ප්‍රගතිය රැකේ.';

  @override
  String get profileSaved => 'සුරකින ලදි';

  @override
  String get authSignIn => 'පිවිසෙන්න';

  @override
  String get authSignUp => 'ගිණුමක් සාදන්න';

  @override
  String get authEmail => 'විද්‍යුත් තැපෑල';

  @override
  String get authPassword => 'මුරපදය';

  @override
  String get authNoAccount => 'තවම ගිණුමක් නැද්ද?';

  @override
  String get authHaveAccount => 'දැනටමත් ගිණුමක් තිබේද?';

  @override
  String get authContinueAsGuest => 'අමුත්තෙකු ලෙස ඉදිරියට';

  @override
  String get authWhySignIn =>
      'පිවිසීමෙන්, ඔබ දුරකථනය මාරු කළත් ඔබේ නැරඹීම් ප්‍රගතිය සහ බාගැනීම් රැකේ. මෙය අනිවාර්ය නොවේ.';

  @override
  String get authInvalidEmail => 'වලංගු විද්‍යුත් තැපැල් ලිපිනයක් ඇතුළත් කරන්න';

  @override
  String get authPasswordTooShort => 'මුරපදය අවම වශයෙන් අක්ෂර 6 විය යුතුය';

  @override
  String get authCheckEmail =>
      'ඔබේ ගිණුම තහවුරු කිරීමට විද්‍යුත් තැපෑල පරීක්ෂා කරන්න.';

  @override
  String get downloadsTitle => 'මගේ බාගැනීම්';

  @override
  String get downloadsEmptyTitle => 'තවම බාගැනීම් නැත';

  @override
  String get downloadsEmptyMessage =>
      'ඔබ බාගන්නා ප්‍රශ්න පත්‍ර, අන්තර්ජාලයෙන් තොරව කියවීමට මෙහි දිස්වේ.';

  @override
  String get downloadsOnThisPhone => 'මෙම දුරකථනයේ සුරකින ලදි';

  @override
  String get downloadsNotOnThisPhone => 'මෙම දුරකථනයේ නැත';

  @override
  String get downloadsRemove => 'දුරකථනයෙන් ඉවත් කරන්න';

  @override
  String get downloadsRemoved => 'මෙම දුරකථනයෙන් ඉවත් කරන ලදි';

  @override
  String get emptyNoSubjectsTitle => 'තවම විෂයයන් නැත';

  @override
  String get emptyNoSubjectsMessage =>
      'අධ්‍යයන ද්‍රව්‍ය තවම ප්‍රකාශයට පත් කර නැත. කරුණාකර පසුව නැවත බලන්න.';

  @override
  String get emptyNoVideosTitle => 'තවම වීඩියෝ නැත';

  @override
  String get emptyNoVideosMessage =>
      'මෙම ප්‍රශ්න පත්‍රය සඳහා සාකච්ඡා වීඩියෝ තවම ප්‍රකාශයට පත් කර නැත.';

  @override
  String get emptyNoPapersTitle => 'ප්‍රශ්න පත්‍ර හමු නොවිය';

  @override
  String get emptyNoPapersMessage => 'මෙම පෙරහන් වලට ගැලපෙන ප්‍රශ්න පත්‍ර නැත.';

  @override
  String get emptyNoProgressMessage =>
      'ඔබ නැරඹීම ආරම්භ කරන වීඩියෝ මෙහි දිස්වේ.';

  @override
  String get commonRetry => 'නැවත උත්සාහ කරන්න';

  @override
  String get commonCancel => 'අවලංගු කරන්න';

  @override
  String get commonClose => 'වසන්න';

  @override
  String get commonSave => 'සුරකින්න';

  @override
  String get commonOk => 'හරි';

  @override
  String get errorGeneric => 'යම් දෝෂයක් සිදු විය';

  @override
  String get errorNoConnection => 'අන්තර්ජාල සම්බන්ධතාවයක් නැත';

  @override
  String get errorConfigMissingTitle => 'යෙදුම වින්‍යාස කර නැත';
}
