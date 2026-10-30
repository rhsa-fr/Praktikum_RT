# Realtime Communication — Praktikum Pemrograman Mobile

Proyek aplikasi Flutter dan backend Node.js untuk mengeksplorasi dan membandingkan 8 paradigma komunikasi data:
1. **Praktikum 1 — REST API (Request–Response)**
2. **Praktikum 2 — Polling & Long Polling (Periodic vs Held Request)**
3. **Praktikum 3 — Server-Sent Events (SSE / Satu Arah)**
4. **Praktikum 4 — WebSocket (Dua Arah / Full Duplex)**
5. **Praktikum 5 — MQTT (Publish–Subscribe IoT Sensor)**
6. **Praktikum 6 — WebRTC (Peer-to-Peer Audio/Video & DataChannel)**
7. **Praktikum 7 — gRPC Streaming (Protocol Buffers & 4 Pola Streaming)**
8. **Praktikum 8 — Push Notification (Firebase Cloud Messaging / FCM)**

---

## 📁 Struktur Direktori

```text
realtime_communication/
├── lib/
│   ├── config/
│   │   └── app_config.dart                 # Konfigurasi dynamic host IP (localhost, 10.0.2.2, atau LAN IP)
│   ├── models/
│   │   ├── sensor_data.dart                # Model data sensor (counter, value, timestamp)
│   │   └── chat_message.dart               # Model pesan WebSocket chat
│   ├── services/
│   │   ├── rest_service.dart               # Service HTTP GET & POST
│   │   ├── polling_service.dart            # Service Polling berkala & Long Polling
│   │   ├── sse_service.dart                # Native streaming SSE (text/event-stream)
│   │   ├── websocket_service.dart          # Service WebSocket channel full duplex
│   │   └── mqtt_service.dart               # Service MQTT TCP pub/sub ke broker HiveMQ
│   ├── screens/
│   │   ├── home_screen.dart                # Dashboard navigasi & indikator status backend
│   │   ├── praktikum1_rest_screen.dart     # Praktikum 1: REST API
│   │   ├── praktikum2_polling_screen.dart  # Praktikum 2: Polling vs Long Polling
│   │   ├── praktikum3_sse_screen.dart      # Praktikum 3: Server-Sent Events
│   │   ├── praktikum4_websocket_screen.dart# Praktikum 4: WebSocket
│   │   ├── praktikum5_mqtt_screen.dart     # Praktikum 5: MQTT IoT Sensor
│   │   ├── praktikum6_webrtc_screen.dart   # Praktikum 6: WebRTC P2P
│   │   ├── praktikum7_grpc_screen.dart     # Praktikum 7: gRPC Streaming
│   │   ├── praktikum8_fcm_screen.dart      # Praktikum 8: Push Notification FCM
│   │   └── analysis_questions_screen.dart  # Rangkuman & Jawaban Analisis Praktikum 1–8
│   └── main.dart
├── server/
│   ├── package.json
│   └── server.js                           # Server Node.js (REST, Long-poll, SSE, WS)
└── pubspec.yaml
```

---

## 🚀 Panduan Menjalankan

### 1. Menjalankan Backend Server
Masuk ke direktori server lalu jalankan:
```bash
cd realtime_communication/server
npm install
node server.js
```
Server akan aktif di port `3000` dengan endpoint:
* `GET /api/data` — REST API data sensor terkini
* `POST /api/message` — REST API pengiriman pesan
* `GET /api/long-poll?lastCounter=X` — Long polling yang menahan koneksi hingga data baru tersedia
* `GET /api/events` — Server-Sent Events stream (`text/event-stream`)
* `ws://0.0.0.0:3000` — WebSocket broadcast & echo chat server

### 2. Menjalankan Aplikasi Flutter
Dari folder `realtime_communication`:
```bash
cd realtime_communication

# Menjalankan di Windows Desktop:
flutter run -d windows

# Atau di Google Chrome (Web):
flutter run -d chrome

# Atau di Android Emulator / Perangkat Fisik:
flutter run
```

