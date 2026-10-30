const express = require("express");
const cors = require("cors");
const http = require("http");
const { WebSocketServer } = require("ws");

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

let counter = 0;
let history = [];
const receivedMessages = [];
const clients = new Set();
const sseClients = new Set();
const longPollWaiters = new Set();

function publishData() {
  counter++;

  const data = {
    counter,
    value: Math.floor(Math.random() * 100),
    timestamp: new Date().toISOString(),
  };

  history.push(data);
  if (history.length > 100) history.shift();

  // 1. Broadcast ke seluruh client WebSocket
  const wsPayload = JSON.stringify({
    type: "sensor_broadcast",
    data,
  });
  for (const client of clients) {
    if (client.readyState === 1) { // 1 = OPEN
      client.send(wsPayload);
    }
  }

  // 2. Kirim pembaruan ke koneksi SSE
  for (const res of sseClients) {
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  }

  // 3. Bangunkan dan tanggapi client Long Polling yang sedang menunggu
  for (const waiter of Array.from(longPollWaiters)) {
    if (waiter.lastCounter === undefined || counter > waiter.lastCounter) {
      clearTimeout(waiter.timer);
      waiter.res.json({
        success: true,
        data,
        waitedMs: Date.now() - waiter.startTime,
      });
      longPollWaiters.delete(waiter);
    }
  }
}

// Terbitkan data simulasi setiap 2 detik
setInterval(publishData, 2000);

// ==========================================
// 1. REST API
// ==========================================
app.get("/api/data", (req, res) => {
  const latest = history.at(-1) ?? {
    counter: 0,
    value: 0,
    timestamp: new Date().toISOString(),
  };
  res.json({
    ...latest,
    lastReceivedMessage: receivedMessages[0]?.message ?? null,
    totalMessagesReceived: receivedMessages.length,
  });
});

app.post("/api/message", (req, res) => {
  const message = req.body?.message ?? "";
  const entry = {
    id: receivedMessages.length + 1,
    message,
    sender: req.body?.sender || "Flutter Client",
    timestamp: new Date().toISOString(),
    clientIp: req.socket.remoteAddress,
  };
  receivedMessages.unshift(entry);
  if (receivedMessages.length > 50) receivedMessages.pop();

  console.log(`\n=================================================`);
  console.log(`[REST POST] PESAN DITERIMA DARI FLUTTER!`);
  console.log(`- Pesan      : "${message}"`);
  console.log(`- Dari IP    : ${entry.clientIp}`);
  console.log(`- Waktu      : ${new Date().toLocaleTimeString()}`);
  console.log(`- Total Pesan: ${receivedMessages.length}`);
  console.log(`=================================================\n`);

  res.json({
    received: true,
    message,
    timestamp: entry.timestamp,
    totalMessages: receivedMessages.length,
  });
});

// Penanganan jika diakses via browser dengan HTTP GET
app.get("/api/message", (req, res) => {
  res.json({
    info: "Endpoint /api/message menggunakan HTTP POST untuk mengirim data dari Flutter.",
    method: "POST",
    lastReceivedMessage: receivedMessages[0] || "Belum ada pesan yang diterima via POST",
    totalMessagesReceived: receivedMessages.length,
    exampleBody: { message: "halo bot" },
    timestamp: new Date().toISOString(),
  });
});

app.get("/api/messages", (req, res) => {
  res.json({
    total: receivedMessages.length,
    messages: receivedMessages,
  });
});

// ==========================================
// 2. Long Polling
// ==========================================
app.get("/api/long-poll", (req, res) => {
  const clientLastCounter = parseInt(req.query.lastCounter || "0", 10);
  const latest = history.at(-1);

  // Jika server sudah memiliki counter yang lebih baru dari client, kembalikan seketika
  if (latest && latest.counter > clientLastCounter) {
    return res.json({
      success: true,
      data: latest,
      immediate: true,
      waitedMs: 0,
    });
  }

  // Jika belum ada data baru, tahan request hingga ada perubahan atau timeout (25 detik)
  const startTime = Date.now();
  const waiter = {
    res,
    lastCounter: clientLastCounter,
    startTime,
    timer: null,
  };

  waiter.timer = setTimeout(() => {
    longPollWaiters.delete(waiter);
    const fallbackLatest = history.at(-1) ?? {
      counter,
      value: 0,
      timestamp: new Date().toISOString(),
    };
    res.json({
      success: false,
      timeout: true,
      data: fallbackLatest,
      waitedMs: Date.now() - startTime,
    });
  }, 25000);

  longPollWaiters.add(waiter);

  req.on("close", () => {
    clearTimeout(waiter.timer);
    longPollWaiters.delete(waiter);
  });
});

// ==========================================
// 3. Server-Sent Events (SSE)
// ==========================================
app.get("/api/events", (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.flushHeaders();

  sseClients.add(res);
  console.log(`[SSE] Client tersambung. Total SSE clients: ${sseClients.size}`);

  res.write("event: connected\ndata: {\"status\":\"connected\"}\n\n");

  req.on("close", () => {
    sseClients.delete(res);
    console.log(`[SSE] Client terputus. Total SSE clients: ${sseClients.size}`);
  });
});

// ==========================================
// 4. WebSocket (Two-Way Communication & Chat Broadcast)
// ==========================================
wss.on("connection", (socket, req) => {
  clients.add(socket);
  const clientIp = req.socket.remoteAddress;
  console.log(`[WebSocket] Client tersambung dari ${clientIp}. Total WS: ${clients.size}`);

  // Kirim salam selamat datang
  socket.send(JSON.stringify({
    type: "system",
    message: "Terhubung ke WebSocket Server!",
    clientsCount: clients.size,
    timestamp: new Date().toISOString(),
  }));

  socket.on("message", (rawMessage) => {
    try {
      const parsed = JSON.parse(rawMessage.toString());
      console.log(`[WebSocket] Pesan diterima:`, parsed);

      const broadcastMsg = JSON.stringify({
        type: "chat",
        sender: parsed.sender || "Client",
        message: parsed.message || rawMessage.toString(),
        timestamp: new Date().toISOString(),
      });

      // Broadcast ke SEMUA client terhubung (termasuk pengirim agar sinkron)
      for (const client of clients) {
        if (client.readyState === 1) {
          client.send(broadcastMsg);
        }
      }
    } catch {
      // Jika pesan plain text
      const reply = JSON.stringify({
        type: "echo",
        message: rawMessage.toString(),
        timestamp: new Date().toISOString(),
      });
      for (const client of clients) {
        if (client.readyState === 1) {
          client.send(reply);
        }
      }
    }
  });

  socket.on("close", () => {
    clients.delete(socket);
    console.log(`[WebSocket] Client terputus. Total WS: ${clients.size}`);
  });

  socket.on("error", (err) => {
    console.error(`[WebSocket] Error:`, err);
  });
});

const PORT = 3000;
server.listen(PORT, "0.0.0.0", () => {
  console.log(`===============================================`);
  console.log(`Server Realtime Communication berjalan di port ${PORT}`);
  console.log(`- REST API GET   : http://localhost:${PORT}/api/data`);
  console.log(`- REST API POST  : http://localhost:${PORT}/api/message`);
  console.log(`- Long Polling   : http://localhost:${PORT}/api/long-poll`);
  console.log(`- SSE Endpoint   : http://localhost:${PORT}/api/events`);
  console.log(`- WebSocket URL  : ws://localhost:${PORT}`);
  console.log(`===============================================`);
});

