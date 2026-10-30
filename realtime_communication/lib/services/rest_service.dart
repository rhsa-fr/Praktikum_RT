import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/sensor_data.dart';

class RestService {
  final AppConfig _config = AppConfig();

  Future<SensorData> getData() async {
    final stopwatch = Stopwatch()..start();
    final url = Uri.parse('${_config.baseUrl}/api/data');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode != 200) {
        throw Exception('Server mengembalikan kode ${response.statusCode}: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SensorData.fromJson(json);
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final url = Uri.parse('${_config.baseUrl}/api/message');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengirim pesan (Kode ${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

