import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/paquete.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import '../utils/eliminar_paquete.dart';
import '../utils/foto_archivo.dart';
import 'miniatura_foto.dart';

class TarjetaPaquete extends ConsumerWidget {
  final Paquete paquete;

  const TarjetaPaquete({super.key, required this.paquete});

  Future<void> _abrirEditar(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DialogoEditarPaquete(paquete: paquete),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 26),
            SizedBox(width: 10),
            Text('¿Eliminar paquete?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Seguro que deseas quitar este paquete del cuaderno?',
              style: TextStyle(fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.dangerLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.danger.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_rounded, color: AppTheme.danger, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paquete.codigoVisible,
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.dangerDark, fontSize: 16),
                        ),
                        if (paquete.paraQuien.isNotEmpty)
                          Text(
                            paquete.paraQuien,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark, fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, cancelar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textMedium)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Sí, eliminar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await eliminarConDeshacer(context, ref, paquete.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = paquete.diasEnLocal();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    paquete.codigoVisible,
                    style: const TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                ),
                const Spacer(),
                // ── Botón Editar con icono y texto claro ──
                Material(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _abrirEditar(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded, size: 16, color: AppTheme.accent),
                          SizedBox(width: 4),
                          Text(
                            'Editar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ── Botón Eliminar con icono y texto claro ──
                Material(
                  color: AppTheme.dangerLight,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _confirmarEliminar(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.danger),
                          SizedBox(width: 4),
                          Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              paquete.paraQuien.isEmpty ? 'Sin nombre' : paquete.paraQuien,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            if (paquete.detalle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                paquete.detalle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
              ),
            ],
            if (paquete.telefono.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                paquete.telefono.trim(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMedium),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                MiniaturaFoto(path: paquete.fotoPath),
                if (paquete.fotoPath != null) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: dias >= 1 ? AppTheme.sentLight : AppTheme.inStockLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${du.DateUtils.textoEnLocal(dias)} · ${du.DateUtils.formatFull(paquete.fechaLlegada)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: dias >= 1 ? AppTheme.sentDark : AppTheme.inStock,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0, duration: 250.ms);
  }
}

class _DialogoEditarPaquete extends ConsumerStatefulWidget {
  final Paquete paquete;
  const _DialogoEditarPaquete({required this.paquete});

  @override
  ConsumerState<_DialogoEditarPaquete> createState() => _DialogoEditarPaqueteState();
}

class _DialogoEditarPaqueteState extends ConsumerState<_DialogoEditarPaquete> {
  late final TextEditingController _codigo;
  late final TextEditingController _persona;
  late final TextEditingController _telefono;
  late final TextEditingController _nota;
  late String? _foto;
  bool _fotoCambio = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.paquete;
    _codigo = TextEditingController(text: p.numero);
    _persona = TextEditingController(
      text: p.destinatario.trim().isNotEmpty ? p.destinatario : p.descripcion,
    );
    _telefono = TextEditingController(text: p.telefono);
    _nota = TextEditingController(
      text: p.destinatario.trim().isNotEmpty ? p.descripcion : '',
    );
    _foto = p.fotoPath;
  }

  @override
  void dispose() {
    _codigo.dispose();
    _persona.dispose();
    _telefono.dispose();
    _nota.dispose();
    super.dispose();
  }

  Future<void> _fotoNueva() async {
    try {
      final archivo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1600);
      if (archivo == null) return;
      final path = await copiarFotoAlCuaderno(archivo.path);
      if (!mounted) return;
      if (path == null) {
        setState(() => _error = 'La foto se guarda en el teléfono');
        return;
      }
      setState(() {
        _foto = path;
        _fotoCambio = true;
        _error = null;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'No pude abrir la foto');
    }
  }

  Future<void> _guardar() async {
    if (_codigo.text.trim().isEmpty || _persona.text.trim().isEmpty) {
      setState(() => _error = 'Código y persona son obligatorios');
      return;
    }
    final repo = ref.read(paqueteRepositoryProvider.notifier);
    if (repo.codigoEnUso(_codigo.text, ignorarId: widget.paquete.id)) {
      final seguir = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ese código ya existe'),
          content: const Text('Hay otro paquete con el mismo código. ¿Lo guardas igual?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Revisar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar igual')),
          ],
        ),
      );
      if (seguir != true) return;
    }
    await repo.editarPaquete(
      id: widget.paquete.id,
      numero: _codigo.text,
      descripcion: _nota.text,
      destinatario: _persona.text,
      telefono: _telefono.text,
      fotoPath: _foto,
      actualizarFoto: _fotoCambio,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppTheme.accent, size: 28),
          SizedBox(width: 10),
          Text('Editar paquete', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codigo,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código',
                prefixIcon: Icon(Icons.tag_rounded, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _persona,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: '¿Para quién es?',
                prefixIcon: Icon(Icons.person_rounded, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nota,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Qué contiene (opcional)',
                prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                MiniaturaFoto(path: _foto, size: 48),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _fotoNueva,
                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: Text(_foto == null ? 'Foto' : 'Cambiar'),
                ),
                if (_foto != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => setState(() {
                      _foto = null;
                      _fotoCambio = true;
                    }),
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
                  ),
                ],
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w800)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textMedium)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _guardar,
          child: const Text('Guardar cambios', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
