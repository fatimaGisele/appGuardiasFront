import 'dart:convert';
import '../constants/api_constants.dart';
import 'api_client.dart';

class EquipoService {
  static Future<List<Map<String, dynamic>>> getGrupos() async {
    final response = await ApiCliente.get(ApiConstants.gruposEscalamiento);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<Map<String, dynamic>> crearGrupo({
    required String nombre,
    required String descripcion,
  }) async {
    final response = await ApiCliente.post(ApiConstants.gruposEscalamiento, {
      'nombre': nombre,
      'descripcion': descripcion,
      'num_orden_escalamiento': 1,
      'activo': true,
    });
    if (response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    return {'success': true, 'data': jsonDecode(response.body).toString()};
  }

  static Future<List<Map<String, dynamic>>> getMiembros(int grupoId) async {
    final response = await ApiCliente.get(
      '${ApiConstants.usuarioGrupo}?grupo=$grupoId',
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<bool> agregarMiembro({
    required int usuarioId,
    required int grupoId,
    required int prioridad,
  }) async {
    final response = await ApiCliente.post(ApiConstants.usuarioGrupo, {
      'usuario': usuarioId,
      'grupo_escalamiento': grupoId,
      'prioridad': prioridad,
      'activo': true,
    });
    return response.statusCode == 201;
  }

  static Future<bool> quitarMiembro(int idUsuario) async {
    final response = await ApiCliente.delete(
      '${ApiConstants.usuarioGrupo}$idUsuario/',
    );
    return response.statusCode == 204;
  }
}