> **Tips Penyesuaian Host IP:**
> Aplikasi dilengkapi fitur **IP Switcher** di pojok kanan atas layar utama:
> * Untuk **Windows Desktop & Chrome Web**: gunakan `localhost` (port 3000).
> * Untuk **Android Emulator**: gunakan `10.0.2.2` (port 3000).
> * Untuk **Perangkat Fisik Android via WiFi**: masukkan IP lokal laptop Anda (contoh `192.168.1.10:3000`).

---

## 📊 Matriks Perbandingan 8 Teknologi Komunikasi

| Teknologi | Arah Aliran Data | State Koneksi | Protokol Transport | Ukuran Overhead | Latensi Rata-rata | Kasus Penggunaan Utama |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **REST API** | Req–Resp (Half-duplex) | Stateless | HTTP/1.1 over TCP | Besar (500B–1KB) | 100–500 ms | CRUD data, autentikasi, submit formulir |
| **Polling** | Req–Resp berkala | Stateless | HTTP over TCP | Sangat Boros | Tergantung Interval | Pembaruan data santai (interval panjang >10s) |
| **Long Polling** | Held Request | Semi-Stateful | HTTP over TCP | Sedang | Rendah saat ada data | Fallback realtime bila firewall memblokir WS |
| **SSE** | Server $\rightarrow$ Client | Stateful (Stream) | HTTP/1.1 or HTTP/2 | Rendah (Teks) | $<50$ ms | Dashboard monitoring, live score, feed log |
| **WebSocket** | Full Duplex (Dua Arah) | Stateful | TCP Socket (ws/wss) | Sangat Ringan (2–10B)| $<20$ ms | Chatting, multiplayer game, live collaboration |
| **MQTT** | Pub / Sub Broker | Stateful | TCP / WS Port 1883 | Sangat Ringan (2 Byte) | $<30$ ms | Sensor IoT (ESP32/Arduino), telemetri baterai |
| **WebRTC** | Peer-to-Peer (P2P) | Direct Session | UDP / SRTP / SCTP | Sangat Efisien | Sub-100 ms | Video call, voice call, transfer file P2P |
| **gRPC Stream**| Unary/Stream Biner | Stateful Multiplex | HTTP/2 Protobuf | Minimal (Biner) | $<10$ ms | Komunikasi antar microservices internal |
| **FCM Push** | Server $\rightarrow$ OS Gateway | Asynchronous Push | OS Push Service | Ringan | Detik – Menit | Notifikasi pesan masuk, reminder saat app mati |

---

## 📝 Jawaban Lengkap Pertanyaan Analisis Praktikum 1–8

### Pertanyaan 1 (Praktikum 1 — REST API)
> **Soal:** Jika nilai pada server berubah setiap dua detik, apakah tampilan Flutter otomatis berubah jika hanya menggunakan REST API? Mengapa?

**Jawaban:**
**TIDAK**, tampilan Flutter tidak akan berubah secara otomatis.
**Alasan Teknis:**
1. **Pull-Based / Client-Initiated:** Protokol HTTP REST bersifat *client-driven*. Server bersikap pasif dan hanya membalas saat menerima permintaan dari client.
2. **Stateless:** Setelah server mengirimkan respons HTTP `200 OK`, siklus request-response berakhir dan koneksi ditutup. Server tidak menyimpan referensi aktif ke client untuk mendorong (*push*) pembaruan data secara proaktif. Tampilan Flutter hanya akan berubah bila client secara eksplisit mengirimkan HTTP GET baru (misal dengan menekan tombol refresh).

---

### Pertanyaan 2 (Praktikum 2 — Polling & Long Polling)
> **Soal:** Apa yang terjadi jika interval polling diturunkan dari lima detik menjadi 200 milidetik? Pertimbangkan latensi, penggunaan jaringan, dan beban server.

**Jawaban:**
1. **Latensi:** Menurun drastis dari maksimal 5.000 ms menjadi $\le 200$ ms. UI terasa sangat responsif dan menyerupai *real-time*.
2. **Penggunaan Jaringan (Network Bandwidth & Battery):**
   * Frekuensi request melonjak **25 kali lipat** (dari 0.2 req/detik menjadi 5 req/detik per client).
   * Karena server hanya memproduksi data baru tiap 2 detik, sekitar **90% request membawa data kosong/duplikat**.
   * Setiap request membawa overhead HTTP header (sekitar 500–1000 byte), menghabiskan kuota internet dan memaksa modem seluler/WiFi terus berada di mode *high-power state* sehingga baterai perangkat cepat habis.
