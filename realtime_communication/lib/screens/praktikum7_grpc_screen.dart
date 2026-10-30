import 'dart:async';
import 'package:flutter/material.dart';

class Praktikum7GrpcScreen extends StatefulWidget {
  const Praktikum7GrpcScreen({super.key});

  @override
  State<Praktikum7GrpcScreen> createState() => _Praktikum7GrpcScreenState();
}

class _Praktikum7GrpcScreenState extends State<Praktikum7GrpcScreen> {
  int _selectedPattern = 1; // 0: Unary, 1: Server Streaming, 2: Client Streaming, 3: Bidirectional
  bool _isSimulating = false;
  final List<String> _simLogs = [];

  final List<Map<String, dynamic>> _patterns = [
    {
      'title': 'Unary RPC',
      'signature': 'rpc GetLatest (SensorRequest) returns (SensorReading);',
      'desc': 'Satu request, satu response (mirip REST API tapi terkompresi biner via HTTP/2).',
      'icon': Icons.swap_horiz,
    },
    {
      'title': 'Server Streaming',
      'signature': 'rpc WatchSensor (SensorRequest) returns (stream SensorReading);',
      'desc': 'Client mengirim 1 request, server mengirim aliran tak terbatas pesan data sensor berkelanjutan.',
      'icon': Icons.stream,
    },
    {
      'title': 'Client Streaming',
      'signature': 'rpc UploadBatch (stream SensorReading) returns (UploadSummary);',
      'desc': 'Client mengirim rentetan pesan berkala, server memberikan 1 respons rangkuman akhir.',
      'icon': Icons.upload_file,
    },
    {
      'title': 'Bidirectional Streaming',
      'signature': 'rpc LiveControl (stream ControlCommand) returns (stream SensorState);',
      'desc': 'Kedua sisi mengirim aliran pesan independen secara bersamaan melalui satu koneksi HTTP/2.',
      'icon': Icons.compare_arrows,
    },
  ];

  Future<void> _runSimulation() async {
    setState(() {
      _isSimulating = true;
      _simLogs.clear();
    });

    switch (_selectedPattern) {
      case 0: // Unary
        _addSimLog('[Client -> Server] Mengirim SensorRequest(device_id: "DEV-01")');
        await Future.delayed(const Duration(milliseconds: 600));
        _addSimLog('[Server -> Client] Menerima SensorReading(device_id: "DEV-01", value: 34.2, timestamp: ${DateTime.now().millisecondsSinceEpoch})');
        break;

      case 1: // Server Streaming
        _addSimLog('[Client -> Server] Inisiasi WatchSensor(device_id: "DEV-01"). Menunggu streaming...');
        for (int i = 1; i <= 5; i++) {
          await Future.delayed(const Duration(milliseconds: 700));
          if (!mounted) return;
          _addSimLog('[Server Stream #$i] SensorReading(value: ${(25.0 + i * 1.5).toStringAsFixed(1)}, timestamp: ${DateTime.now().millisecondsSinceEpoch})');
        }
        break;

      case 2: // Client Streaming
        _addSimLog('[Client Streaming] Membuka channel upload batch data sensor...');
        for (int i = 1; i <= 4; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          _addSimLog('[Client Stream #$i] Mengunggah paket log sensor #$i (18 bytes binary Protobuf)...');
        }
        await Future.delayed(const Duration(milliseconds: 600));
        _addSimLog('[Server -> Client] UploadSummary(total_received: 4, status: "SUCCESS_BATCH_ACK")');
        break;

      case 3: // Bidirectional Streaming
        _addSimLog('[Bidi Channel] Kanal dua arah HTTP/2 aktif.');
        _addSimLog('[Client -> Server] Kirim Ping / Control Command: SET_RATE_500MS');
        await Future.delayed(const Duration(milliseconds: 500));
        _addSimLog('[Server -> Client] Balasan Stream: SensorState(rate: 500ms, active: true)');
        await Future.delayed(const Duration(milliseconds: 600));
        _addSimLog('[Server -> Client] Balasan Stream: SensorState(value: 88.4, rpm: 1200)');
        await Future.delayed(const Duration(milliseconds: 500));
        _addSimLog('[Client -> Server] Kirim Control Command: ACK_STATE');
        break;
    }

    if (mounted) {
      setState(() => _isSimulating = false);
    }
  }

