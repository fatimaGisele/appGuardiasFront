import 'dart:convert';
import '../constants/api_constants.dart';
import 'api_client.dart';

class UsuarioService {
  static Future<List<Map<String, dynamic>>> getUsuarios({String? rol}) async {
    String url = ApiConstants.usuarios;
    if (rol != null) url += '?rol=$rol';
    final response = await ApiCliente.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