3. **Beban Server (Server Concurrency):**
   * Jika terdapat 1.000 client aktif, server harus memproses **5.000 Request Per Second (RPS)** dari sebelumnya hanya 200 RPS. Hal ini memicu risiko *connection exhaustion*, lonjakan CPU/RAM, dan potensi *Denial of Service* (DoS).

---

### Pertanyaan 3 (Praktikum 3 — Server-Sent Events)
> **Soal:** Mengapa SSE menarik untuk dashboard monitoring, tetapi bukan pilihan utama untuk komunikasi audio/video dua arah?

**Jawaban:**
1. **Mengapa SSE Menarik untuk Dashboard Monitoring?**
   * Berjalan di atas HTTP standar (port 80/443), sehingga aman melewati firewall perusahaan, proxy (Nginx), dan CDN tanpa konfigurasi khusus.
   * Sangat hemat sumber daya dibandingkan polling karena koneksi dibuka sekali dan server terus mengirim teks pembaruan (`text/event-stream`).
   * Memiliki mekanisme rekoneksi otomatis (*auto-reconnect*) dan pelacakan event ID bawaan.
   * Karakteristik dashboard bersifat asimetris (hanya server yang perlu mempublikasikan metrik ke client).
2. **Mengapa SSE BUKAN untuk Audio/Video Dua Arah?**
   * **Unidirectional (Satu Arah):** SSE hanya mengalir dari server ke client. Komunikasi audio/video call membutuhkan aliran dua arah (*full duplex*) secara simultan.
   * **Berbasis Teks:** SSE dirancang untuk payload teks UTF-8, sangat tidak efisien untuk paket biner frame media.
   * **Berbasis TCP:** TCP menjamin keutuhan data dengan retransmisi paket hilang. Jika terjadi *packet loss*, terjadi *Head-of-Line Blocking* yang menimbulkan delay dan jitter tinggi. Video call memerlukan UDP (seperti pada WebRTC) dengan latensi sub-100 ms.

---

### Pertanyaan 4 (Praktikum 4 — WebSocket)
> **Soal:** Apa perbedaan mendasar antara WebSocket dan HTTP REST dalam hal state koneksi dan efisiensi pengiriman pesan berkala?

**Jawaban:**
1. **State Koneksi:**
   * **HTTP REST bersifat Stateless:** Setiap request berdiri sendiri tanpa menyimpan konteks koneksi fisik sebelumnya, lalu koneksi ditutup.
   * **WebSocket bersifat Stateful:** Setelah handshake awal via HTTP 101 Switching Protocols, soket TCP dipertahankan tetap terbuka (*persistent connection*) secara dua arah.
2. **Efisiensi Pengiriman Pesan Berkala:**
   * Pada HTTP REST, setiap pesan berkala harus mengulang header HTTP berukuran ratusan byte.
   * Pada WebSocket, setelah koneksi terbentuk, frame data hanya menambahkan framing overhead sekecil **2 hingga 10 byte** per pesan, menghemat bandwidth hingga 98% pada transmisi data frekuensi tinggi.

---

### Pertanyaan 5 (Praktikum 5 — MQTT)
> **Soal:** Mengapa MQTT sering dipilih untuk IoT dibandingkan polling REST API setiap detik?

**Jawaban:**
1. **Header Ultra-Ringan (2-Byte Fixed Header):** Ukuran header MQTT hanya 2 byte, dibandingkan HTTP request yang berukuran 500–1000 byte. Ini krusial bagi mikrokontroler (ESP32/Arduino) dengan RAM terbatas dan modul seluler hemat kuota.
2. **Model Publish–Subscribe (Event-Driven):** Perangkat sensor hanya mempublikasikan pesan saat nilai berubah. Perangkat tidak perlu terus-menerus bertanya "apakah ada data baru?". Pengirim dan penerima terdekupel (*decoupled*).
3. **Fitur Keandalan Khusus Jaringan Buruk:**
   * **QoS (0, 1, 2):** Jaminan pengiriman pesan bertingkat sesuai stabilitas jaringan.
   * **Last Will and Testament (LWT):** Broker otomatis memberitahu subscriber jika suatu sensor tiba-tiba mati / terputus jaringan.
   * **Retained Messages:** Subscriber baru langsung menerima status sensor terakhir tanpa menunggu siklus publish berikutnya.

