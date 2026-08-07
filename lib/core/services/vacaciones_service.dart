import 'dart:convert';
import 'api_client.dart';
import '../constants/api_constants.dart';

class VacacionesService {
  static Future<Map<String, dynamic>> getMisDias() async {
    //dias de vacaciones
    final response = await ApiCliente.get(ApiConstants.misDiasVacaciones);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'disponibles': 15, 'usados': 0, 'restantes': 15};
  }

  //mis solicitudes
  static Future<List<Map<String, dynamic>>> getMisVacaciones() async {
    final response = await ApiCliente.get(ApiConstants.vacaciones);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  //vacas pendientes
  static Future<List<Map<String, dynamic>>> getPendientes() async {
    final response = await ApiCliente.get(ApiConstants.vacacionesPendientes);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  //solicitar vacaciones
  static Future<Map<String, dynamic>> solicitar({
    required String fechaInicio,
    required String fechaFin,
    required int aprobadorId,
    String motivo = '',
  }) async {
    final response =
        await ApiCliente.post('${ApiConstants.vacaciones}solicitar/', {
          'fecha_inicio': fechaInicio,
          'fecha_fin': fechaFin,
          'aprobador': aprobadorId,
          'motivo': motivo,
        });
    if (response.statusCode == 200) {
      return {'success': true};
    }
    final data = jsonDecode(response.body);
    return {'success': false, 'error': data.toString()};
  }

  //aprobar
  static Future<bool> aprobar(int idVacas, {String nota = ''}) async {
    final response = await ApiCliente.post(
      '${ApiConstants.vacaciones}$idVacas/aprobar/',
      {'nota': nota},
    );
    return response.statusCode == 200;
  }

  //rechazar
  static Future<bool> rechazar(int idVacas, {String nota = ''}) async{
    final response = await ApiCliente.post(
      '${ApiConstants.vacaciones}$idVacas/rechazar/',
      {'nota': nota},
    );
    return response.statusCode == 200;
  }
}
