class ChatMessage {
  final String type;
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  const ChatMessage({
    required this.type,
    required this.sender,
    required this.message,
    required this.timestamp,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String currentSender = ''}) {
    final senderStr = json['sender']?.toString() ?? 'Server';
    return ChatMessage(
      type: json['type']?.toString() ?? 'chat',
      sender: senderStr,
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isMe: currentSender.isNotEmpty && senderStr.toLowerCase() == currentSender.toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'sender': sender,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
  };
}

