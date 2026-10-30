import 'package:flutter/material.dart';

class Praktikum6WebRtcScreen extends StatefulWidget {
  const Praktikum6WebRtcScreen({super.key});

  @override
  State<Praktikum6WebRtcScreen> createState() => _Praktikum6WebRtcScreenState();
}

class _Praktikum6WebRtcScreenState extends State<Praktikum6WebRtcScreen> {
  int _currentStep = 0;
  bool _isP2pConnected = false;
  final TextEditingController _p2pMsgController = TextEditingController(text: 'Halo Peer B! Pesan P2P via SCTP');
  final List<String> _p2pLogs = [];

  final List<Map<String, String>> _stepsInfo = [
    {
      'title': '1. Inisialisasi Media & DataChannel',
      'desc': 'Peer A meminta izin kamera/mic (getUserMedia) atau membuka RTCDataChannel untuk data teks/binary.',
    },
    {
      'title': '2. Create SDP Offer (Peer A)',
      'desc': 'Peer A menghasilkan Session Description Protocol (SDP) Offer yang berisi metadata codec (H.264/VP8, Opus) dan profil enkripsi.',
    },
    {
      'title': '3. Signaling Server Relay',
      'desc': 'SDP Offer dikirim ke Signaling Server (misal via WebSocket), lalu diteruskan ke Peer B.',
    },
    {
      'title': '4. Create SDP Answer (Peer B)',
      'desc': 'Peer B menerima offer, mengatur remote description, lalu membuat SDP Answer dan mengirimkannya kembali via signaling server.',
    },
    {
      'title': '5. ICE Candidate Gathering (STUN/TURN)',
      'desc': 'Kedua peer menghubungi STUN server untuk menemukan alamat IP publik dan port di balik NAT/Firewall.',
    },
    {
      'title': '6. P2P Connection Established (Direct Stream)',
      'desc': 'Koneksi peer-to-peer terbentuk langsung! Aliran audio/video mengalir melalui SRTP dan data via SCTP tanpa melewati server aplikasi.',
    },
  ];

  void _nextStep() {
    if (_currentStep < _stepsInfo.length - 1) {
      setState(() {
        _currentStep++;
        if (_currentStep == _stepsInfo.length - 1) {
          _isP2pConnected = true;
          _p2pLogs.insert(0, '[Sistem] Kanal P2P DataChannel berhasil terhubung langsung!');
        }
      });
    }
  }

  void _resetSteps() {
    setState(() {
      _currentStep = 0;
      _isP2pConnected = false;
      _p2pLogs.clear();
    });
  }

