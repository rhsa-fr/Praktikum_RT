import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/sensor_data.dart';
import '../services/sse_service.dart';

class Praktikum3SseScreen extends StatefulWidget {
  const Praktikum3SseScreen({super.key});

  @override
  State<Praktikum3SseScreen> createState() => _Praktikum3SseScreenState();
}

class _Praktikum3SseScreenState extends State<Praktikum3SseScreen> {
  final SseService _service = SseService();
  final AppConfig _config = AppConfig();

  SseStatus _status = SseStatus.disconnected;
  SensorData? _latestData;
  int _receivedCount = 0;
  final List<String> _logs = [];

  StreamSubscription? _dataSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _logSub;

  @override
  void initState() {
    super.initState();
    _statusSub = _service.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });

    _dataSub = _service.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _latestData = data;
          _receivedCount++;
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
    _dataSub?.cancel();
    _statusSub?.cancel();
    _logSub?.cancel();
    _service.dispose();
    super.dispose();
  }

  void _toggleConnect() {
    if (_status == SseStatus.connected || _status == SseStatus.connecting) {
      _service.disconnect();
    } else {
      _service.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status == SseStatus.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 3 — Server-Sent Events (SSE)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Bersihkan Log',
            onPressed: () => setState(() => _logs.clear()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatusIndicator(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Endpoint: ${_config.baseUrl}/api/events',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: isConnected ? Colors.red : Colors.green,
                          ),
                          onPressed: _toggleConnect,
                          child: Text(isConnected ? 'Disconnect' : 'Connect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Sensor Display
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
                          'Data Sensor Real-Time (SSE Stream)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Total Masuk: $_receivedCount',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    if (_latestData != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.indigo.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Counter ID', style: TextStyle(fontSize: 12, color: Colors.indigo)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '#${_latestData!.counter}',
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.teal.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Sensor Value', style: TextStyle(fontSize: 12, color: Colors.teal)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_latestData!.value} %',
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _latestData!.value / 100.0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: _latestData!.value > 75 ? Colors.red : Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pembaruan terakhir: ${_latestData!.timestamp.toLocal()}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            isConnected
                                ? 'Menunggu event pertama dari server...'
                                : 'Tekan tombol "Connect" untuk mulai mendengarkan event streaming.',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Stream Logs Terminal
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Live Event Stream Log (text/event-stream)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 180,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text('Log masih kosong...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            )
                          : ListView.builder(
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  _logs[index],
                                  style: const TextStyle(
                                    color: Color(0xFF4AF626),
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pertanyaan Analisis
            ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.quiz, color: Colors.purple),
              title: const Text(
                'Pertanyaan Analisis Praktikum 3',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan:\nMengapa SSE menarik untuk dashboard monitoring, tetapi bukan pilihan utama untuk komunikasi audio/video dua arah?',
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
                          '1. Mengapa SSE Menarik untuk Dashboard Monitoring?\n'
                          '   - Berjalan di atas HTTP standar (port 80/443), sehingga aman melewati firewall dan proxy perusahaan tanpa konfigurasi khusus.\n'
                          '   - Memiliki fitur auto-reconnect dan event ID bawaan dari protokol browser/HTTP.\n'
                          '   - Beban overhead sangat kecil dibandingkan polling karena tidak perlu mengulang handshake HTTP pada tiap data.\n'
                          '   - Arah komunikasi dashboard bersifat asimetris: server yang mempublikasikan metrik/sensor ke client.\n\n'
                          '2. Mengapa SSE BUKAN Pilihan untuk Audio/Video Dua Arah?\n'
                          '   - Unidirectional (Satu Arah): SSE hanya mengalir dari server ke client. Audio/video call memerlukan komunikasi full-duplex (dua arah simultan).\n'
                          '   - Berbasis Teks (UTF-8): Protokol SSE dirancang untuk payload teks (`data: ...`), bukan binary streaming efisien.\n'
                          '   - Berbasis TCP: TCP menjamin urutan paket dengan retransmisi. Jika terjadi packet loss di jaringan buruk, terjadi Head-of-Line Blocking yang menyebabkan audio/video patah-patah (jitter tinggi). WebRTC memanfaatkan UDP/SRTP untuk latensi sub-100ms.',
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

  Widget _buildStatusIndicator() {
    Color color;
    switch (_status) {
      case SseStatus.connected:
        color = Colors.green;
        break;
      case SseStatus.connecting:
        color = Colors.amber;
        break;
      case SseStatus.error:
        color = Colors.red;
        break;
      case SseStatus.disconnected:
        color = Colors.grey;
        break;
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: _status == SseStatus.connected
            ? [BoxShadow(color: Colors.green.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
            : null,
      ),
    );
  }

  String _getStatusText() {
    switch (_status) {
      case SseStatus.connected:
        return 'Tersambung (Streaming)';
      case SseStatus.connecting:
        return 'Sedang Menghubungkan...';
      case SseStatus.error:
        return 'Koneksi Error';
      case SseStatus.disconnected:
        return 'Terputus';
    }
  }
}
