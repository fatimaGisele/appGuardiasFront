import 'dart:convert';
import 'api_client.dart';
import '../models/turno_model.dart';
import '../constants/api_constants.dart';

class TurnoService {
  static Future<List<Turno>> getTurnos({String? estado}) async {
    String url = ApiConstants.turnos;
    if (estado != null) url += '?estado=$estado';

    final response = await ApiCliente.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Turno.fromJson(json)).toList();
    }
    return [];
  }

  static Future<bool> checkin(int turnoId) async {
    final response = await ApiCliente.post(
      '${ApiConstants.baseUrl}/turnos/checkin/$turnoId/',
      {},
    );
    return response.statusCode==200;
  }

  static Future<Map<String, dynamic>> crearTurno({
  required String nombre,
  required String descripcion,
  required DateTime fechaInicio,
  required DateTime fechaFin,
  required int usuarioAsignadoId,
  required int usuarioRalevoId,
  required int calendarioId,
}) async {
  final response = await ApiCliente.post(ApiConstants.turnos, {
    'nombre': nombre,
    'descripcion': descripcion,
    'fecha_inicio': fechaInicio.toIso8601String(),
    'fecha_fin': fechaFin.toIso8601String(),
    'usuario_asignado': usuarioAsignadoId,
    'usuario_relevo_id': usuarioRalevoId,
    'calendario': calendarioId,
    'grupo_escalamiento': 1, // ← hacer un selector
  });

  if (response.statusCode == 201) {
    return {'success': true};
  }
  final data = jsonDecode(response.body);
  return {'success': false, 'error': data.toString()};
}
}
