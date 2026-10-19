import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/paquete.dart';
import '../models/viaje.dart';
import '../utils/cuaderno_csv.dart';
import '../utils/foto_archivo.dart';

const String _boxName = 'paquetes';
const String _viajesBoxName = 'viajes';
const _uuid = Uuid();

final hiveBoxProvider = Provider<Box<Paquete>>((ref) {
  return Hive.box<Paquete>(_boxName);
});

final viajesBoxProvider = Provider<Box<Viaje>>((ref) {
  return Hive.box<Viaje>(_viajesBoxName);
});

final paquetesProvider = StreamProvider<List<Paquete>>((ref) async* {
  final box = ref.watch(hiveBoxProvider);
  yield box.values.toList();
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});

final viajesProvider = StreamProvider<List<Viaje>>((ref) async* {
  final box = ref.watch(viajesBoxProvider);
  yield box.values.toList();
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});

final busquedaInventarioProvider = StateProvider<String>((_) => '');
final busquedaHistorialProvider = StateProvider<String>((_) => '');

final paquetesEnAlmacenProvider = Provider<AsyncValue<List<Paquete>>>((ref) {
  return ref.watch(paquetesProvider).whenData(
        (list) => list.where((p) => !p.enviado).toList()
          ..sort((a, b) => b.fechaLlegada.compareTo(a.fechaLlegada)),
      );
});

final paquetesFiltradosAlmacenProvider = Provider<AsyncValue<List<Paquete>>>((ref) {
  final query = ref.watch(busquedaInventarioProvider);
  return ref.watch(paquetesEnAlmacenProvider).whenData((list) {
    return list.where((p) => p.coincideCon(query)).toList();
  });
});

final paquetesEnviadosProvider = Provider<AsyncValue<List<Paquete>>>((ref) {
  return ref.watch(paquetesProvider).whenData(
        (list) => list.where((p) => p.enviado).toList()
          ..sort((a, b) => b.fechaEnvio!.compareTo(a.fechaEnvio!)),
      );
});

class EntradaPaquete {
  final String numero;
  final String destinatario;
  final String telefono;
  final String descripcion;
  final String? fotoPath;

  const EntradaPaquete({
    required this.numero,
    required this.destinatario,
    this.telefono = '',
    this.descripcion = '',
    this.fotoPath,
  });
}

class PaqueteRepository extends Notifier<void> {
  @override
  void build() {}

  Box<Paquete> get _box => ref.read(hiveBoxProvider);
  Box<Viaje> get _viajes => ref.read(viajesBoxProvider);

  bool codigoEnUso(String numero, {String? ignorarId}) {
    final buscado = numero.trim().toLowerCase();
    if (buscado.isEmpty) return false;
    return _box.values.any(
      (p) => p.id != ignorarId && p.numero.trim().toLowerCase() == buscado,
    );
  }

  List<String> codigosEnUso(Iterable<String> numeros) {
    final usados = <String>[];
    final vistos = <String>{};
    for (final numero in numeros) {
      final clave = numero.trim().toLowerCase();
      if (clave.isEmpty || !vistos.add(clave)) continue;
      if (codigoEnUso(numero)) usados.add(numero.trim().toUpperCase());
    }
    return usados;
  }

  Future<void> agregarVarios(List<EntradaPaquete> entradas) async {
    final ahora = DateTime.now();
    final mapa = <String, Paquete>{};
    for (final entrada in entradas) {
      final id = _uuid.v4();
      mapa[id] = Paquete(
        id: id,
        numero: entrada.numero.trim().toUpperCase(),
        descripcion: entrada.descripcion.trim(),
        destinatario: entrada.destinatario.trim(),
        telefono: entrada.telefono.trim(),
        fechaLlegada: ahora,
        fotoPath: entrada.fotoPath,
      );
    }
    if (mapa.isEmpty) return;
    await _box.putAll(mapa);
  }

  Future<void> editarPaquete({
    required String id,
    required String numero,
    required String descripcion,
    required String destinatario,
    required String telefono,
    String? fotoPath,
    bool actualizarFoto = false,
  }) async {
    final paquete = _box.get(id);
    if (paquete == null) return;
    final fotoAnterior = paquete.fotoPath;
    paquete.numero = numero.trim().toUpperCase();
    paquete.descripcion = descripcion.trim();
    paquete.destinatario = destinatario.trim();
    paquete.telefono = telefono.trim();
    if (actualizarFoto) paquete.fotoPath = fotoPath;
    await paquete.save();
    if (actualizarFoto && fotoAnterior != null && fotoAnterior != fotoPath) {
      await borrarArchivoFoto(fotoAnterior);
    }
  }

  Future<Viaje> despacharVarios(List<String> ids, {String nota = ''}) async {
    final ahora = DateTime.now();
    final viaje = Viaje(id: _uuid.v4(), fecha: ahora, nota: nota.trim());
    await _viajes.put(viaje.id, viaje);

    final cambios = <String, Paquete>{};
    for (final id in ids) {
      final paquete = _box.get(id);
      if (paquete == null || paquete.enviado) continue;
      paquete.fechaEnvio = ahora;
      paquete.viajeId = viaje.id;
      cambios[id] = paquete;
    }
    if (cambios.isNotEmpty) await _box.putAll(cambios);
    return viaje;
  }

  Future<void> revertirAAlmacen(String id) async {
    final paquete = _box.get(id);
    if (paquete == null) return;
    paquete.fechaEnvio = null;
    paquete.viajeId = null;
    await paquete.save();
  }

  Future<Paquete?> eliminarPaquete(String id) async {
    final paquete = _box.get(id);
    if (paquete == null) return null;
    final copia = paquete.copiar();
    await _box.delete(id);
    return copia;
  }

  Future<void> restaurarPaquete(Paquete paquete) async {
    await _box.put(paquete.id, paquete);
  }

  Future<void> importarRespaldo(RespaldoCuaderno data, {required bool reemplazar}) async {
    if (reemplazar) {
      await _box.clear();
      await _viajes.clear();
    }
    if (data.viajes.isNotEmpty) {
      await _viajes.putAll({for (final viaje in data.viajes) viaje.id: viaje});
    }
    final paquetes = <String, Paquete>{};
    for (final paquete in data.paquetes) {
      final id = paquete.id.trim().isEmpty ? _uuid.v4() : paquete.id.trim();
      paquete.id = id;
      paquetes[id] = paquete;
    }
    if (paquetes.isNotEmpty) await _box.putAll(paquetes);
  }

  Future<void> limpiarTodo() async {
    final fotos = _box.values.map((p) => p.fotoPath).whereType<String>().toList();
    await _box.clear();
    await _viajes.clear();
    for (final foto in fotos) {
      await borrarArchivoFoto(foto);
    }
  }
}

final paqueteRepositoryProvider = NotifierProvider<PaqueteRepository, void>(PaqueteRepository.new);
