import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/sensor_data.dart';

enum SseStatus { disconnected, connecting, connected, error }

class SseService {
  final AppConfig _config = AppConfig();
  http.Client? _client;
  StreamSubscription<String>? _subscription;

  SseStatus _status = SseStatus.disconnected;
  SseStatus get status => _status;

  final StreamController<SensorData> _dataController = StreamController<SensorData>.broadcast();
  Stream<SensorData> get dataStream => _dataController.stream;

  final StreamController<SseStatus> _statusController = StreamController<SseStatus>.broadcast();
  Stream<SseStatus> get statusStream => _statusController.stream;

  final StreamController<String> _logController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  void _setStatus(SseStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void _addLog(String msg) {
    _logController.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $msg');
  }

  Future<void> connect() async {
    disconnect();
    _setStatus(SseStatus.connecting);
    _addLog('Membuka koneksi SSE ke ${_config.baseUrl}/api/events...');

    _client = http.Client();

    try {
      final request = http.Request('GET', Uri.parse('${_config.baseUrl}/api/events'));
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final response = await _client!.send(request);

      if (response.statusCode != 200) {
        _setStatus(SseStatus.error);
        _addLog('SSE gagal terhubung: Status HTTP ${response.statusCode}');
        return;
      }

      _setStatus(SseStatus.connected);
      _addLog('SSE Terhubung! Menunggu aliran event dari server...');

      String currentEvent = 'message';
      final StringBuffer dataBuffer = StringBuffer();

      _subscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          final trimmed = line.trim();

          if (trimmed.isEmpty) {
            // Akhir blok event: dispatch jika dataBuffer tidak kosong
            if (dataBuffer.isNotEmpty) {
              final rawData = dataBuffer.toString();
              dataBuffer.clear();

              _handleEvent(currentEvent, rawData);
              currentEvent = 'message';
            }
            return;
          }

          if (trimmed.startsWith('event:')) {
            currentEvent = trimmed.substring(6).trim();
          } else if (trimmed.startsWith('data:')) {
            if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
            dataBuffer.write(trimmed.substring(5).trim());
          }
        },
        onError: (err) {
          _setStatus(SseStatus.error);
          _addLog('SSE Error: $err');
          disconnect();
        },
        onDone: () {
          _setStatus(SseStatus.disconnected);
          _addLog('Koneksi SSE ditutup oleh server.');
        },
        cancelOnError: true,
      );
    } catch (e) {
      _setStatus(SseStatus.error);
      _addLog('Gagal koneksi SSE: $e');
    }
  }

  void _handleEvent(String eventName, String rawData) {
    _addLog('Event diterima [$eventName]: $rawData');
    try {
      final json = jsonDecode(rawData);
      if (json is Map<String, dynamic> && json.containsKey('counter')) {
        _dataController.add(SensorData.fromJson(json));
      }
    } catch (_) {
      // Ignored if non-json handshake event
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _client?.close();
    _client = null;
    if (_status != SseStatus.disconnected) {
      _setStatus(SseStatus.disconnected);
      _addLog('SSE diputuskan oleh pengguna.');
    }
  }

  void dispose() {
    disconnect();
    _dataController.close();
    _statusController.close();
    _logController.close();
  }
}

