import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  //guardar las tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  //leer los tokens
  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  //leer refresh token
  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  //guardar data
  static Future<void> saveUser(String userData) async {
    await _storage.write(key: _userKey, value: userData);
  }

  //leer user data
  static Future<String?> getUserData() async {
    return _storage.read(key: _userKey);
  }

  //brrar
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
