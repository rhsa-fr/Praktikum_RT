import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/chat_message.dart';
import '../models/sensor_data.dart';
import '../services/websocket_service.dart';

class Praktikum4WebSocketScreen extends StatefulWidget {
  const Praktikum4WebSocketScreen({super.key});

  @override
  State<Praktikum4WebSocketScreen> createState() => _Praktikum4WebSocketScreenState();
}

class _Praktikum4WebSocketScreenState extends State<Praktikum4WebSocketScreen> {
  final WebSocketService _service = WebSocketService();
  final AppConfig _config = AppConfig();
  final TextEditingController _msgInputController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(text: 'Mahasiswa-1');
  final ScrollController _scrollController = ScrollController();

  WsStatus _status = WsStatus.disconnected;
  final List<ChatMessage> _chatMessages = [];
  SensorData? _latestWsSensorData;

  StreamSubscription? _statusSub;
  StreamSubscription? _chatSub;
  StreamSubscription? _sensorSub;

  @override
  void initState() {
    super.initState();
    _service.currentUsername = _usernameController.text;

    _statusSub = _service.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });

    _chatSub = _service.chatStream.listen((msg) {
      if (mounted) {
        setState(() {
          _chatMessages.add(msg);
        });
        _scrollToBottom();
      }
    });

    _sensorSub = _service.sensorStream.listen((sensor) {
      if (mounted) {
        setState(() => _latestWsSensorData = sensor);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _chatSub?.cancel();
    _sensorSub?.cancel();
    _service.dispose();
    _msgInputController.dispose();
    _usernameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleConnect() {
    if (_status == WsStatus.connected || _status == WsStatus.connecting) {
      _service.disconnect();
    } else {
      _service.currentUsername = _usernameController.text.trim().isEmpty ? 'Mahasiswa' : _usernameController.text.trim();
      _service.connect();
    }
  }

  void _sendMessage() {
    final text = _msgInputController.text.trim();
    if (text.isEmpty) return;
    _service.sendMessage(text);
    _msgInputController.clear();
  }

  void _sendSimulatedPeerMessage() {
    final original = _service.currentUsername;
    _service.currentUsername = 'Mahasiswa-2 (Teman)';
    final quotes = [
      'Halo juga! Pesan ini masuk dari simulasi Client B.',
      'WebSocket benar-benar dua arah (full duplex)!',
      'Koneksi tetap terbuka tanpa handshake ulang.',
      'Sangat cepat, latensinya hanya dalam hitungan milidetik!'
    ];
    final quote = quotes[DateTime.now().second % quotes.length];
    _service.sendMessage(quote);
    _service.currentUsername = original;
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status == WsStatus.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 4 — WebSocket (Dua Arah)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Chat',
            onPressed: () => setState(() => _chatMessages.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                _buildStatusDot(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? 'Terhubung (Full Duplex)' : (_status == WsStatus.error ? 'Koneksi Gagal' : 'Terputus'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isConnected ? Colors.green.shade800 : (_status == WsStatus.error ? Colors.red : Colors.black87),
                        ),
                      ),
                      Text(
                        _config.wsUrl,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 34,
                  child: TextField(
                    controller: _usernameController,
                    enabled: !isConnected,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      labelText: 'Nama Anda',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _service.currentUsername = val,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isConnected ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _toggleConnect,
                  child: Text(isConnected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
          ),

          // Error Banner with Emulator helper
          if (_status == WsStatus.error)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Gagal menghubungkan WebSocket. Di Android Emulator gunakan 10.0.2.2:',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      _config.updateServer(host: '10.0.2.2', port: _config.port);
                      _toggleConnect();
                    },
                    child: const Text('Ganti ke 10.0.2.2', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

          // Sensor Broadcast Ticker
          if (_latestWsSensorData != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.sensors, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    'Server Broadcast: Counter #${_latestWsSensorData!.counter} | Nilai: ${_latestWsSensorData!.value}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                  ),
                  const Spacer(),
                  Text(
                    '${_latestWsSensorData!.timestamp.toLocal().second}s',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),

          // Chat Messages List
          Expanded(
            child: _chatMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          isConnected
                              ? 'Koneksi aktif! Kirim pesan untuk menguji broadcast dua arah.'
                              : 'Tekan Connect di atas untuk membuka koneksi WebSocket.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _chatMessages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),

          // Chat Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                  child: Text(
                    'Perbedaan Mendasar WebSocket vs HTTP REST:\n'
                    '1. State Koneksi: HTTP REST bersifat Stateless (koneksi ditutup tiap selesai request-response), sedangkan WebSocket Stateful (koneksi TCP tetap terbuka/persistent).\n'
                    '2. Mode Komunikasi: HTTP REST adalah Half-Duplex (pull), WebSocket adalah Full-Duplex (client dan server dapat saling kirim kapan saja secara independen).\n'
                    '3. Overhead Protokol: Setelah handshake awal (HTTP 101 Switching Protocols), frame data WebSocket hanya berukuran 2–10 byte overhead tanpa HTTP header ratusan byte, sehingga sangat hemat bandwidth untuk streaming frekuensi tinggi.',
                    style: TextStyle(fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.type == 'system') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg.message,
            style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final isMe = msg.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isMe ? const Radius.circular(14) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(14),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.sender,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.indigo.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              msg.message,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}:${msg.timestamp.second.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 9,
                color: isMe ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot() {
    Color color;
    switch (_status) {
      case WsStatus.connected:
        color = Colors.green;
        break;
      case WsStatus.connecting:
        color = Colors.amber;
        break;
      case WsStatus.error:
        color = Colors.red;
        break;
      case WsStatus.disconnected:
        color = Colors.grey;
        break;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

