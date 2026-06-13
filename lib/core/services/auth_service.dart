import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'storage_service.dart';

class AuthService {
  //login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      //guardando token
      await StorageService.saveTokens(
        accessToken: data['access'],
        refreshToken: data['refreshToken'],
      );
      //guardar datos del servicio
      await StorageService.saveUser(jsonEncode(data['usuario']));
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Error al iniciar sesion',
      };
    }
  }

  //register
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String password,
    required String password2,
    required int rolId,
  }) async {
    final responde = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'Application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'password': password,
        'password2': password2,
        'rolId': rolId,
      }),
    );
    final data = jsonDecode(responde.body);
    if (responde.statusCode == 201) {
      return {'success': true};
    } else {
      return {'success': false, 'errors': data};
    }
  }

  //logout
  static Future<void> logout() async {
    await StorageService.clearAll();
  }

  //
  static Future<bool> isLoggedIn() async {
    final token = await StorageService.getAccessToken();
    return token != null;
  }
}
