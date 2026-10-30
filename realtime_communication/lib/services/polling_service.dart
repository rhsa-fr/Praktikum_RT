import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/sensor_data.dart';

class PollingService {
  final AppConfig _config = AppConfig();

  // Polling Biasa State
  Timer? _pollingTimer;
  bool _isPollingRunning = false;
  int _pollingCount = 0;
  bool get isPollingRunning => _isPollingRunning;
  int get pollingCount => _pollingCount;

  // Long Polling State
  bool _isLongPollingRunning = false;
  int _longPollCount = 0;
  int _lastCounter = 0;
  http.Client? _longPollClient;
  bool get isLongPollingRunning => _isLongPollingRunning;
  int get longPollCount => _longPollCount;

  // ==========================================
  // 1. Polling Biasa (Interval-based)
  // ==========================================
  void startPolling({
    required Function(SensorData data, int latencyMs) onData,
    required Function(String error) onError,
    Duration interval = const Duration(seconds: 2),
  }) {
    stopPolling();
    _isPollingRunning = true;
    _pollingCount = 0;

    Future<void> fetchOnce() async {
      if (!_isPollingRunning) return;
      final sw = Stopwatch()..start();
      try {
        final url = Uri.parse('${_config.baseUrl}/api/data');
        final response = await http.get(url).timeout(const Duration(seconds: 5));
        sw.stop();
        _pollingCount++;

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          onData(SensorData.fromJson(json), sw.elapsedMilliseconds);
        } else {
          onError('HTTP ${response.statusCode}');
        }
      } catch (e) {
        sw.stop();
        onError(e.toString());
      }
    }

    // Eksekusi segera lalu ulangi
    fetchOnce();
    _pollingTimer = Timer.periodic(interval, (_) => fetchOnce());
  }

  void stopPolling() {
    _isPollingRunning = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ==========================================
  // 2. Long Polling (Held Connection)
  // ==========================================
  void startLongPolling({
    required Function(SensorData data, int waitedMs) onData,
    required Function(String error) onError,
    required Function(String status) onStatus,
  }) {
    stopLongPolling();
    _isLongPollingRunning = true;
    _longPollCount = 0;
    _longPollClient = http.Client();

    _runLongPollLoop(onData, onError, onStatus);
  }

  Future<void> _runLongPollLoop(
    Function(SensorData data, int waitedMs) onData,
    Function(String error) onError,
    Function(String status) onStatus,
  ) async {
    while (_isLongPollingRunning) {
      final sw = Stopwatch()..start();
      onStatus('Menunggu data baru dari server (connection held)...');
      try {
        final url = Uri.parse('${_config.baseUrl}/api/long-poll?lastCounter=$_lastCounter');
        final response = await _longPollClient!.get(url).timeout(const Duration(seconds: 35));
        sw.stop();

        if (!_isLongPollingRunning) break;

        _longPollCount++;
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final bool success = json['success'] == true;
          final int waitedMs = (json['waitedMs'] as int?) ?? sw.elapsedMilliseconds;

          if (json['data'] != null) {
            final data = SensorData.fromJson(json['data'] as Map<String, dynamic>);
            _lastCounter = data.counter;
            if (success) {
              onData(data, waitedMs);
            } else {
              onStatus('Long poll timeout (${waitedMs}ms), mengirim request baru...');
            }
          }
        } else {
          onError('Long poll gagal: HTTP ${response.statusCode}');
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        sw.stop();
        if (!_isLongPollingRunning) break;
        onError('Koneksi terputus: $e');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void stopLongPolling() {
    _isLongPollingRunning = false;
    _longPollClient?.close();
    _longPollClient = null;
  }

  void dispose() {
    stopPolling();
    stopLongPolling();
  }
}

