import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/cuaderno_csv.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final paquetes = ref.read(paquetesProvider).valueOrNull ?? [];
    final viajes = ref.read(viajesProvider).valueOrNull ?? [];
    final csv = exportarRespaldo(RespaldoCuaderno(paquetes: paquetes, viajes: viajes));
    final bytes = utf8.encode('\uFEFF$csv');
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'text/csv',
            name: 'paquete-listo-respaldo.csv',
          ),
        ],
        subject: 'Copia de PaqueteListo',
      ),
    );
  }

  Future<void> _importar(BuildContext context, WidgetRef ref) async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    if (resultado == null || resultado.files.isEmpty) return;
    final bytes = resultado.files.single.bytes;
    if (bytes == null) {
      if (context.mounted) {
        _aviso(context, 'No pude leer ese archivo');
      }
      return;
    }
    final data = importarRespaldo(utf8.decode(bytes));
    if (data.paquetes.isEmpty && data.viajes.isEmpty) {
      if (context.mounted) _aviso(context, 'Ese archivo no tiene paquetes');
      return;
    }
    if (!context.mounted) return;
    final reemplazar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Traer esta copia', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
          'El archivo tiene ${data.paquetes.length} paquetes y ${data.viajes.length} envíos. '
          'Las fotos no viajan en la copia.',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Agregar a lo que ya tengo'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reemplazar todo'),
          ),
        ],
      ),
    );
    if (reemplazar == null || !context.mounted) return;
    await ref.read(paqueteRepositoryProvider.notifier).importarRespaldo(
          data,
          reemplazar: reemplazar,
        );
    if (context.mounted) {
      _aviso(context, reemplazar ? 'Cuaderno reemplazado' : 'Copia agregada al cuaderno');
    }
  }

  void _aviso(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const _TituloSeccion('Copia del cuaderno'),
          const SizedBox(height: 6),
          const Text(
            'Guarda un archivo para no perder los paquetes si cambia el teléfono. Las fotos se quedan en este aparato.',
            style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _Accion(
            icono: Icons.ios_share_rounded,
            titulo: 'Guardar una copia',
            detalle: 'Compartir o descargar el archivo',
            onTap: () => _exportar(context, ref),
          ),
          _Accion(
            icono: Icons.file_open_rounded,
            titulo: 'Traer una copia',
            detalle: 'Agregar o reemplazar desde un archivo',
            onTap: () => _importar(context, ref),
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String texto;
  const _TituloSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark),
    );
  }
}

class _Accion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  const _Accion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider, width: 1.3),
            ),
            child: Row(
              children: [
                Icon(icono, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(detalle, style: const TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
