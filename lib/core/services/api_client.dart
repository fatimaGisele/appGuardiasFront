import 'dart:convert';
import 'storage_service.dart';
import 'package:http/http.dart' as http;

class ApiCliente {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String url) async {
    return http.get(Uri.parse(url), headers: await _authHeaders());
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) 
  async {
    return http.post(
      Uri.parse(url),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body)
  async{
    return http.put(
      Uri.parse(url),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
  }
}
