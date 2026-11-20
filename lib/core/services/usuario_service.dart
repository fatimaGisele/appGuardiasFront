import 'dart:convert';
import '../constants/api_constants.dart';
import '../models/estadistica_model.dart';
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

  static Future<Map<String, dynamic>> crear({ ///alta de usuario con rol...requiere sesion de lider o encargado...
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String password,
    required String password2,
    required int rolId,
  }) async {
    final response = await ApiCliente.post(ApiConstants.usuarios, {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'password': password,
     'password2': password2,
      'rol_id': rolId,
    });
    if (response.statusCode == 201) return {'success': true};
    return {'success': false, 'errors': jsonDecode(response.body)};
  }


  static Future<List<EstadisticaUsuario>> getEstadisticaEquipo() async {
    final response = await ApiCliente.get(ApiConstants.estadisticasEquipos);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => EstadisticaUsuario.fromJson(json)).toList();
    }
    return [];
  }
}
