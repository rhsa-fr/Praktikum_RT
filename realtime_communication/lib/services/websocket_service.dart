import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../models/chat_message.dart';
import '../models/sensor_data.dart';

enum WsStatus { disconnected, connecting, connected, error }

class WebSocketService {
  final AppConfig _config = AppConfig();
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  WsStatus _status = WsStatus.disconnected;
  WsStatus get status => _status;

  final StreamController<WsStatus> _statusController = StreamController<WsStatus>.broadcast();
  Stream<WsStatus> get statusStream => _statusController.stream;

  final StreamController<ChatMessage> _chatController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get chatStream => _chatController.stream;

  final StreamController<SensorData> _sensorController = StreamController<SensorData>.broadcast();
  Stream<SensorData> get sensorStream => _sensorController.stream;

  final StreamController<String> _logController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  String currentUsername = 'Mahasiswa';

  void _setStatus(WsStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void _addLog(String log) {
    _logController.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $log');
  }

  void connect() {
    disconnect();
    _setStatus(WsStatus.connecting);
    _addLog('Menghubungkan ke WebSocket: ${_config.wsUrl}...');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_config.wsUrl));
      _setStatus(WsStatus.connected);
      _addLog('WebSocket terhubung ke ${_config.wsUrl}!');

      _subscription = _channel!.stream.listen(
        (data) {
          _handleRawMessage(data.toString());
        },
        onError: (error) {
          _setStatus(WsStatus.error);
          _addLog('WebSocket Error: $error');
          disconnect();
        },
        onDone: () {
          _setStatus(WsStatus.disconnected);
          _addLog('Koneksi WebSocket ditutup oleh server.');
        },
        cancelOnError: true,
      );
    } catch (e) {
      _setStatus(WsStatus.error);
      _addLog('Gagal menghubungkan WebSocket: $e');
    }
  }

  void _handleRawMessage(String raw) {
    _addLog('Pesan masuk: $raw');
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        final type = json['type']?.toString();

        if (type == 'sensor_broadcast' && json['data'] != null) {
          _sensorController.add(SensorData.fromJson(json['data'] as Map<String, dynamic>));
        } else if (type == 'chat' || type == 'echo') {
          _chatController.add(ChatMessage.fromJson(json, currentSender: currentUsername));
        } else if (type == 'system') {
          _chatController.add(ChatMessage(
            type: 'system',
            sender: 'Sistem Server',
            message: json['message']?.toString() ?? '',
            timestamp: DateTime.now(),
          ));
        } else {
          _chatController.add(ChatMessage.fromJson(json, currentSender: currentUsername));
        }
      }
    } catch (_) {
      _chatController.add(ChatMessage(
        type: 'raw',
        sender: 'Server',
        message: raw,
        timestamp: DateTime.now(),
      ));
    }
  }

  void sendMessage(String message) {
    if (_status != WsStatus.connected || _channel == null) {
      _addLog('Gagal mengirim: WebSocket belum terhubung!');
      return;
    }

    final payload = jsonEncode({
      'sender': currentUsername,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _channel!.sink.add(payload);
    _addLog('Pesan terkirim: $message');
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;

    if (_status != WsStatus.disconnected) {
      _setStatus(WsStatus.disconnected);
      _addLog('WebSocket terputus.');
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _chatController.close();
    _sensorController.close();
    _logController.close();
  }
}
