import 'package:hive/hive.dart';

part 'viaje.g.dart';

/// Varios paquetes que salen juntos, el mismo día en que se registran.
@HiveType(typeId: 1)
class Viaje extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime fecha;

  @HiveField(2)
  String nota;

  Viaje({
    required this.id,
    required this.fecha,
    this.nota = '',
  });
}