  void _addSimLog(String log) {
    if (mounted) {
      setState(() {
        _simLogs.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $log');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pattern = _patterns[_selectedPattern];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 7 — gRPC Streaming'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Card(
              color: Colors.teal.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.teal.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.teal.shade800, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'gRPC & Protocol Buffers (Protobuf)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'gRPC menggunakan HTTP/2 multiplexing dan serialisasi biner Protobuf yang jauh lebih kecil, cepat, dan strictly-typed dibandingkan JSON HTTP/1.1.',
                            style: TextStyle(color: Colors.teal.shade900, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pattern Selection Tabs
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih 4 Pola Komunikasi gRPC:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_patterns.length, (idx) {
                        final isSel = _selectedPattern == idx;
                        return ChoiceChip(
                          avatar: Icon(_patterns[idx]['icon'] as IconData, size: 16),
                          label: Text(_patterns[idx]['title'] as String),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedPattern = idx;
                                _simLogs.clear();
                              });
                            }
                          },
                        );
                      }),
                    ),
                    const Divider(height: 24),

                    // Active Pattern Detail
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pattern['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pattern['desc'] as String,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pattern['signature'] as String,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.lightGreenAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: _isSimulating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.play_arrow),
                        label: Text(_isSimulating ? 'Sedang Streaming Paket...' : 'Jalankan Simulasi Pola Ini'),
                        onPressed: _isSimulating ? null : _runSimulation,
                      ),
                    ),

                    if (_simLogs.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _simLogs.length,
                          itemBuilder: (ctx, i) => Text(
                            _simLogs[i],
                            style: const TextStyle(color: Color(0xFF64FFDA), fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Protocol Buffers Definition Display
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Definisi Schema (monitoring.proto):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 8),
                    Text(
                      'syntax = "proto3";\n'
                      'package monitoring;\n\n'
                      'service SensorService {\n'
                      '  rpc GetLatest (SensorRequest) returns (SensorReading);        // Unary\n'
                      '  rpc WatchSensor (SensorRequest) returns (stream SensorReading); // Server Streaming\n'
                      '}\n\n'
                      'message SensorRequest {\n'
                      '  string device_id = 1;\n'
                      '}\n\n'
                      'message SensorReading {\n'
                      '  string device_id = 1;\n'
                      '  double value = 2;\n'
                      '  int64 timestamp = 3;\n'
                      '}',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.35),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comparison: Protobuf vs JSON
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Protobuf (gRPC) vs JSON (REST API)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildCompareRow('Format Data', 'Biner terkompresi (sangat kecil)', 'Teks string berulang (verbose)'),
                    _buildCompareRow('Transport', 'HTTP/2 (Multiplexing stream)', 'HTTP/1.1 (Satu req per TCP stream)'),
                    _buildCompareRow('Ukuran Pesan', 'Rata-rata 15–25 Bytes', 'Rata-rata 80–120 Bytes (4-5x lebih besar)'),
                    _buildCompareRow('Type Safety', 'Ketat dari file .proto compiler', 'Rentan typo & runtime type mismatch'),
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
                'Pertanyaan Analisis Praktikum 7',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan:\nDalam sistem monitoring yang mengirim ribuan pembaruan terstruktur, kapan gRPC streaming dapat lebih sesuai dibandingkan REST API?',
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
                          'gRPC Streaming LEBIH SESUAI dibandingkan REST API pada kondisi-kondisi berikut:\n\n'
                          '1. Throughput Sangat Tinggi (Ribuan Update Per Detik):\n'
                          '   - Pada REST API, setiap update memerlukan request HTTP baru dengan TCP handshake dan ribuan byte header berulang.\n'
                          '   - gRPC Server Streaming membuka 1 koneksi HTTP/2 persistent dan terus memompa data biner tanpa overhead header berulang.\n\n'
                          '2. Efisiensi Bandwidth & CPU (Serialization Performance):\n'
                          '   - Serialisasi biner Protocol Buffers 5x hingga 10x lebih cepat daripada parsing string JSON (`jsonDecode` di Dart/Flutter memakan resource memori).\n'
                          '   - Ukuran payload Protobuf berkurang 60%–80% dibandingkan JSON, sangat krusial jika memproses data jutaan sensor pabrik atau telemetri kendaraan.\n\n'
                          '3. Komunikasi Antar Microservice (Backend-to-Backend):\n'
                          '   - Sangat ideal untuk menghubungkan Ingestion Pipeline, Kafka Consumer, atau dashboard backend internal yang membutuhkan kontrak tipe data (code generation) yang 100% konsisten antar bahasa pemrograman (Go, Java, Python, Dart).',
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

  Widget _buildCompareRow(String aspect, String grpcVal, String restVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(aspect, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          Expanded(
            child: Text(grpcVal, style: TextStyle(fontSize: 11, color: Colors.teal.shade800, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(restVal, style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700)),
          ),
        ],
      ),
    );
  }
}