  void _sendP2pMessage() {
    final text = _p2pMsgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _p2pLogs.insert(
        0,
        '[P2P Langsung] DataChannel: "$text" (Bypassed server, direct SCTP over UDP)',
      );
    });
    _p2pMsgController.clear();
  }

  @override
  void dispose() {
    _p2pMsgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 6 — WebRTC (Peer-to-Peer)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Conceptual Banner
            Card(
              color: Colors.indigo.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.indigo.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.video_call, color: Colors.indigo.shade800, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arsitektur WebRTC (Audio, Video & Data)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'WebRTC menghubungkan dua browser atau perangkat secara langsung (Peer-to-Peer). Server hanya bertindak sebagai "Signaling" di awal untuk pertukaran metadata (SDP & ICE Candidates).',
                            style: TextStyle(color: Colors.indigo.shade900, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Simulator
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
                          'Simulasi Alur Handshake & Koneksi P2P',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset Alur'),
                          onPressed: _resetSteps,
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    // Visual Progress Tracker
                    Row(
                      children: List.generate(_stepsInfo.length, (index) {
                        final isPassed = index <= _currentStep;
                        return Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isPassed ? Colors.green : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Current Step Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isP2pConnected ? Colors.green.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isP2pConnected ? Colors.green.shade300 : Colors.blue.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isP2pConnected ? Icons.check_circle : Icons.swap_horiz,
                                color: _isP2pConnected ? Colors.green : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _stepsInfo[_currentStep]['title']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _isP2pConnected ? Colors.green.shade900 : Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _stepsInfo[_currentStep]['desc']!,
                            style: const TextStyle(fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: Icon(_isP2pConnected ? Icons.done_all : Icons.arrow_forward),
                        label: Text(_isP2pConnected ? 'P2P Sudah Terhubung' : 'Lanjutkan Tahap Berikutnya'),
                        onPressed: _isP2pConnected ? null : _nextStep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // P2P Direct DataChannel Message Tester
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
                        Icon(Icons.bolt, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Uji DataChannel P2P Langsung',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isP2pConnected
                          ? 'Kanal P2P aktif! Data yang dikirim di bawah ini langsung menuju Peer B tanpa transit di server backend.'
                          : 'Selesaikan 6 tahap handshake di atas agar DataChannel terbuka.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _p2pMsgController,
                            enabled: _isP2pConnected,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Ketik pesan P2P...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _isP2pConnected ? _sendP2pMessage : null,
                          child: const Text('Kirim P2P'),
                        ),
                      ],
                    ),
                    if (_p2pLogs.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        height: 90,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListView.builder(
                          itemCount: _p2pLogs.length,
                          itemBuilder: (context, i) => Text(
                            _p2pLogs[i],
                            style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Code Implementation Guide
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Langkah Integrasi di Flutter (flutter_webrtc):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 8),
                    Text(
                      '1. Tambahkan paket: flutter pub add flutter_webrtc\n'
                      '2. Minta izin kamera & mikrofon di AndroidManifest / Info.plist\n'
                      '3. Buat konfigurasi ICE Servers: {"iceServers": [{"urls": "stun:stun.l.google.com:19302"}]}\n'
                      '4. Inisialisasi: RTCPeerConnection connection = await createPeerConnection(configuration)\n'
                      '5. Tangkap media: MediaStream stream = await navigator.mediaDevices.getUserMedia({"audio": true, "video": true})\n'
                      '6. Pasang renderer: RTCVideoRenderer localRenderer = RTCVideoRenderer(); await localRenderer.initialize();',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
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
                'Pertanyaan Analisis Praktikum 6',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertanyaan:\nMengapa WebRTC lebih tepat untuk video call dibandingkan mengirim gambar kamera berulang kali melalui REST API?',
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
                          '1. Kompresi & Codec Video Khusus (H.264 / VP8 / VP9 / AV1):\n'
                          '   - Mengirim gambar JPEG berulang kali via REST API menghasilkan ukuran 50KB–200KB per frame. Pada 30 FPS, bandwidth melonjak hingga puluhan megabyte per detik!\n'
                          '   - WebRTC menggunakan video codec modern dengan kompresi antar-frame (inter-frame delta / I-frames & P-frames), memangkas bandwidth hingga 95%.\n\n'
                          '2. Transport UDP vs TCP (Latensi Sub-100ms):\n'
                          '   - REST API berjalan di atas HTTP/TCP. Jika 1 paket frame hilang di jaringan, TCP akan menahan seluruh frame selanjutnya (Head-of-Line Blocking) sampai paket hilang di-retransmit, menyebabkan lag parah.\n'
                          '   - WebRTC menggunakan SRTP di atas UDP. Jika frame hilang sedikit, frame dilewati dan audio/video tetap berjalan lancar secara real-time.\n\n'
                          '3. Peer-to-Peer (Beban Server Ringan & Privasi):\n'
                          '   - REST API mewajibkan semua video dikirim ke server terlebih dahulu, lalu diunduh oleh client lain (beban bandwidth server sangat tinggi).\n'
                          '   - WebRTC mengalir langsung antar perangkat pengguna (P2P), menghemat biaya server dan menjamin enkripsi end-to-end.',
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
