import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttStatus { disconnected, connecting, connected, error }

class MqttCustomMessage {
  final String topic;
  final String payload;
  final DateTime timestamp;

  MqttCustomMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });
}

class MqttService {
  MqttServerClient? _client;
  MqttStatus _status = MqttStatus.disconnected;
  MqttStatus get status => _status;

  String _broker = 'broker.hivemq.com';
  int _port = 1883;
  String _topic = 'kampus/demo/sensor01';
  String _clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch % 100000}';

  String get broker => _broker;
  int get port => _port;
  String get topic => _topic;
  String get clientId => _clientId;

  final StreamController<MqttStatus> _statusController = StreamController<MqttStatus>.broadcast();
  Stream<MqttStatus> get statusStream => _statusController.stream;

  final StreamController<MqttCustomMessage> _messageController =
      StreamController<MqttCustomMessage>.broadcast();
  Stream<MqttCustomMessage> get messageStream => _messageController.stream;

  final StreamController<String> _logController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  void configure({String? broker, int? port, String? topic, String? clientId}) {
    if (broker != null) _broker = broker;
    if (port != null) _port = port;
    if (topic != null) _topic = topic;
    if (clientId != null) _clientId = clientId;
  }

  void _setStatus(MqttStatus s) {
    _status = s;
    _statusController.add(s);
  }

  void _addLog(String text) {
    _logController.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $text');
  }

  Future<void> connect() async {
    disconnect();
    _setStatus(MqttStatus.connecting);
    _addLog('Menghubungkan ke Broker MQTT: $_broker:$_port (Client ID: $_clientId)...');

    if (kIsWeb) {
      _setStatus(MqttStatus.error);
      _addLog('Catatan: Web browser membatasi raw TCP port 1883. Jalankan pada Windows Desktop atau Android Emulator.');
      return;
    }

    try {
      _client = MqttServerClient.withPort(_broker, _clientId, _port);
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30;
      _client!.autoReconnect = true;

      _client!.onConnected = () {
        _setStatus(MqttStatus.connected);
        _addLog('MQTT Terhubung ke $_broker:$_port!');
        _subscribeToTopic(_topic);
      };

      _client!.onDisconnected = () {
        _setStatus(MqttStatus.disconnected);
        _addLog('MQTT terputus dari broker.');
      };

      _client!.onSubscribed = (t) {
        _addLog('Berhasil subscribe ke topik: $t');
      };

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);
      _client!.connectionMessage = connMessage;

      final status = await _client!.connect().timeout(const Duration(seconds: 12));

      if (status?.state != MqttConnectionState.connected) {
        _setStatus(MqttStatus.error);
        _addLog('Gagal terhubung, status: ${status?.state}');
        disconnect();
        return;
      }

      _client!.updates?.listen((events) {
        for (final event in events) {
          final publish = event.payload as MqttPublishMessage;
          final message = MqttPublishPayload.bytesToStringAsString(
            publish.payload.message,
          );

          _addLog('Topik [${event.topic}]: $message');
          _messageController.add(MqttCustomMessage(
            topic: event.topic,
            payload: message,
            timestamp: DateTime.now(),
          ));
        }
      });
    } catch (e) {
      _setStatus(MqttStatus.error);
      _addLog('MQTT Connection Error: $e');
      disconnect();
    }
  }

  void _subscribeToTopic(String t) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(t, MqttQos.atMostOnce);
      _addLog('Mengirim perintah subscribe ke "$t"...');
    }
  }

  void updateTopic(String newTopic) {
    if (_topic == newTopic) return;
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.unsubscribe(_topic);
      _topic = newTopic;
      _subscribeToTopic(_topic);
    } else {
      _topic = newTopic;
    }
  }

  void publishSensorData({required double temperature, double? humidity}) {
    if (_status != MqttStatus.connected || _client == null) {
      _addLog('Gagal publish: MQTT belum tersambung!');
      return;
    }

    final payloadMap = {
      'temperature': double.parse(temperature.toStringAsFixed(1)),
      if (humidity != null) 'humidity': double.parse(humidity.toStringAsFixed(1)),
      'device_id': _clientId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsonStr = jsonEncode(payloadMap);
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonStr);

    _client!.publishMessage(_topic, MqttQos.atMostOnce, builder.payload!);
    _addLog('Published ke $_topic: $jsonStr');
  }

  void disconnect() {
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;
    if (_status != MqttStatus.disconnected) {
      _setStatus(MqttStatus.disconnected);
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
    _logController.close();
  }
}
