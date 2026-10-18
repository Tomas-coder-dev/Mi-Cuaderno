import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paquete.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;

class TarjetaPaquete extends ConsumerWidget {
  final Paquete paquete;
  final VoidCallback? onDismissed;

  const TarjetaPaquete({
    super.key,
    required this.paquete,
    this.onDismissed,
  });

  void _abrirEditar(BuildContext context, WidgetRef ref) {
    final numCtrl = TextEditingController(text: paquete.numero);
    final descCtrl = TextEditingController(text: paquete.descripcion);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('✏️ Editar Paquete', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código del Paquete',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción / Para quién es',
                prefixIcon: Icon(Icons.description_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (numCtrl.text.trim().isNotEmpty && descCtrl.text.trim().isNotEmpty) {
                ref.read(paqueteRepositoryProvider.notifier).editarPaquete(
                  id: paquete.id,
                  numero: numCtrl.text.trim().toUpperCase(),
                  descripcion: descCtrl.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar paquete?'),
        content: Text('Se eliminará del almacén el paquete #${paquete.numero}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              ref.read(paqueteRepositoryProvider.notifier).eliminarPaquete(paquete.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarOpciones(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetallePaqueteSheet(
        paquete: paquete,
        onEditar: () => _abrirEditar(context, ref),
        onEliminar: () => _confirmarEliminar(context, ref),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _mostrarOpciones(context, ref),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppTheme.divider, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Fila de código y badge de almacén ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          paquete.numero.startsWith('#') ? paquete.numero : '#${paquete.numero}',
                          style: const TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Badge claro que está en almacén
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.inStockLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.inStock.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.home_work_rounded,
                          color: AppTheme.inStock,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'EN ALMACÉN',
                          style: TextStyle(
                            color: AppTheme.inStock,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Descripción o para quién es ──
              Text(
                paquete.descripcion,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // ── Fecha en que llegó al almacén ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      size: 16,
                      color: AppTheme.inStock,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Llegó / Registrado: ${du.DateUtils.formatFull(paquete.fechaLlegada)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Botones de acciones rápidas (Editar y Eliminar) ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _abrirEditar(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textDark,
                        side: const BorderSide(color: AppTheme.divider, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 16, color: AppTheme.textMedium),
                      label: const Text('Editar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmarEliminar(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                        side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.3), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.danger),
                      label: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}

class _DetallePaqueteSheet extends StatelessWidget {
  final Paquete paquete;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _DetallePaqueteSheet({
    required this.paquete,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  paquete.numero.startsWith('#') ? paquete.numero : '#${paquete.numero}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.inStockLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.inStock.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '📦 EN ALMACÉN',
                    style: TextStyle(
                      color: AppTheme.inStock,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción / Para quién es:',
              style: TextStyle(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              paquete.descripcion,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.login_rounded, size: 18, color: AppTheme.inStock),
                const SizedBox(width: 8),
                Text(
                  'Llegó al almacén: ${du.DateUtils.formatFull(paquete.fechaLlegada)}',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textMedium, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEditar();
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: const BorderSide(color: AppTheme.danger),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onEliminar();
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
