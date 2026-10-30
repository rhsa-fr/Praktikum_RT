import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/polling_service.dart';

class Praktikum2PollingScreen extends StatefulWidget {
  const Praktikum2PollingScreen({super.key});

  @override
  State<Praktikum2PollingScreen> createState() => _Praktikum2PollingScreenState();
}

class _Praktikum2PollingScreenState extends State<Praktikum2PollingScreen> {
  final PollingService _service = PollingService();

  // Polling Biasa State
  bool _isPolling = false;
  int _pollingIntervalSeconds = 2;
  SensorData? _pollingData;
  int _pollingCount = 0;
  int _pollingLatency = 0;
  String? _pollingError;

  // Long Polling State
  bool _isLongPolling = false;
  SensorData? _longPollData;
  int _longPollCount = 0;
  int _longPollWaitedMs = 0;
  String _longPollStatus = 'Belum dimulai';
  String? _longPollError;

  final List<String> _pollingLogs = [];
  final List<String> _longPollLogs = [];

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _togglePolling() {
    if (_isPolling) {
      _service.stopPolling();
      setState(() {
        _isPolling = false;
      });
    } else {
      setState(() {
        _isPolling = true;
        _pollingError = null;
      });

      _service.startPolling(
        interval: Duration(seconds: _pollingIntervalSeconds),
        onData: (data, latencyMs) {
          if (!mounted) return;
          setState(() {
            _pollingData = data;
            _pollingCount = _service.pollingCount;
            _pollingLatency = latencyMs;
            _pollingLogs.insert(
              0,
              '[${DateTime.now().toIso8601String().substring(11, 19)}] Counter #${data.counter} | Val: ${data.value} (${latencyMs}ms)',
            );
            if (_pollingLogs.length > 20) _pollingLogs.removeLast();
          });
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _pollingError = err;
          });
        },
      );
    }
  }

  void _toggleLongPolling() {
    if (_isLongPolling) {
      _service.stopLongPolling();
      setState(() {
        _isLongPolling = false;
        _longPollStatus = 'Dihentikan';
      });
    } else {
      setState(() {
        _isLongPolling = true;
        _longPollError = null;
        _longPollStatus = 'Koneksi ditahan server...';
      });

      _service.startLongPolling(
        onData: (data, waitedMs) {
          if (!mounted) return;
          setState(() {
            _longPollData = data;
            _longPollCount = _service.longPollCount;
            _longPollWaitedMs = waitedMs;
            _longPollStatus = 'Menerima pembaruan seketika!';
            _longPollLogs.insert(
              0,
              '[${DateTime.now().toIso8601String().substring(11, 19)}] Counter #${data.counter} | Val: ${data.value} (Server tahan ${waitedMs}ms)',
            );
            if (_longPollLogs.length > 20) _longPollLogs.removeLast();
          });
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _longPollError = err;
            _longPollStatus = 'Error koneksi';
          });
        },
        onStatus: (status) {
          if (!mounted) return;
          setState(() {
            _longPollStatus = status;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 2 — Polling & Long Polling'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Head Comparison Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card 1: Polling Biasa
                Expanded(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _isPolling ? Colors.blue : Colors.grey.shade300,
                        width: _isPolling ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.timer, color: _isPolling ? Colors.blue : Colors.grey),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Polling Biasa',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Request berulang sesuai interval berkala.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const Divider(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Interval: ${_pollingIntervalSeconds}s', style: const TextStyle(fontSize: 12)),
                              DropdownButton<int>(
                                value: _pollingIntervalSeconds,
                                isDense: true,
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('1 dtk')),
                                  DropdownMenuItem(value: 2, child: Text('2 dtk')),
                                  DropdownMenuItem(value: 5, child: Text('5 dtk')),
                                ],
                                onChanged: _isPolling
                                    ? null
                                    : (val) {
                                        if (val != null) {
                                          setState(() => _pollingIntervalSeconds = val);
                                        }
                                      },
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          _buildMiniStat('Total Request', '$_pollingCount kali'),
                          _buildMiniStat(
                            'Nilai Terakhir',
                            _pollingData != null
                                ? '#${_pollingData!.counter} (Val: ${_pollingData!.value})'
                                : '-',
                          ),
                          _buildMiniStat('Latensi', '${_pollingLatency}ms'),

                          if (_pollingError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(_pollingError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                            ),

                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: _isPolling ? Colors.red : Colors.blue,
                              ),
                              onPressed: _togglePolling,
                              child: Text(_isPolling ? 'Hentikan Polling' : 'Mulai Polling'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Card 2: Long Polling
                Expanded(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _isLongPolling ? Colors.purple : Colors.grey.shade300,
                        width: _isLongPolling ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.hourglass_bottom, color: _isLongPolling ? Colors.purple : Colors.grey),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Long Polling',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Koneksi ditahan server hingga data baru tersedia.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const Divider(height: 20),

                          Text(
                            _longPollStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: _isLongPolling ? Colors.purple : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _buildMiniStat('Total Request', '$_longPollCount kali'),
                          _buildMiniStat(
                            'Nilai Terakhir',
                            _longPollData != null
                                ? '#${_longPollData!.counter} (Val: ${_longPollData!.value})'
                                : '-',
                          ),
                          _buildMiniStat('Durasi Tahan', '${_longPollWaitedMs}ms'),

                          if (_longPollError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(_longPollError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                            ),

                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: _isLongPolling ? Colors.red : Colors.purple,
                              ),
                              onPressed: _toggleLongPolling,
                              child: Text(_isLongPolling ? 'Hentikan Long Poll' : 'Mulai Long Poll'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Comparison Matrix Table
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tabel Perbandingan Karakteristik',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                      columnWidths: const {
                        0: FlexColumnWidth(1.2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                      },
                      children: const [
                        TableRow(
                          decoration: BoxDecoration(color: Color(0xFFECEFF1)),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Aspek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Polling Biasa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Long Polling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('Request', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Berulang sesuai interval waktu tetap', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Menunggu respons baru, lalu request ulang', style: TextStyle(fontSize: 12))),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('Latensi', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Tergantung interval (rata-rata interval/2)', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Sangat rendah (seketika data tersedia)', style: TextStyle(fontSize: 12))),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('Beban Server', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Banyak request kosong (overhead HTTP header)', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Banyak koneksi idle yang ditahan server', style: TextStyle(fontSize: 12))),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('Implementasi', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Sangat sederhana (cukup timer)', style: TextStyle(fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Perlu manajemen timeout & connection pool', style: TextStyle(fontSize: 12))),
                          ],
                        ),
                      ],
                    ),
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
                'Pertanyaan Analisis Praktikum 2',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan:\nApa yang terjadi jika interval polling diturunkan dari 5 detik menjadi 200 milidetik? Pertimbangkan latensi, penggunaan jaringan, dan beban server.',
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
                          '1. Latensi:\n'
                          '   - Menurun drastis dari maksimal 5.000ms menjadi <=200ms. Aplikasi terasa jauh lebih responsif mendekati real-time.\n\n'
                          '2. Penggunaan Jaringan (Network Overhead):\n'
                          '   - Frekuensi request melonjak 25x lipat (dari 0.2 req/dtk menjadi 5 req/dtk per client).\n'
                          '   - Setiap request HTTP membawa overhead header (500–1000 byte) meskipun payload kosong (tidak ada data baru). Ini memboroskan kuota internet dan baterai perangkat mobile secara signifikan.\n\n'
                          '3. Beban Server (Server Load & Concurrency):\n'
                          '   - Jika terdapat 1.000 pengguna aktif, server harus menangani 5.000 RPS (Request Per Second) dari sebelumnya hanya 200 RPS.\n'
                          '   - Menimbulkan risiko tinggi HTTP connection exhaustion, lonjakan CPU/RAM, dan potensi DoS (Denial of Service) akibat request storming.',
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

  Widget _buildMiniStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
