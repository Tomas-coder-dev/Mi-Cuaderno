import '../models/paquete.dart';
import '../models/viaje.dart';

class GrupoEnvio {
  final String? viajeId;
  final Viaje? viaje;
  final List<Paquete> paquetes;

  const GrupoEnvio({
    required this.viajeId,
    required this.viaje,
    required this.paquetes,
  });

  bool get suelto => viajeId == null;

  DateTime get fecha {
    if (viaje != null) return viaje!.fecha;
    for (final paquete in paquetes) {
      if (paquete.fechaEnvio != null) return paquete.fechaEnvio!;
    }
    return paquetes.first.fechaLlegada;
  }
}

/// Agrupa los paquetes ya enviados por el viaje en el que salieron.
List<GrupoEnvio> agruparEnvios(List<Paquete> paquetes, List<Viaje> viajes) {
  final porViaje = <String, List<Paquete>>{};
  final sueltos = <Paquete>[];

  for (final paquete in paquetes) {
    final id = paquete.viajeId;
    if (id == null || id.isEmpty) {
      sueltos.add(paquete);
    } else {
      porViaje.putIfAbsent(id, () => []).add(paquete);
    }
  }

  final viajePorId = {for (final viaje in viajes) viaje.id: viaje};
  final grupos = <GrupoEnvio>[
    for (final entry in porViaje.entries)
      GrupoEnvio(
        viajeId: entry.key,
        viaje: viajePorId[entry.key],
        paquetes: entry.value,
      ),
  ];

  if (sueltos.isNotEmpty) {
    grupos.add(GrupoEnvio(viajeId: null, viaje: null, paquetes: sueltos));
  }

  grupos.sort((a, b) => b.fecha.compareTo(a.fecha));
  return grupos;
}
