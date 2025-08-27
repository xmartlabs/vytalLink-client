// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String error(String text) {
    return 'Error: $text';
  }

  @override
  String get error_button_ok => 'Ok';

  @override
  String get error_button_retry => 'Retry';

  @override
  String get error_no_internet_connection_error_description =>
      'You have no internet connection';

  @override
  String get error_no_internet_connection_error_title => 'Error';

  @override
  String get error_unknown_error_description => 'Something went wrong!';

  @override
  String get error_unknown_error_title => 'Ops!';

  @override
  String get home_button_start_server => 'Start MCP Server';

  @override
  String get home_button_starting => 'Starting...';

  @override
  String get home_button_stop_server => 'Stop MCP Server';

  @override
  String get home_button_stopping => 'Stopping...';

  @override
  String get home_description_offline =>
      'Ready to start the MCP server on this device';

  @override
  String get home_description_running =>
      'Server is active and ready to accept connections';

  @override
  String get home_description_starting =>
      'Initializing MCP server and binding to port...';

  @override
  String get home_description_stopping =>
      'Shutting down server and closing connections...';

  @override
  String home_endpoint_label(String endpoint) {
    return 'Endpoint: $endpoint';
  }

  @override
  String home_server_ip_label(String ipAddress) {
    return 'Server IP: $ipAddress';
  }

  @override
  String get home_status_offline => 'MCP Server Offline';

  @override
  String get home_status_running => 'MCP Server Running';

  @override
  String get home_status_starting => 'Starting Server...';

  @override
  String get home_status_stopping => 'Stopping Server...';

  @override
  String get home_title => 'MCP Server Control';
}
