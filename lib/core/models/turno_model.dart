import 'dart:convert';

class Turno {
  final int id;
  final String nombre;
  final String? descripcion;
  final String estado;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? usuarioNombre;

  Turno({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    this.usuarioNombre,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: (json['idTurno'] ?? 0) as int,
      nombre: json['nombre'] ??'',
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'programado',
      fechaInicio: DateTime.parse(json['fecha_inicio']?? DateTime.now().toIso8601String()),
      fechaFin: DateTime.parse(json['fecha_fin'] ?? DateTime.now().toIso8601String()),
      usuarioNombre: json['usuario_nombre']
    );
  }
}
