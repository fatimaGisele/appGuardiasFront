import 'dart:convert';
import '../constants/api_constants.dart';
import 'api_client.dart';

class RelevoService {
  static Future<List<Map<String, dynamic>>> getMisRelevosPendientes() async {
    final response = await ApiCliente.get(ApiConstants.misRelevosPendientes);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<bool> aceptar(int relevoId) async {
    final response = await ApiCliente.post(
      '${ApiConstants.baseUrl}/relevos/$relevoId/aceptar/', {},
    );
    return response.statusCode == 200;
  }

  static Future<bool> rechazar(int relevoId, {String motivo = ''}) async {
    final response = await ApiCliente.post(
      '${ApiConstants.baseUrl}/relevos/$relevoId/rechazar/',
      {'motivo': motivo},
    );
    return response.statusCode == 200;
  }
}