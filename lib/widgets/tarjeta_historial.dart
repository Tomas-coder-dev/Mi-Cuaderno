import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paquete.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import '../utils/eliminar_paquete.dart';
import 'miniatura_foto.dart';

class TarjetaHistorial extends ConsumerWidget {
  final Paquete paquete;
  final int index;

  const TarjetaHistorial({
    super.key,
    required this.paquete,
    required this.index,
  });

  void _mostrarDetalles(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetalleHistorialSheet(paquete: paquete),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _mostrarDetalles(context, ref),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador visual verde
              Container(
                width: 4,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.sent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          paquete.numero.startsWith('#') ? paquete.numero : '#${paquete.numero}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.sent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.sent,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'ENVIADO',
                                style: TextStyle(
                                  color: AppTheme.sent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paquete.paraQuien.isEmpty ? paquete.descripcion : paquete.paraQuien,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMedium,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _infoChip(
                          Icons.login_rounded,
                          'Llegó: ${du.DateUtils.formatDate(paquete.fechaLlegada)}',
                          AppTheme.inStock.withValues(alpha: 0.15),
                          AppTheme.inStock,
                        ),
                        if (paquete.fechaEnvio != null)
                          _infoChip(
                            Icons.local_shipping_rounded,
                            'Salió: ${du.DateUtils.formatDate(paquete.fechaEnvio!)} ${du.DateUtils.formatTime(paquete.fechaEnvio!)}',
                            AppTheme.sent.withValues(alpha: 0.15),
                            AppTheme.sent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 25))
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.04, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }

  Widget _infoChip(
    IconData icon,
    String text,
    Color bg,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: iconColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetalleHistorialSheet extends ConsumerWidget {
  final Paquete paquete;
  const _DetalleHistorialSheet({required this.paquete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.sent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ENVIADO',
                    style: TextStyle(
                      color: AppTheme.sent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Para quién es:',
              style: TextStyle(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              paquete.paraQuien.isEmpty ? paquete.descripcion : paquete.paraQuien,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
            if (paquete.detalle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                paquete.detalle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
              ),
            ],
            if (paquete.fotoPath != null) ...[
              const SizedBox(height: 12),
              MiniaturaFoto(path: paquete.fotoPath, size: 96),
            ],
            const SizedBox(height: 14),
            // Fechas con chips visuales
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _fechaChip(
                  Icons.login_rounded,
                  'Llegó: ${du.DateUtils.formatFull(paquete.fechaLlegada)}',
                  AppTheme.inStockLight,
                  AppTheme.inStock,
                ),
                if (paquete.fechaEnvio != null)
                  _fechaChip(
                    Icons.local_shipping_rounded,
                    'Salió: ${du.DateUtils.formatFull(paquete.fechaEnvio!)}',
                    AppTheme.sentLight,
                    AppTheme.sent,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Solo botón eliminar con confirmación
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('¿Eliminar del historial?'),
                      content: Text('Se eliminará el paquete #${paquete.numero}.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            eliminarConDeshacer(context, ref, paquete.id);
                          },
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar del historial', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fechaChip(IconData icon, String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
