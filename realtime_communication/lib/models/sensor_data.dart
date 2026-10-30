class SensorData {
  final int counter;
  final int value;
  final DateTime timestamp;

  const SensorData({
    required this.counter,
    required this.value,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      counter: json['counter'] is int ? json['counter'] as int : int.tryParse(json['counter']?.toString() ?? '0') ?? 0,
      value: json['value'] is int ? json['value'] as int : int.tryParse(json['value']?.toString() ?? '0') ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'counter': counter,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  String toString() => 'SensorData(counter: $counter, value: $value, time: $timestamp)';
}

