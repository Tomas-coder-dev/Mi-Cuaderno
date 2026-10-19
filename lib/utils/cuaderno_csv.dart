import '../models/paquete.dart';
import '../models/viaje.dart';

class RespaldoCuaderno {
  final List<Paquete> paquetes;
  final List<Viaje> viajes;

  const RespaldoCuaderno({
    required this.paquetes,
    required this.viajes,
  });
}

const _encabezado =
    'tipo,id,numero,descripcion,destinatario,telefono,fechaLlegada,fechaEnvio,viajeId,nota';

String exportarRespaldo(RespaldoCuaderno data) {
  final lineas = <String>[_encabezado];
  for (final viaje in data.viajes) {
    lineas.add([
      'viaje',
      viaje.id,
      '',
      '',
      '',
      '',
      viaje.fecha.toIso8601String(),
      '',
      '',
      viaje.nota,
    ].map(_campoCsv).join(','));
  }
  for (final paquete in data.paquetes) {
    lineas.add([
      'paquete',
      paquete.id,
      paquete.numero,
      paquete.descripcion,
      paquete.destinatario,
      paquete.telefono,
      paquete.fechaLlegada.toIso8601String(),
      paquete.fechaEnvio?.toIso8601String() ?? '',
      paquete.viajeId ?? '',
      '',
    ].map(_campoCsv).join(','));
  }
  return lineas.join('\n');
}

RespaldoCuaderno importarRespaldo(String texto) {
  final filas = _parsearCsv(texto);
  final paquetes = <Paquete>[];
  final viajes = <Viaje>[];

  for (final fila in filas) {
    final tipo = _col(fila, 0).toLowerCase();
    if (tipo == 'tipo' || tipo.isEmpty) continue;
    if (tipo == 'viaje') {
      final fecha = DateTime.tryParse(_col(fila, 6));
      final id = _col(fila, 1);
      if (fecha == null || id.isEmpty) continue;
      viajes.add(Viaje(id: id, fecha: fecha, nota: _col(fila, 9)));
      continue;
    }
    if (tipo == 'paquete') {
      final numero = _col(fila, 2);
      if (numero.isEmpty) continue;
      final llegada = DateTime.tryParse(_col(fila, 6)) ?? DateTime.now();
      final envioTexto = _col(fila, 7);
      final viajeId = _col(fila, 8);
      paquetes.add(
        Paquete(
          id: _col(fila, 1),
          numero: numero,
          descripcion: _col(fila, 3),
          destinatario: _col(fila, 4),
          telefono: _col(fila, 5),
          fechaLlegada: llegada,
          fechaEnvio: envioTexto.isEmpty ? null : DateTime.tryParse(envioTexto),
          viajeId: viajeId.isEmpty ? null : viajeId,
        ),
      );
    }
  }

  return RespaldoCuaderno(paquetes: paquetes, viajes: viajes);
}

String _col(List<String> fila, int indice) => indice < fila.length ? fila[indice].trim() : '';

String _campoCsv(String valor) {
  if (valor.contains(',') || valor.contains('"') || valor.contains('\n') || valor.contains('\r')) {
    return '"${valor.replaceAll('"', '""')}"';
  }
  return valor;
}

List<List<String>> _parsearCsv(String input) {
  var text = input;
  if (text.startsWith('\uFEFF')) text = text.substring(1);
  text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  final filas = <List<String>>[];
  final fila = <String>[];
  final actual = StringBuffer();
  var entreComillas = false;

  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (entreComillas) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          actual.write('"');
          i++;
        } else {
          entreComillas = false;
        }
      } else {
        actual.write(c);
      }
    } else if (c == '"') {
      entreComillas = true;
    } else if (c == ',') {
      fila.add(actual.toString());
      actual.clear();
    } else if (c == '\n') {
      fila.add(actual.toString());
      actual.clear();
      if (fila.any((celda) => celda.trim().isNotEmpty)) {
        filas.add(List<String>.of(fila));
      }
      fila.clear();
    } else {
      actual.write(c);
    }
  }

  fila.add(actual.toString());
  if (fila.any((celda) => celda.trim().isNotEmpty)) {
    filas.add(List<String>.of(fila));
  }
  return filas;
}
