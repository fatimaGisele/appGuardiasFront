class EstadisticaUsuario {
  final int id;
  final String nombre;
  final String apellido;
  final String rol;
  final int total;
  final int cubiertas;
  final int activas;
  final int perdidas;
  final int programadas;

  EstadisticaUsuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.total,
    required this.cubiertas,
    required this.activas,
    required this.perdidas,
    required this.programadas,
  });

  factory EstadisticaUsuario.fromJson(Map<String, dynamic> json) {
    return EstadisticaUsuario(
      id: json['idusuario'] as int,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ??'',
      rol: json['rol']??'',
      total: json['total']??0,
      cubiertas: json['cubiertas']??0,
      activas: json['activas']??0,
      perdidas: json['perdidas']??0,
      programadas: json['programadas']??0,
    );
  }
}
