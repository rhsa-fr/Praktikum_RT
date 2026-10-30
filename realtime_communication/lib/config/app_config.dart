import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AppConfig extends ChangeNotifier {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;

  AppConfig._internal() {
    _host = _detectDefaultHost();
  }

  String _host = 'localhost';
  int _port = 3000;

  String get host => _host;
  int get port => _port;

  String get baseUrl => 'http://$_host:$_port';
  String get wsUrl => 'ws://$_host:$_port';

  String _detectDefaultHost() {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  void updateServer({required String host, int port = 3000}) {
    _host = host.trim().replaceAll(RegExp(r'^https?://|^ws://'), '');
    _port = port;
    notifyListeners();
  }
}

