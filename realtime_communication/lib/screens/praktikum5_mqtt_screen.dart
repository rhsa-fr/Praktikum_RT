import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class Praktikum5MqttScreen extends StatefulWidget {
  const Praktikum5MqttScreen({super.key});

  @override
  State<Praktikum5MqttScreen> createState() => _Praktikum5MqttScreenState();
}

class _Praktikum5MqttScreenState extends State<Praktikum5MqttScreen> {
  final MqttService _service = MqttService();

  final TextEditingController _brokerController = TextEditingController(text: 'broker.hivemq.com');
  final TextEditingController _portController = TextEditingController(text: '1883');
  final TextEditingController _topicController = TextEditingController(text: 'kampus/demo/sensor01');

  MqttStatus _status = MqttStatus.disconnected;
  double _temperature = 28.5;
  double _humidity = 65.0;

  final List<MqttCustomMessage> _messages = [];
  final List<String> _logs = [];

  StreamSubscription? _statusSub;
  StreamSubscription? _msgSub;
  StreamSubscription? _logSub;

  @override
  void initState() {
    super.initState();
    _statusSub = _service.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });

    _msgSub = _service.messageStream.listen((msg) {
      if (mounted) {
        setState(() {
          _messages.insert(0, msg);
          if (_messages.length > 30) _messages.removeLast();
        });
      }
    });

    _logSub = _service.logStream.listen((log) {
      if (mounted) {
        setState(() {
          _logs.insert(0, log);
          if (_logs.length > 50) _logs.removeLast();
        });
      }
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _msgSub?.cancel();
    _logSub?.cancel();
    _service.dispose();
    _brokerController.dispose();
    _portController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _toggleConnect() {
    if (_status == MqttStatus.connected || _status == MqttStatus.connecting) {
      _service.disconnect();
    } else {
      _service.configure(
        broker: _brokerController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 1883,
        topic: _topicController.text.trim(),
      );
      _service.connect();
    }
  }

  void _publish() {
    _service.publishSensorData(
      temperature: _temperature,
      humidity: _humidity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status == MqttStatus.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 5 — MQTT (IoT Pub/Sub)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Pesan',
            onPressed: () => setState(() {
              _messages.clear();
              _logs.clear();
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kIsWeb)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Peringatan Platform: MQTT TCP (Port 1883) tidak didukung browser web sandboxing. Jalankan aplikasi pada Windows desktop atau emulator Android untuk koneksi TCP langsung.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Broker Connection Config
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusDot(),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusTitle(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const Spacer(),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: isConnected ? Colors.red : Colors.green,
                          ),
                          onPressed: _toggleConnect,
                          child: Text(isConnected ? 'Disconnect' : 'Connect Broker'),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _brokerController,
                            enabled: !isConnected,
                            decoration: const InputDecoration(
                              labelText: 'Broker Host',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _portController,
                            enabled: !isConnected,
                            decoration: const InputDecoration(
                              labelText: 'Port',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _topicController,
                      enabled: !isConnected,
                      decoration: const InputDecoration(
                        labelText: 'MQTT Topic (Pub/Sub)',
                        isDense: true,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.tag, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Publisher Panel (Simulasi Sensor ESP32)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                          child: const Icon(Icons.sensors, color: Colors.deepOrange),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Simulasi Sensor ESP32 (Publisher)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text('Publish nilai sensor ke broker MQTT', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Temperature Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Temperatur Suhu:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('${_temperature.toStringAsFixed(1)} °C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ],
                    ),
                    Slider(
                      value: _temperature,
                      min: 15.0,
                      max: 45.0,
                      divisions: 60,
                      label: '${_temperature.toStringAsFixed(1)} °C',
                      activeColor: Colors.deepOrange,
                      onChanged: (val) => setState(() => _temperature = val),
                    ),

                    // Humidity Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kelembapan Udara (RH):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('${_humidity.toStringAsFixed(0)} %', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    Slider(
                      value: _humidity,
                      min: 20.0,
                      max: 95.0,
                      divisions: 75,
                      label: '${_humidity.toStringAsFixed(0)} %',
                      activeColor: Colors.teal,
                      onChanged: (val) => setState(() => _humidity = val),
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Publish Data ke Broker MQTT'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
                        onPressed: isConnected ? _publish : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subscriber Panel (Data Sensor Masuk)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pesan Diterima dari Broker (Subscriber)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${_messages.length} pesan',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    if (_messages.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Belum ada pesan masuk. Tekan "Publish" di atas untuk mengirim pesan uji.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _messages.length.clamp(0, 5),
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.label, size: 14, color: Colors.blue.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      msg.topic,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}:${msg.timestamp.second.toString().padLeft(2, '0')}',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.payload,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // MQTT Advanced Concepts Info (QoS, Retain, LWT)
            Card(
              color: Colors.blueGrey.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blueGrey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fitur Unggulan MQTT:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildFeatureItem('QoS 0 (At most once)', 'Pesan dikirim sekali tanpa jaminan sampai (cocok untuk sensor frekuensi tinggi).'),
                    _buildFeatureItem('QoS 1 (At least once)', 'Pesan dijamin sampai minimal sekali (memerlukan ACK, ada kemungkinan duplikat).'),
                    _buildFeatureItem('QoS 2 (Exactly once)', 'Pesan dijamin sampai tepat satu kali via 4-way handshake (untuk transaksi kritis).'),
                    _buildFeatureItem('Retained Message', 'Broker menyimpan pesan terakhir untuk subscriber baru yang baru bergabung.'),
                    _buildFeatureItem('Last Will (LWT)', 'Pesan darurat otomatis jika perangkat tiba-tiba mati / ungraceful disconnect.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Analisis Box
            ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.quiz, color: Colors.purple),
              title: const Text(
                'Pertanyaan Analisis Praktikum 5',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan:\nMengapa MQTT sering dipilih untuk IoT dibandingkan polling REST API setiap detik?',
                        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: const Text(
                          'Jawaban Analisis Komprehensif:\n'
                          '1. Header Sangat Ringan (Minimal Overhead):\n'
                          '   - Header paket MQTT hanya berukuran 2 BYTE, sedangkan HTTP request membawa 500–1000 byte header (User-Agent, Accept, Cookies, dll).\n'
                          '   - Pada mikrokontroler (ESP32/Arduino) dengan konektivitas seluler (GPRS/LTE-M) dan daya baterai, MQTT menghemat kuota data hingga 90%+.\n\n'
                          '2. Model Publish–Subscribe vs Polling:\n'
                          '   - Pada polling REST, sensor atau client harus terus-menerus bertanya "ada data baru?" setiap detik (ribuan request sia-sia).\n'
                          '   - Pada MQTT, broker langsung mendorong data ke subscriber hanya saat data berubah (event-driven).\n\n'
                          '3. Fitur Keandalan IoT (Built-in Resilience):\n'
                          '   - Mendukung QoS (0, 1, 2) untuk adaptasi di jaringan seluler tidak stabil.\n'
                          '   - Fitur Keep-Alive ringan (pingreq/pingresp) dan Last Will & Testament (LWT) yang otomatis mendeteksi jika sensor offline.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot() {
    Color color;
    switch (_status) {
      case MqttStatus.connected:
        color = Colors.green;
        break;
      case MqttStatus.connecting:
        color = Colors.amber;
        break;
      case MqttStatus.error:
        color = Colors.red;
        break;
      case MqttStatus.disconnected:
        color = Colors.grey;
        break;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _getStatusTitle() {
    switch (_status) {
      case MqttStatus.connected:
        return 'MQTT Terhubung ke Broker';
      case MqttStatus.connecting:
        return 'Menghubungkan ke Broker...';
      case MqttStatus.error:
        return 'Koneksi Gagal / Error';
      case MqttStatus.disconnected:
        return 'MQTT Terputus';
    }
  }
}
