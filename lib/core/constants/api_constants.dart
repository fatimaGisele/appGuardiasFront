class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';

  //Auth
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';

  //Turnos
  static const String turnos = '$baseUrl/turnos/';

  //Usuarios
  static const String usuarios = '$baseUrl/usuarios/';

  //calendario
  static const String calendario = '$baseUrl/calendario/';

  //estadisticas
  static const String estadisticasEquipos = '$baseUrl/usuarios/estadisticas/';

  //manejoGrupo
  static const String gruposEscalamiento = '$baseUrl/grupo_escalamiento/';
  static const String usuarioGrupo = '$baseUrl/usuario_grupo/';
}
