import 'dart:convert';
import '../constants/api_constants.dart';
import 'api_client.dart';

class CalendarioService {
  static Future<List<Map<String, dynamic>>> getCalendarios() async {
    final response = await ApiCliente.get(ApiConstants.calendario);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
