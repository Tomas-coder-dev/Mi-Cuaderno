import 'package:hive/hive.dart';

part 'paquete.g.dart';

@HiveType(typeId: 0)
class Paquete extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String numero;

  @HiveField(2)
  String descripcion;

  @HiveField(3)
  DateTime fechaLlegada;

  @HiveField(4)
  DateTime? fechaEnvio;

  @HiveField(5)
  String destinatario;

  @HiveField(6)
  String telefono;

  @HiveField(7)
  String? viajeId;

  @HiveField(8)
  String? fotoPath;

  Paquete({
    required this.id,
    required this.numero,
    this.descripcion = '',
    required this.fechaLlegada,
    this.fechaEnvio,
    this.destinatario = '',
    this.telefono = '',
    this.viajeId,
    this.fotoPath,
  });

  bool get enviado => fechaEnvio != null;

  String get codigoVisible => numero.startsWith('#') ? numero : '#$numero';

  /// Nombre de la persona, o la nota si el registro es antiguo.
  String get paraQuien {
    if (destinatario.trim().isNotEmpty) return destinatario.trim();
    return descripcion.trim();
  }

  /// Nota de contenido, si no repite el nombre.
  String get detalle {
    final nota = descripcion.trim();
    if (nota.isEmpty) return '';
    if (nota.toLowerCase() == destinatario.trim().toLowerCase()) return '';
    return nota;
  }

  int diasEnLocal([DateTime? ahora]) {
    final fin = fechaEnvio ?? ahora ?? DateTime.now();
    final inicio = DateTime(fechaLlegada.year, fechaLlegada.month, fechaLlegada.day);
    final corte = DateTime(fin.year, fin.month, fin.day);
    final dias = corte.difference(inicio).inDays;
    return dias < 0 ? 0 : dias;
  }

  bool coincideCon(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return numero.toLowerCase().contains(q) ||
        descripcion.toLowerCase().contains(q) ||
        destinatario.toLowerCase().contains(q) ||
        telefono.toLowerCase().contains(q);
  }

  Paquete copiar() {
    return Paquete(
      id: id,
      numero: numero,
      descripcion: descripcion,
      fechaLlegada: fechaLlegada,
      fechaEnvio: fechaEnvio,
      destinatario: destinatario,
      telefono: telefono,
      viajeId: viajeId,
      fotoPath: fotoPath,
    );
  }
}
