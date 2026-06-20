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
}
