// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SoundCraft';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navLibrary => 'Library';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Next track';

  @override
  String get previous => 'Previous track';

  @override
  String get offlineBanner =>
      'Offline — your library and downloads still work.';

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get cancel => 'Cancel';
}
