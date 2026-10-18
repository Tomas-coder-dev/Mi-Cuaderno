import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';

class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enAlmacen = ref.watch(paquetesEnAlmacenProvider).valueOrNull?.length ?? 0;
    final enviados = ref.watch(paquetesEnviadosProvider).valueOrNull?.length ?? 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Encabezado principal tipo cuaderno cálido ───────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.divider, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.inStockLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.inStock,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PaqueteListo',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Cuaderno de Cargas y Envíos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Resumen rápido en 2 pastillas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppTheme.inStock,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$enAlmacen en almacén',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 20, color: AppTheme.divider),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppTheme.sent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$enviados ya salieron',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05),

              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Toca un cuadro para comenzar',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── 4 BOTONES CUADRADOS GRANDES EN GRILLA 2x2 ───────────────
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 1. Paquetes en Local (Almacén e Ingreso)
                  _BotonCuadrado(
                    titulo: 'PAQUETES\nEN LOCAL',
                    subtitulo: '$enAlmacen en espera',
                    descripcion: 'Llegaron y se anotan aquí',
                    icono: Icons.inventory_2_rounded,
                    colorPrincipal: AppTheme.inStock,
                    colorFondo: AppTheme.inStockLight,
                    onTap: () {
                      ref.read(pantallaActualProvider.notifier).state = Pantalla.almacen;
                    },
                  ),

                  // 2. Despachar / Enviar Paquetes (Seleccionar y enviar)
                  _BotonCuadrado(
                    titulo: 'DESPACHAR\nY ENVIAR',
                    subtitulo: 'Marcar salidas',
                    descripcion: 'Seleccionar los que salen',
                    icono: Icons.local_shipping_rounded,
                    colorPrincipal: AppTheme.sent,
                    colorFondo: AppTheme.sentLight,
                    onTap: () {
                      ref.read(pantallaActualProvider.notifier).state = Pantalla.despachar;
                    },
                  ),

                  // 3. Historial de Entregados
                  _BotonCuadrado(
                    titulo: 'HISTORIAL\nDE ENVÍOS',
                    subtitulo: '$enviados entregados',
                    descripcion: 'Ver los que ya salieron',
                    icono: Icons.checklist_rounded,
                    colorPrincipal: AppTheme.history,
                    colorFondo: AppTheme.historyLight,
                    onTap: () {
                      ref.read(pantallaActualProvider.notifier).state = Pantalla.historial;
                    },
                  ),

                  // 4. Calendario y Fechas
                  _BotonCuadrado(
                    titulo: 'CALENDARIO\nY FECHAS',
                    subtitulo: 'Días y rangos',
                    descripcion: 'Buscar qué llegó o salió',
                    icono: Icons.calendar_month_rounded,
                    colorPrincipal: AppTheme.accent,
                    colorFondo: AppTheme.accentLight,
                    onTap: () {
                      ref.read(pantallaActualProvider.notifier).state = Pantalla.calendario;
                    },
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms).scale(begin: const Offset(0.96, 0.96)),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonCuadrado extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String descripcion;
  final IconData icono;
  final Color colorPrincipal;
  final Color colorFondo;
  final VoidCallback onTap;

  const _BotonCuadrado({
    required this.titulo,
    required this.subtitulo,
    required this.descripcion,
    required this.icono,
    required this.colorPrincipal,
    required this.colorFondo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: colorPrincipal.withValues(alpha: 0.15),
        highlightColor: colorPrincipal.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorPrincipal.withValues(alpha: 0.35),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorPrincipal.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: colorFondo,
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: colorPrincipal, size: 34),
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorFondo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: colorPrincipal,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
