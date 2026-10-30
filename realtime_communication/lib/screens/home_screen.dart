import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'praktikum1_rest_screen.dart';
import 'praktikum2_polling_screen.dart';
import 'praktikum3_sse_screen.dart';
import 'praktikum4_websocket_screen.dart';
import 'praktikum5_mqtt_screen.dart';
import 'praktikum6_webrtc_screen.dart';
import 'praktikum7_grpc_screen.dart';
import 'praktikum8_fcm_screen.dart';
import 'analysis_questions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppConfig _config = AppConfig();
  bool _isCheckingServer = false;
  bool? _isServerOnline;
  String? _serverCheckMsg;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
  }

  Future<void> _checkServerStatus() async {
    setState(() {
      _isCheckingServer = true;
      _serverCheckMsg = null;
    });

    try {
      final response = await http
          .get(Uri.parse('${_config.baseUrl}/api/data'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isServerOnline = true;
          _serverCheckMsg = 'Online (Counter: #${data['counter']})';
          _isCheckingServer = false;
        });
      } else {
        setState(() {
          _isServerOnline = false;
          _serverCheckMsg = 'Server respons status ${response.statusCode}';
          _isCheckingServer = false;
        });
      }
    } catch (e) {
      setState(() {
        _isServerOnline = false;
        _serverCheckMsg = 'Server offline / tidak terjangkau';
        _isCheckingServer = false;
      });
    }
  }

  void _showConfigDialog() {
    final hostController = TextEditingController(text: _config.host);
    final portController = TextEditingController(text: _config.port.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfigurasi Alamat Server'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sesuaikan host server backend sesuai platform pengujian Anda:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Host / IP Address',
                  hintText: 'localhost atau 10.0.2.2 atau 192.168.x.x',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port Backend',
                  hintText: '3000',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: [
                  ActionChip(
                    label: const Text('localhost (Desktop/Web)', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      hostController.text = 'localhost';
                      portController.text = '3000';
                    },
                  ),
                  ActionChip(
                    label: const Text('10.0.2.2 (Android Emulator)', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      hostController.text = '10.0.2.2';
                      portController.text = '3000';
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final newHost = hostController.text.trim();
                final newPort = int.tryParse(portController.text.trim()) ?? 3000;
                if (newHost.isNotEmpty) {
                  _config.updateServer(host: newHost, port: newPort);
                  Navigator.pop(context);
                  _checkServerStatus();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Praktikum 1 — REST API',
        'subtitle': 'Request–Response (HTTP GET & POST)',
        'icon': Icons.swap_horiz,
        'color': Colors.blue,
        'badge': 'Stateless',
        'screen': const Praktikum1RestScreen(),
      },
      {
        'title': 'Praktikum 2 — Polling & Long Polling',
        'subtitle': 'Perbandingan Interval vs Held Connection',
        'icon': Icons.hourglass_bottom,
        'color': Colors.purple,
        'badge': 'Periodic / Held',
        'screen': const Praktikum2PollingScreen(),
      },
      {
        'title': 'Praktikum 3 — Server-Sent Events',
        'subtitle': 'Aliran data satu arah dari server (SSE)',
        'icon': Icons.stream,
        'color': Colors.teal,
        'badge': 'Satu Arah',
        'screen': const Praktikum3SseScreen(),
      },
      {
        'title': 'Praktikum 4 — WebSocket',
        'subtitle': 'Komunikasi dua arah & Broadcast Chat',
        'icon': Icons.forum,
        'color': Colors.indigo,
        'badge': 'Dua Arah',
        'screen': const Praktikum4WebSocketScreen(),
      },
      {
        'title': 'Praktikum 5 — MQTT',
        'subtitle': 'Publish–Subscribe Broker untuk IoT Sensor',
        'icon': Icons.sensors,
        'color': Colors.deepOrange,
        'badge': 'Pub–Sub',
        'screen': const Praktikum5MqttScreen(),
      },
      {
        'title': 'Praktikum 6 — WebRTC',
        'subtitle': 'Signaling, SDP, ICE & DataChannel P2P',
        'icon': Icons.video_call,
        'color': Colors.cyan.shade800,
        'badge': 'Peer-to-Peer',
        'screen': const Praktikum6WebRtcScreen(),
      },
      {
        'title': 'Praktikum 7 — gRPC Streaming',
        'subtitle': 'Protocol Buffers & 4 Pola Streaming RPC',
        'icon': Icons.bolt,
        'color': Colors.green.shade800,
        'badge': 'Binary Stream',
        'screen': const Praktikum7GrpcScreen(),
      },
      {
        'title': 'Praktikum 8 — Push Notification',
        'subtitle': 'Firebase Cloud Messaging (FCM Lifecycle)',
        'icon': Icons.notifications_active,
        'color': Colors.amber.shade900,
        'badge': 'Notifikasi OS',
        'screen': const Praktikum8FcmScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Communication'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Konfigurasi IP Server',
            onPressed: _showConfigDialog,
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Jawaban Analisis 1–8',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalysisQuestionsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Status Banner
            ListenableBuilder(
              listenable: _config,
              builder: (context, _) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _isServerOnline == true
                          ? Colors.green.shade300
                          : _isServerOnline == false
                              ? Colors.red.shade300
                              : Colors.grey.shade300,
                    ),
                  ),
                  color: _isServerOnline == true
                      ? Colors.green.shade50
                      : _isServerOnline == false
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isServerOnline == true
                                ? Colors.green
                                : _isServerOnline == false
                                    ? Colors.red
                                    : Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Server Backend: ${_config.baseUrl}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: _showConfigDialog,
                                    child: const Icon(Icons.edit, size: 14, color: Colors.blue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isCheckingServer
                                    ? 'Memeriksa status server...'
                                    : (_serverCheckMsg ?? 'Status belum dicek'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isServerOnline == true ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: _isCheckingServer
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.refresh, size: 20),
                          tooltip: 'Cek Ulang Server',
                          onPressed: _isCheckingServer ? null : _checkServerStatus,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Master Questions Banner
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalysisQuestionsScreen()),
                );
              },
              child: Card(
                elevation: 2,
                color: Colors.purple.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jawaban Lengkap Pertanyaan Analisis',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Kompilasi jawaban akademis pertanyaan Praktikum 1 sampai 8 beserta matriks perbandingan komprehensif.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Modul Praktikum:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Modules List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = modules[index];
                final color = item['color'] as Color;

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData, color: color),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(item['subtitle'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