---

### Pertanyaan 6 (Praktikum 6 — WebRTC)
> **Soal:** Mengapa WebRTC lebih tepat untuk video call dibandingkan mengirim gambar kamera berulang kali melalui REST API?

**Jawaban:**
1. **Codec Video Khusus & Inter-Frame Compression:** Mengirim gambar JPEG berulang via REST API (30 FPS) menghasilkan data sekitar 1.5–3 MB per detik. WebRTC menggunakan codec VP8/VP9/H.264/AV1 yang hanya mengirimkan perbedaan piksel antar frame (*delta compression*), menghemat bandwidth hingga 95%.
2. **Transport UDP & SRTP (Bebas Head-of-Line Blocking):** REST API berbasis TCP. Jika ada satu paket frame hilang, TCP menahan seluruh antrean data hingga retransmisi selesai (gambar membeku). WebRTC menggunakan SRTP di atas UDP: paket hilang langsung dilewati agar video tetap mengalir lancar dengan latensi sub-100 ms.
3. **Jalur Langsung Peer-to-Peer (P2P):** Media audio dan video mengalir langsung antar perangkat pengguna tanpa membebani bandwidth server aplikasi. Server hanya digunakan di awal untuk pertukaran sinyal (*signaling*) SDP dan ICE Candidates.

---

### Pertanyaan 7 (Praktikum 7 — gRPC Streaming)
> **Soal:** Dalam sistem monitoring yang mengirim ribuan pembaruan terstruktur, kapan gRPC streaming dapat lebih sesuai dibandingkan REST API?

**Jawaban:**
gRPC Streaming lebih sesuai pada skenario:
1. **Throughput Tinggi (Ribuan Update Per Detik):** gRPC Server Streaming memanfaatkan HTTP/2 multiplexing dalam 1 koneksi persisten untuk mengalirkan ribuan pesan tanpa overhead pembuatan koneksi TCP baru.
2. **Efisiensi Serialisasi Biner (Protocol Buffers vs JSON):** Parsing JSON string membutuhkan alokasi memori dan beban CPU tinggi. Protocol Buffers berbentuk biner terkompresi yang 5–10x lebih cepat diserialisasi dan memangkas ukuran paket hingga 60–80%.
3. **Integritas Kontrak Tipe Data:** File skema `.proto` menjamin *type safety* yang konsisten di semua bahasa pemrograman (Dart, Go, Java, Python), mencegah kesalahan *field mismatch* pada telemetri skala besar.

---

### Pertanyaan 8 (Praktikum 8 — Push Notification / FCM)
> **Soal:** Mengapa push notification tidak menjamin pembaruan data seketika seperti aliran WebSocket yang aktif?

**Jawaban:**
1. **Best-Effort Delivery & Antrean Gateway Pihak Ketiga:** Pesan push harus melalui gateway perantara (Google FCM atau Apple APNs). Gateway ini menerapkan *throttling*, antrean, dan penyesuaian prioritas global yang dapat menunda kedatangan pesan.
2. **Power Management OS & Doze Mode:** Ketika layar mati atau perangkat diam, sistem operasi Android (Doze Mode) dan iOS menidurkan chip radio dan mematikan eksekusi latar belakang demi menghemat baterai. Notifikasi push dapat ditahan hingga OS membuka jendela pemeliharaan (*maintenance window*).
3. **Tujuan Desain (Alerting vs Live Stream):** Push notification dirancang untuk memberi tahu kejadian penting (*alerting*) saat aplikasi tidak aktif. Sebaliknya, WebSocket mempertahankan koneksi soket aktif terus-menerus dengan latensi milidetik saat aplikasi sedang digunakan secara interaktif.
