import 'package:flutter/material.dart';

class Praktikum8FcmScreen extends StatefulWidget {
  const Praktikum8FcmScreen({super.key});

  @override
  State<Praktikum8FcmScreen> createState() => _Praktikum8FcmScreenState();
}

class _Praktikum8FcmScreenState extends State<Praktikum8FcmScreen> {
  final TextEditingController _titleController = TextEditingController(text: 'Peringatan Sensor Suhu!');
  final TextEditingController _bodyController = TextEditingController(text: 'Suhu ruangan server melebihi 35°C segera periksa!');
  final TextEditingController _extraDataKey = TextEditingController(text: 'sensor_id');
  final TextEditingController _extraDataVal = TextEditingController(text: 'ESP32_SRV_01');

  String _fcmToken = 'dKj8a9Z...fcm_mock_token_39a82bb...X0q9';
  bool _isGeneratingToken = false;
  final List<Map<String, dynamic>> _simulatedNotifications = [];

  void _generateNewToken() async {
    setState(() => _isGeneratingToken = true);
    await Future.delayed(const Duration(milliseconds: 700));
    final randHex = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    setState(() {
      _fcmToken = 'fcm_token_flutter_${randHex}_ak99z7';
      _isGeneratingToken = false;
    });
  }

  void _simulatePush({required bool isForeground}) {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final notif = {
      'title': title.isEmpty ? 'Notifikasi Masuk' : title,
      'body': body.isEmpty ? 'Isi notifikasi...' : body,
      'data': {
        _extraDataKey.text.trim(): _extraDataVal.text.trim(),
      },
      'mode': isForeground ? 'Foreground (Aplikasi Terbuka)' : 'Background (System Notification Tray)',
      'timestamp': DateTime.now(),
    };

    setState(() {
      _simulatedNotifications.insert(0, notif);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isForeground ? Colors.indigo : Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(isForeground ? Icons.notifications_active : Icons.system_update_alt, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isForeground
                    ? 'Foreground In-App Banner: $title'
                    : 'System Tray Notification: $title',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _extraDataKey.dispose();
    _extraDataVal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 8 — Push Notification (FCM)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Log',
            onPressed: () => setState(() => _simulatedNotifications.clear()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Architectural Concept Header
            Card(
              color: Colors.amber.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.amber.shade900, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Firebase Cloud Messaging (FCM)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Push notification memanfaatkan gateway OS (Google Play Services di Android / APNs di iOS). Aplikasi dapat menerima notifikasi meskipun sedang di latar belakang atau dalam keadaan tertutup (terminated).',
                            style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FCM Token Section
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
                          'FCM Device Registration Token',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        TextButton.icon(
                          icon: _isGeneratingToken
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh Token'),
                          onPressed: _isGeneratingToken ? null : _generateNewToken,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SelectableText(
                        _fcmToken,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Token ini dikirimkan ke server backend Anda untuk menargetkan perangkat ini secara spesifik.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Simulation Dispatcher
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Simulasi Pengiriman Push Notification:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Notifikasi (notification.title)',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Isi Pesan (notification.body)',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _extraDataKey,
                            decoration: const InputDecoration(
                              labelText: 'Data Key',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _extraDataVal,
                            decoration: const InputDecoration(
                              labelText: 'Data Value',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.touch_app),
                            label: const Text('Simulasi Foreground'),
                            onPressed: () => _simulatePush(isForeground: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.system_security_update),
                            label: const Text('Simulasi System Tray'),
                            style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
                            onPressed: () => _simulatePush(isForeground: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Received Notifications List
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
                        const Text('Riwayat Notifikasi Diterima:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${_simulatedNotifications.length} diterima', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const Divider(height: 16),

                    if (_simulatedNotifications.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Belum ada notifikasi uji. Tekan tombol simulasi di atas.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _simulatedNotifications.length.clamp(0, 5),
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (context, idx) {
                          final item = _simulatedNotifications[idx];
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.mark_email_read, size: 16, color: Colors.blue.shade700),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item['title'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['mode'] as String,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(item['body'] as String, style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  'Payload Data: ${item['data']}',
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blueGrey),
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

            // Security Best Practice
            Card(
              color: Colors.red.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.security, color: Colors.red),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Penting: Praktik Keamanan FCM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
                          SizedBox(height: 4),
                          Text(
                            'JANGAN PERNAH menyimpan Server Key atau Service Account Private Key Firebase di dalam kode aplikasi Flutter! Client hanya bertugas menerima token dan mendengarkan event. Pengiriman notifikasi wajib dieksekusi melalui backend tepercaya.',
                            style: TextStyle(fontSize: 11, color: Colors.red, height: 1.3),
                          ),
                        ],
                      ),
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
                'Pertanyaan Analisis Praktikum 8',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan:\nMengapa push notification tidak menjamin pembaruan data seketika seperti aliran WebSocket yang aktif?',
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
                          'Push notification tidak menjamin pengiriman instan/seketika karena alasan fundamental berikut:\n\n'
                          '1. Jaminan Pengiriman Best-Effort & Pengaruh Gateway Pihak Ketiga:\n'
                          '   - Pesan push tidak dikirim langsung dari server Anda ke perangkat. Pesan harus melalui gateway perantara (Google FCM / Apple APNs).\n'
                          '   - Gateway ini dapat menunda, mengelompokkan (batching), atau menurunkan prioritas pesan push tergantung status jaringan global.\n\n'
                          '2. Penghematan Baterai & Power Management OS (Doze Mode):\n'
                          '   - Sistem operasi Android (Doze Mode & App Standby) serta iOS secara aktif menidurkan koneksi radio jaringan untuk menghemat baterai saat perangkat diam atau layar mati.\n'
                          '   - Notifikasi push reguler hanya dilewatkan saat OS membuka maintenance window berkala, bukan seketika saat event terjadi.\n\n'
                          '3. Desain Kegunaan (Alerting vs Live Streaming):\n'
                          '   - Push Notification dirancang untuk notifikasi penting (misal: "Ada chat baru!", "Alarm berbunyi!") untuk memicu atensi pengguna atau membangunkan aplikasi.\n'
                          '   - Sebaliknya, WebSocket mempertahankan koneksi TCP soket terbuka secara terus-menerus (active socket) dengan latency milidetik untuk transmisi data frekuensi tinggi.',
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
}
