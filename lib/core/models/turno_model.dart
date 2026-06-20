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
      id: json['idTurno'],
      nombre: json['nombre'] ??'',
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'programado',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      usuarioNombre: json['usuarioNombre']
    );
  }
}
