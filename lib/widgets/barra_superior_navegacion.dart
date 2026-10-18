import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/home_shell.dart';
import '../theme/app_theme.dart';

class BarraSuperiorNavegacion extends ConsumerWidget {
  final String titulo;
  final IconData icono;
  final Color colorTema;
  final Widget? accionDerecha;

  const BarraSuperiorNavegacion({
    super.key,
    required this.titulo,
    required this.icono,
    this.colorTema = AppTheme.primary,
    this.accionDerecha,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Botón ÚNICO y Claro para Volver al Menú ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ref.read(pantallaActualProvider.notifier).state = Pantalla.menu;
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWarm,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppTheme.textDark,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Menú',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Título con icono de la pantalla ──
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: colorTema.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: colorTema, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Acción derecha opcional ──
          if (accionDerecha != null) ...[
            const SizedBox(width: 8),
            accionDerecha!,
          ],
        ],
      ),
    );
  }
}
