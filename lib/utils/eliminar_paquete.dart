import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/paquete_provider.dart';
import 'foto_archivo.dart';

Future<void> eliminarConDeshacer(BuildContext context, WidgetRef ref, String id) async {
  final copia = await ref.read(paqueteRepositoryProvider.notifier).eliminarPaquete(id);
  if (copia == null || !context.mounted) return;
  var deshecho = false;
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text('${copia.codigoVisible} eliminado'),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () {
              deshecho = true;
              ref.read(paqueteRepositoryProvider.notifier).restaurarPaquete(copia);
            },
          ),
        ),
      )
      .closed
      .then((_) {
        if (!deshecho) borrarArchivoFoto(copia.fotoPath);
      });
}
