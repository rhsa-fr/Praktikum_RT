import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/sensor_data.dart';
import '../services/rest_service.dart';

class Praktikum1RestScreen extends StatefulWidget {
  const Praktikum1RestScreen({super.key});

  @override
  State<Praktikum1RestScreen> createState() => _Praktikum1RestScreenState();
}

class _Praktikum1RestScreenState extends State<Praktikum1RestScreen> {
  final RestService _service = RestService();
  final AppConfig _config = AppConfig();
  final TextEditingController _messageController = TextEditingController(text: 'Halo dari Flutter!');

  SensorData? _data;
  bool _isLoadingData = false;
  String? _dataError;
  int? _lastLatencyMs;

  bool _isSendingMessage = false;
  Map<String, dynamic>? _postResponse;
  String? _postError;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingData = true;
      _dataError = null;
    });

    final sw = Stopwatch()..start();
    try {
      final result = await _service.getData();
      sw.stop();
      setState(() {
        _data = result;
        _lastLatencyMs = sw.elapsedMilliseconds;
        _isLoadingData = false;
      });
    } catch (e) {
      sw.stop();
      setState(() {
        _dataError = e.toString();
        _isLoadingData = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSendingMessage = true;
      _postError = null;
    });

    try {
      final res = await _service.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _postResponse = res;
        _isSendingMessage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Pesan "$text" berhasil diterima server (HTTP 200 OK)!'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _postError = e.toString();
        _isSendingMessage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 1 — REST API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Ambil Data Ulang',
            onPressed: _isLoadingData ? null : _fetchData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade800, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Karakteristik Request–Response (HTTP REST)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Koneksi dimulai hanya saat client meminta (GET/POST). Setelah server menjawab, koneksi ditutup. Server tidak dapat mengirim data baru ke client secara mandiri.',
                            style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: GET /api/data
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'GET',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_config.baseUrl}/api/data',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    if (_isLoadingData)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_dataError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _dataError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_data != null)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatTile(
                                  label: 'Counter',
                                  value: '#${_data!.counter}',
                                  icon: Icons.tag,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatTile(
                                  label: 'Random Value',
                                  value: '${_data!.value}',
                                  icon: Icons.speed,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Server Timestamp: ${_data!.timestamp.toLocal()}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                                if (_lastLatencyMs != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${_lastLatencyMs}ms',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Belum ada data. Tekan tombol "Ambil Data (GET)" di bawah.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Ambil Data (GET /api/data)'),
                        onPressed: _isLoadingData ? null : _fetchData,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 2: POST /api/message
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'POST',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_config.baseUrl}/api/message',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _isSendingMessage ? null : _sendMessage(),
                      decoration: InputDecoration(
                        labelText: 'Isi Pesan JSON',
                        hintText: 'Ketik pesan lalu tekan tombol atau Enter...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.send_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _messageController.clear(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        icon: _isSendingMessage
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: const Text('Kirim Pesan (POST)'),
                        onPressed: _isSendingMessage ? null : _sendMessage,
                      ),
                    ),
                    if (_postResponse != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Pesan Sukses Diterima Server (HTTP 200 OK):',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _postResponse.toString(),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_postError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                const SizedBox(width: 6),
                                const Text(
                                  'Gagal Terhubung ke Server Backend:',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _postError!,
                              style: const TextStyle(color: Colors.red, fontSize: 11),
                            ),
                            if (_config.host == 'localhost') ...[
                              const Divider(height: 16),
                              const Text(
                                '💡 Solusi: Jika aplikasi dibuka di Android Emulator, alamat "localhost" mengarah ke HP emulator itu sendiri (bukan ke laptop). Tekan tombol di bawah untuk otomatis mengganti host ke 10.0.2.2:',
                                style: TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
                                icon: const Icon(Icons.swap_horiz, size: 16),
                                label: const Text('Ganti Host ke 10.0.2.2 (Emulator)'),
                                onPressed: () {
                                  setState(() {
                                    _config.updateServer(host: '10.0.2.2', port: _config.port);
                                    _postError = null;
                                  });
                                  _sendMessage();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
                'Pertanyaan Analisis Praktikum 1',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan:\nJika nilai pada server berubah setiap dua detik, apakah tampilan Flutter otomatis berubah jika hanya menggunakan REST API? Mengapa?',
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
                          'Jawaban:\n'
                          'TIDAK, tampilan Flutter TIDAK akan berubah otomatis. '
                          'Alasannya adalah protokol HTTP REST menggunakan paradigma Request–Response yang bersifat stateless dan pull-based (client-initiated). '
                          'Server tidak menyimpan saluran koneksi aktif ke client dan tidak memiliki mekanisme untuk mem-push (mendorong) data perubahan secara proaktif. '
                          'Tampilan Flutter baru akan diperbarui jika client secara eksplisit mengirimkan HTTP GET baru ke server.',
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

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
