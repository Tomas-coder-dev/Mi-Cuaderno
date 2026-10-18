import 'package:hive/hive.dart';

part 'paquete.g.dart';

@HiveType(typeId: 0)
class Paquete extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String numero;

  @HiveField(2)
  late String descripcion;

  @HiveField(3)
  late DateTime fechaLlegada;

  @HiveField(4)
  DateTime? fechaEnvio;

  Paquete({
    required this.id,
    required this.numero,
    required this.descripcion,
    required this.fechaLlegada,
    this.fechaEnvio,
  });

  bool get enviado => fechaEnvio != null;
}
