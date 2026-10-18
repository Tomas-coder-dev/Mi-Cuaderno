import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/paquete.dart';

const String _boxName = 'paquetes';
const _uuid = Uuid();

// Provider for the raw Hive box
final hiveBoxProvider = Provider<Box<Paquete>>((ref) {
  return Hive.box<Paquete>(_boxName);
});

// Provider for all packages (reactive to Hive changes)
final paquetesProvider = StreamProvider<List<Paquete>>((ref) async* {
  final box = ref.watch(hiveBoxProvider);

  // Emit current values
  yield box.values.toList();

  // Listen to changes
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});

// Search filter for Inventory
final busquedaInventarioProvider = StateProvider<String>((_) => '');

// Search filter for History
final busquedaHistorialProvider = StateProvider<String>((_) => '');

// Derived: packages in stock (not sent)
final paquetesEnAlmacenProvider = Provider<AsyncValue<List<Paquete>>>((ref) {
  return ref.watch(paquetesProvider).whenData(
    (list) => list
        .where((p) => !p.enviado)
        .toList()
      ..sort((a, b) => b.fechaLlegada.compareTo(a.fechaLlegada)),
  );
});

// Derived: packages in stock filtered by search query
final paquetesFiltradosAlmacenProvider =
    Provider<AsyncValue<List<Paquete>>>((ref) {
  final query = ref.watch(busquedaInventarioProvider).trim().toLowerCase();
  return ref.watch(paquetesEnAlmacenProvider).whenData((list) {
    if (query.isEmpty) return list;
    return list
        .where((p) =>
            p.numero.toLowerCase().contains(query) ||
            p.descripcion.toLowerCase().contains(query))
        .toList();
  });
});

// Derived: sent packages
final paquetesEnviadosProvider = Provider<AsyncValue<List<Paquete>>>((ref) {
  return ref.watch(paquetesProvider).whenData(
    (list) => list
        .where((p) => p.enviado)
        .toList()
      ..sort((a, b) => b.fechaEnvio!.compareTo(a.fechaEnvio!)),
  );
});

// Repository notifier for CRUD operations
class PaqueteRepository extends Notifier<void> {
  @override
  void build() {}

  Box<Paquete> get _box => ref.read(hiveBoxProvider);

  String sugerirSiguienteNumero() {
    final todos = _box.values.toList();
    if (todos.isEmpty) return 'P-001';

    int maxNum = 0;
    final regex = RegExp(r'\d+');
    for (final p in todos) {
      final matches = regex.allMatches(p.numero);
      for (final m in matches) {
        final val = int.tryParse(m.group(0) ?? '');
        if (val != null && val > maxNum) {
          maxNum = val;
        }
      }
    }

    final nextNum = maxNum + 1;
    return 'P-${nextNum.toString().padLeft(3, '0')}';
  }

  Future<void> agregarPaquete({
    required String numero,
    required String descripcion,
    DateTime? fechaLlegada,
  }) async {
    final paquete = Paquete(
      id: _uuid.v4(),
      numero: numero.trim(),
      descripcion: descripcion.trim(),
      fechaLlegada: fechaLlegada ?? DateTime.now(),
    );
    await _box.put(paquete.id, paquete);
  }

  Future<void> editarPaquete({
    required String id,
    required String numero,
    required String descripcion,
    DateTime? fechaLlegada,
  }) async {
    final paquete = _box.get(id);
    if (paquete != null) {
      paquete.numero = numero.trim();
      paquete.descripcion = descripcion.trim();
      if (fechaLlegada != null) {
        paquete.fechaLlegada = fechaLlegada;
      }
      await paquete.save();
    }
  }

  Future<void> marcarComoEnviado(String id, [DateTime? fechaEnvio]) async {
    final paquete = _box.get(id);
    if (paquete != null) {
      paquete.fechaEnvio = fechaEnvio ?? DateTime.now();
      await paquete.save();
    }
  }

  Future<void> despacharMultiplesPaquetes(List<String> ids, [DateTime? fechaEnvio]) async {
    final now = fechaEnvio ?? DateTime.now();
    for (final id in ids) {
      final paquete = _box.get(id);
      if (paquete != null) {
        paquete.fechaEnvio = now;
        await paquete.save();
      }
    }
  }

  Future<void> revertirAAlmacen(String id) async {
    final paquete = _box.get(id);
    if (paquete != null) {
      paquete.fechaEnvio = null;
      await paquete.save();
    }
  }

  Future<void> eliminarPaquete(String id) async {
    await _box.delete(id);
  }

  Future<void> cargarDatosEjemplo() async {
    final now = DateTime.now();
    final ejemplos = [
      Paquete(
        id: _uuid.v4(),
        numero: 'FZ30',
        descripcion: 'Caja de ropa de Doña Carmen (Envío expreso)',
        fechaLlegada: now.subtract(const Duration(hours: 3)),
      ),
      Paquete(
        id: _uuid.v4(),
        numero: 'GUIA-104',
        descripcion: 'Bolsa con zapatillas deportivas para Carlos Gómez',
        fechaLlegada: now.subtract(const Duration(hours: 5)),
      ),
      Paquete(
        id: _uuid.v4(),
        numero: 'AB22',
        descripcion: 'Sobre con documentos notariales de Doña Rosa',
        fechaLlegada: now.subtract(const Duration(days: 1, hours: 2)),
        fechaEnvio: now.subtract(const Duration(hours: 1)),
      ),
      Paquete(
        id: _uuid.v4(),
        numero: 'XP88',
        descripcion: 'Caja con juego de tazas para María Paz',
        fechaLlegada: now.subtract(const Duration(days: 2)),
        fechaEnvio: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final p in ejemplos) {
      await _box.put(p.id, p);
    }
  }

  Future<void> limpiarTodo() async {
    await _box.clear();
  }
}

final paqueteRepositoryProvider =
    NotifierProvider<PaqueteRepository, void>(PaqueteRepository.new);
