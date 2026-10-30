import 'package:flutter/material.dart';

class AnalysisQuestionsScreen extends StatelessWidget {
  const AnalysisQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rangkuman & Jawaban Analisis Praktikum 1–8'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Master Comparison Matrix Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.table_chart, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          'Matriks Perbandingan 8 Teknologi Komunikasi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                        dataRowMinHeight: 36,
                        dataRowMaxHeight: 52,
                        columns: const [
                          DataColumn(label: Text('Teknologi', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Arah', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('State', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Transport', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Overhead', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Latensi Khas', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Kasus Penggunaan Terbaik', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('REST API', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Req - Resp')),
                            DataCell(Text('Stateless')),
                            DataCell(Text('HTTP/1.1 TCP')),
                            DataCell(Text('Tinggi (500B-1KB)')),
                            DataCell(Text('100 - 500 ms')),
                            DataCell(Text('CRUD, Auth, Profil Pengguna, Form')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Polling', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Req - Resp berulang')),
                            DataCell(Text('Stateless')),
                            DataCell(Text('HTTP TCP')),
                            DataCell(Text('Sangat Boros')),
                            DataCell(Text('Tergantung Interval')),
                            DataCell(Text('Solusi cepat pembaruan berkala interval longgar')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Long Polling', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Held Request')),
                            DataCell(Text('Semi-Stateful')),
                            DataCell(Text('HTTP TCP')),
                            DataCell(Text('Sedang')),
                            DataCell(Text('Rendah saat ada data')),
                            DataCell(Text('Fallback jika WebSocket/SSE tidak didukung proxy')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('SSE (Server-Sent Events)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Satu Arah (Server -> Client)')),
                            DataCell(Text('Stateful (HTTP Stream)')),
                            DataCell(Text('HTTP/1.1 or HTTP/2')),
                            DataCell(Text('Rendah')),
                            DataCell(Text('< 50 ms')),
                            DataCell(Text('Dashboard Monitoring, Live Score, Status Job, Log')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('WebSocket', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Dua Arah (Full Duplex)')),
                            DataCell(Text('Stateful')),
                            DataCell(Text('TCP Socket (ws/wss)')),
                            DataCell(Text('Sangat Ringan (2-10 Byte)')),
                            DataCell(Text('< 20 ms')),
                            DataCell(Text('Live Chat, Game Multiplayer, Dokumen Kolaborasi')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('MQTT', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Pub / Sub Broker')),
                            DataCell(Text('Stateful')),
                            DataCell(Text('TCP / WebSocket')),
                            DataCell(Text('Sangat Ringan (2 Byte)')),
                            DataCell(Text('< 30 ms')),
                            DataCell(Text('IoT Sensor (ESP32/Arduino), Telemetri Kendaraan')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('WebRTC', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Peer-to-Peer (P2P)')),
                            DataCell(Text('Direct Session')),
                            DataCell(Text('UDP / SRTP / SCTP')),
                            DataCell(Text('Sangat Efisien')),
                            DataCell(Text('< 10 ms (Sub-100ms Media)')),
                            DataCell(Text('Video Call, Voice Chat, P2P File Sharing')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('gRPC Streaming', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Unary / Bi-di Stream')),
                            DataCell(Text('Stateful Multiplex')),
                            DataCell(Text('HTTP/2 Protobuf')),
                            DataCell(Text('Minimal (Biner)')),
                            DataCell(Text('< 10 ms')),
                            DataCell(Text('Komunikasi Microservices, Ingestion High-throughput')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('FCM Push Notification', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Server -> Gateway -> OS')),
                            DataCell(Text('Asynchronous Push')),
                            DataCell(Text('OS Push Service')),
                            DataCell(Text('Ringan')),
                            DataCell(Text('Detik - Menit (Best effort)')),
                            DataCell(Text('Notifikasi Pesan Baru, Promosi, Wake-up Alarm')),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Question 1
            _buildQuestionCard(
              number: 1,
              title: 'REST API & Request-Response',
              question: 'Jika nilai pada server berubah setiap dua detik, apakah tampilan Flutter otomatis berubah jika hanya menggunakan REST API? Mengapa?',
              answer:
                  'TIDAK, tampilan Flutter tidak akan berubah secara otomatis.\n\n'
                  'Alasan:\n'
                  '1. Sifat Pull-Based (Client-Initiated): Protokol HTTP REST bekerja dengan pola request-response yang sepenuhnya dikendalikan oleh client. Server bertindak pasif yang hanya merespons saat dipanggil.\n'
                  '2. Stateless Connection: Begitu server selesai mengirimkan respons HTTP 200 OK dengan body JSON, koneksi TCP langsung ditutup (atau idle pada connection pool). Server tidak memiliki referensi saluran untuk "mendorong" (push) data baru ke Flutter ketika nilainya berubah di memori backend.\n'
                  '3. Tampilan Flutter hanya akan berubah apabila client secara proaktif memicu request GET baru (misalnya pengguna menekan tombol refresh).',
            ),
            const SizedBox(height: 12),

            // Question 2
            _buildQuestionCard(
              number: 2,
              title: 'Polling vs Long Polling',
              question: 'Apa yang terjadi jika interval polling diturunkan dari 5 detik menjadi 200 milidetik? Pertimbangkan latensi, penggunaan jaringan, dan beban server.',
              answer:
                  'Konsekuensi teknis penurunan interval ke 200 milidetik:\n\n'
                  '1. Latensi:\n'
                  '   - Latensi persepsi data menurun drastis dari maksimal 5.000 ms menjadi maksimal 200 ms. Aplikasi terlihat sangat responsif mendekati real-time.\n\n'
                  '2. Penggunaan Jaringan (Network Bandwidth & Battery Drain):\n'
                  '   - Terjadi lonjakan 25 kali lipat dalam jumlah paket data (dari 0.2 req/detik menjadi 5 req/detik).\n'
                  '   - Mengingat sebagian besar respons akan bernilai sama (karena server hanya update setiap 2 detik), 90% paket jaringan membawa data mubazir (redundant data).\n'
                  '   - Setiap request mengirim overhead HTTP header (sekitar 500–1000 byte per request), yang akan menguras kuota internet dan membuat baterai smartphone cepat habis karena radio seluler/WiFi terus aktif pada mode high-power state.\n\n'
                  '3. Beban Server (Server CPU, RAM & Concurrency):\n'
                  '   - Pada skala 1.000 pengguna aktif, server menerima 5.000 Request Per Second (RPS) dari sebelumnya hanya 200 RPS.\n'
                  '   - Server berisiko mengalami kehabisan socket descriptor, penumpukan thread/event loop, dan ancaman crash (DoS) yang tidak disengaja.',
            ),
            const SizedBox(height: 12),

            // Question 3
            _buildQuestionCard(
              number: 3,
              title: 'Server-Sent Events (SSE)',
              question: 'Mengapa SSE menarik untuk dashboard monitoring, tetapi bukan pilihan utama untuk komunikasi audio/video dua arah?',
              answer:
                  '1. Mengapa SSE Menarik untuk Dashboard Monitoring?\n'
                  '   - Berjalan di atas HTTP standar (Port 80/443), aman melewati firewall, reverse proxy (Nginx, Traefik), dan CDN tanpa perlu konfigurasi khusus.\n'
                  '   - Sangat hemat sumber daya dibandingkan polling karena koneksi HTTP dibuka sekali dan server terus mengirim teks data (text/event-stream) saat terjadi pembaruan.\n'
                  '   - Memiliki fitur native auto-reconnect dan event ID tracking bawaan spesifikasi W3C.\n'
                  '   - Pola monitoring dashboard cocok 100% dengan karakteristik SSE yang asimetris: server mempublikasikan metrik/sensor ke client.\n\n'
                  '2. Mengapa SSE BUKAN Pilihan untuk Audio/Video Dua Arah?\n'
                  '   - Unidirectional: SSE hanya mengalir dari server ke client. Audio/video call wajib memerlukan komunikasi dua arah (full duplex) secara simultan.\n'
                  '   - Berbasis Teks UTF-8: SSE dirancang untuk payload teks (`data: {...}\\n\\n`), sangat tidak efisien untuk streaming frame biner media.\n'
                  '   - Menggunakan TCP: TCP menjamin pengiriman paket dengan retransmisi otomatis. Jika ada 1 paket frame audio/video hilang, TCP akan menahan seluruh paket berikutnya (Head-of-Line Blocking) sehingga terjadi lag/jitter yang fatal untuk video call. Video call membutuhkan protokol UDP (seperti WebRTC) dengan latensi sub-100ms.',
            ),
            const SizedBox(height: 12),

            // Question 4
            _buildQuestionCard(
              number: 4,
              title: 'WebSocket (Dua Arah / Full Duplex)',
              question: 'Apa perbedaan mendasar antara WebSocket dan HTTP REST dalam hal state koneksi dan efisiensi pengiriman pesan berkala?',
              answer:
                  '1. State Koneksi:\n'
                  '   - HTTP REST bersifat Stateless: Setiap kali request dikirim, server memprosesnya secara terisolasi tanpa mengingat konteks koneksi fisik sebelumnya, lalu menutup koneksi.\n'
                  '   - WebSocket bersifat Stateful: Setelah proses handshake awal (HTTP 101 Switching Protocols), koneksi TCP soket tetap terbuka (persistent connection) antara client dan server selama sesi berlangsung.\n\n'
                  '2. Efisiensi Pengiriman Pesan Berkala:\n'
                  '   - Pada HTTP REST, setiap pesan berkala harus mengulang framing HTTP lengkap beserta header ratusan byte (User-Agent, Cookie, Content-Type, Accept, dsb).\n'
                  '   - Pada WebSocket, data dikirim dalam bentuk frame biner ringkas dengan framing overhead hanya 2 hingga 10 byte per pesan. Hal ini memangkas overhead jaringan hingga 98% pada transmisi data frekuensi tinggi seperti chat real-time atau game.',
            ),
            const SizedBox(height: 12),

            // Question 5
            _buildQuestionCard(
              number: 5,
              title: 'MQTT (IoT Pub/Sub)',
              question: 'Mengapa MQTT sering dipilih untuk IoT dibandingkan polling REST API setiap detik?',
              answer:
                  'Alasan utama MQTT menjadi standar de facto untuk IoT (ESP32, sensor mikrokontroler, smart home):\n\n'
                  '1. Overhead Paket Ultra-Ringan (2-Byte Fixed Header):\n'
                  '   - Paket MQTT memiliki fixed header sekecil 2 byte, dibandingkan HTTP yang membutuhkan 500–1000 byte per request. Pada mikrokontroler berdaya rendah dengan memori kecil (RAM 32KB–512KB) dan modul modem seluler berbayar per megabyte, MQTT menghemat kuota dan memori secara masif.\n\n'
                  '2. Arsitektur Publish–Subscribe (Event-Driven):\n'
                  '   - Sensor hanya mempublikasikan data ke topik saat ada pembacaan baru. Perangkat tidak perlu terus-menerus melakukan polling "apakah ada perintah?".\n'
                  '   - Decoupling spasial dan temporal: Pengirim (sensor) dan penerima (aplikasi mobile) tidak perlu saling mengetahui alamat IP masing-masing, cukup terhubung ke broker MQTT yang sama.\n\n'
                  '3. Fitur Keandalan Khusus Jaringan Buruk:\n'
                  '   - Quality of Service (QoS 0, QoS 1, QoS 2) untuk jaminan pengiriman sesuai prioritas.\n'
                  '   - Last Will and Testament (LWT): Jika sensor tiba-tiba kehabisan daya baterai atau terputus jaringan, broker secara otomatis memberi tahu subscriber bahwa sensor telah mati (ungraceful disconnect).\n'
                  '   - Retained Message: Subscriber yang baru online langsung menerima status sensor terakhir tanpa harus menunggu sensor mengirim pembacaan berikutnya.',
            ),
            const SizedBox(height: 12),

            // Question 6
            _buildQuestionCard(
              number: 6,
              title: 'WebRTC (Peer-to-Peer)',
              question: 'Mengapa WebRTC lebih tepat untuk video call dibandingkan mengirim gambar kamera berulang kali melalui REST API?',
              answer:
                  '1. Codec Video & Kompresi Inter-Frame Modern (H.264, VP8, VP9, AV1):\n'
                  '   - Mengirim gambar JPEG berulang via REST API (misal 30 frame/detik) menghasilkan data raksasa (50KB x 30 = 1.5 MB/detik per user).\n'
                  '   - WebRTC menggunakan codec video adaptif yang hanya mengirimkan perubahan piksel antar frame (delta compression), menghemat bandwidth hingga 95%.\n\n'
                  '2. Transport UDP & SRTP (Bebas Head-of-Line Blocking):\n'
                  '   - REST API menggunakan TCP yang menjamin setiap byte sampai berurutan. Jika 1 paket frame tertunda atau hilang, gambar akan freeze menunggu retransmisi.\n'
                  '   - WebRTC menggunakan Real-time Transport Protocol (SRTP) di atas UDP. Jika 1 paket hilang di jaringan, WebRTC tetap menampilkan frame selanjutnya secara mulus tanpa penundaan (latensi sub-100 ms yang imperceptible bagi telinga dan mata manusia).\n\n'
                  '3. Jalur Langsung Peer-to-Peer (P2P):\n'
                  '   - Pada REST API, semua video dari Client A harus diunggah ke server, lalu diunduh oleh Client B (server menjadi bottleneck bandwidth raksasa).\n'
                  '   - WebRTC mengalirkan audio dan video langsung antar kedua perangkat pengguna, sehingga server aplikasi tidak terbebani biaya bandwidth streaming media.',
            ),
            const SizedBox(height: 12),

            // Question 7
            _buildQuestionCard(
              number: 7,
              title: 'gRPC Streaming',
              question: 'Dalam sistem monitoring yang mengirim ribuan pembaruan terstruktur, kapan gRPC streaming dapat lebih sesuai dibandingkan REST API?',
              answer:
                  'gRPC Streaming jauh lebih unggul daripada REST API pada skenario-skenario berikut:\n\n'
                  '1. Volume dan Frekuensi Pembaruan Sangat Tinggi (Throughput Skala Ribuan QPS):\n'
                  '   - REST API harus mengulang proses alokasi connection dan HTTP header parsing setiap request.\n'
                  '   - gRPC Server Streaming membuka 1 stream HTTP/2 dan memompa ribuan record data tanpa henti dalam satu saluran koneksi.\n\n'
                  '2. Kecepatan Serialisasi & Penghematan Bandwidth (Protocol Buffers vs JSON):\n'
                  '   - JSON adalah format teks yang membutuhkan CPU parsing string (`jsonDecode`) yang boros memori.\n'
                  '   - Protobuf mengompresi data ke format biner terindeks, memotong ukuran payload 60%–80% dan meningkatkan performa serialisasi 5x–10x lebih kencang.\n\n'
                  '3. Integritas Skema Kuat (Strict Contract Type-Safety):\n'
                  '   - Definisi `.proto` dikompilasi secara otomatis ke kode native (Dart, Go, Java, C++, Python) sehingga mustahil terjadi bug runtime karena salah ketik nama field atau tipe data pada ribuan pembacaan sensor.',
            ),
            const SizedBox(height: 12),

            // Question 8
            _buildQuestionCard(
              number: 8,
              title: 'Push Notification (FCM)',
              question: 'Mengapa push notification tidak menjamin pembaruan data seketika seperti aliran WebSocket yang aktif?',
              answer:
                  '1. Best-Effort Delivery & Antrean Gateway Pihak Ketiga:\n'
                  '   - Pesan push tidak dikirim langsung dari backend ke aplikasi Anda. Pesan harus mampir ke gateway FCM (Google) atau APNs (Apple) terlebih dahulu.\n'
                  '   - Gateway publik ini memiliki mekanisme throttling, antrean (queuing), dan prioritas pengiriman global yang dapat menunda kedatangan pesan beberapa detik hingga beberapa menit.\n\n'
                  '2. Manajemen Daya dan Doze Mode Sistem Operasi:\n'
                  '   - Ketika smartphone dalam kondisi layar mati atau diam di meja, OS Android (Doze Mode) dan iOS mematikan chip radio dan menidurkan proses aplikasi latar belakang untuk menghemat daya baterai.\n'
                  '   - Notifikasi push reguler ditahan sampai OS membuka "maintenance window" berkala.\n\n'
                  '3. Perbedaan Desain (Alerting vs Live Stream):\n'
                  '   - Push Notification diciptakan untuk "Alerting" (membangunkan user atau menaruh icon di notification tray saat ada kejadian baru).\n'
                  '   - WebSocket mempertahankan koneksi soket aktif secara terus-menerus untuk transmisi real-time instan tanpa campur tangan gateway perantara pihak ketiga.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required int number,
    required String title,
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          foregroundColor: Colors.purple.shade900,
          child: Text('$number', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(
          'Praktikum $number: $title',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.help_outline, size: 20, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Text(
                    answer,
                    style: const TextStyle(fontSize: 13, height: 1.45, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
