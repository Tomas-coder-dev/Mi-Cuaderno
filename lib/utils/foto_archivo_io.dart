import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> copiarFotoAlCuaderno(String origen) async {
  final archivo = File(origen);
  if (!await archivo.exists()) return null;
  final dir = await getApplicationDocumentsDirectory();
  final carpeta = Directory('${dir.path}${Platform.pathSeparator}fotos_paquetes');
  if (!await carpeta.exists()) {
    await carpeta.create(recursive: true);
  }
  final destino = File(
    '${carpeta.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  await archivo.copy(destino.path);
  return destino.path;
}

Future<void> borrarArchivoFoto(String? path) async {
  if (path == null || path.isEmpty) return;
  final archivo = File(path);
  if (await archivo.exists()) {
    await archivo.delete();
  }
}

bool fotoDisponible(String? path) {
  if (path == null || path.isEmpty) return false;
  return File(path).existsSync();
}
