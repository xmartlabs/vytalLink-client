import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Gives the user an error explanation
  ///
  /// In en, this message translates to:
  /// **'Error: {text}'**
  String error(String text);

  /// No description provided for @error_button_ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get error_button_ok;

  /// No description provided for @error_button_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get error_button_retry;

  /// No description provided for @error_no_internet_connection_error_description.
  ///
  /// In en, this message translates to:
  /// **'You have no internet connection'**
  String get error_no_internet_connection_error_description;

  /// No description provided for @error_no_internet_connection_error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_no_internet_connection_error_title;

  /// No description provided for @error_unknown_error_description.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get error_unknown_error_description;

  /// No description provided for @error_unknown_error_title.
  ///
  /// In en, this message translates to:
  /// **'Ops!'**
  String get error_unknown_error_title;

  /// No description provided for @home_button_start_server.
  ///
  /// In en, this message translates to:
  /// **'Start MCP Server'**
  String get home_button_start_server;

  /// No description provided for @home_button_starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get home_button_starting;

  /// No description provided for @home_button_stop_server.
  ///
  /// In en, this message translates to:
  /// **'Stop MCP Server'**
  String get home_button_stop_server;

  /// No description provided for @home_button_stopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping...'**
  String get home_button_stopping;

  /// No description provided for @home_description_offline.
  ///
  /// In en, this message translates to:
  /// **'Ready to start the MCP server on this device'**
  String get home_description_offline;

  /// No description provided for @home_description_running.
  ///
  /// In en, this message translates to:
  /// **'Server is active and ready to accept connections'**
  String get home_description_running;

  /// No description provided for @home_description_starting.
  ///
  /// In en, this message translates to:
  /// **'Initializing MCP server and binding to port...'**
  String get home_description_starting;

  /// No description provided for @home_description_stopping.
  ///
  /// In en, this message translates to:
  /// **'Shutting down server and closing connections...'**
  String get home_description_stopping;

  /// Shows the endpoint
  ///
  /// In en, this message translates to:
  /// **'Endpoint: {endpoint}'**
  String home_endpoint_label(String endpoint);

  /// Shows the server IP address
  ///
  /// In en, this message translates to:
  /// **'Server IP: {ipAddress}'**
  String home_server_ip_label(String ipAddress);

  /// No description provided for @home_status_offline.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Offline'**
  String get home_status_offline;

  /// No description provided for @home_status_running.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Running'**
  String get home_status_running;

  /// No description provided for @home_status_starting.
  ///
  /// In en, this message translates to:
  /// **'Starting Server...'**
  String get home_status_starting;

  /// No description provided for @home_status_stopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping Server...'**
  String get home_status_stopping;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Control'**
  String get home_title;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
