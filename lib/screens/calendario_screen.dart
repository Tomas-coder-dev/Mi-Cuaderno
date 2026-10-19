import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/paquete.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import '../widgets/barra_superior_navegacion.dart';

final _selectedDayCalProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
final _focusedDayCalProvider = StateProvider<DateTime>((ref) => DateTime.now());

enum TipoFiltroCalendario { llegaron, salieron, todos }

final _tipoFiltroCalProvider =
    StateProvider<TipoFiltroCalendario>((ref) => TipoFiltroCalendario.llegaron);

class CalendarioScreen extends ConsumerWidget {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paquetesAsync = ref.watch(paquetesProvider);
    final selectedDay = ref.watch(_selectedDayCalProvider);
    final focusedDay = ref.watch(_focusedDayCalProvider);
    final tipoFiltro = ref.watch(_tipoFiltroCalProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Barra Superior con botón rápido para ir a Hoy ──
          BarraSuperiorNavegacion(
            titulo: 'Calendario',
            icono: Icons.calendar_month_rounded,
            colorTema: AppTheme.accent,
            accionDerecha: Material(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  final hoy = DateTime.now();
                  ref.read(_selectedDayCalProvider.notifier).state =
                      DateTime(hoy.year, hoy.month, hoy.day);
                  ref.read(_focusedDayCalProvider.notifier).state = hoy;
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.today_rounded, size: 18, color: AppTheme.accent),
                      SizedBox(width: 6),
                      Text(
                        'Hoy',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido ──
          Expanded(
            child: paquetesAsync.when(
              data: (todos) {
                bool fechaCoincide(DateTime dt) {
                  final soloFecha = DateTime(dt.year, dt.month, dt.day);
                  return du.DateUtils.isSameDay(soloFecha, selectedDay);
                }

                // Paquetes que LLEGARON este día
                final paquetesLlegaron =
                    todos.where((p) => fechaCoincide(p.fechaLlegada)).toList();

                // Paquetes que SALIERON este día
                final paquetesSalieron = todos
                    .where((p) => p.fechaEnvio != null && fechaCoincide(p.fechaEnvio!))
                    .toList();

                // Todos los paquetes con movimiento en este día
                final paquetesTodos = <String, Paquete>{};
                for (final p in paquetesLlegaron) {
                  paquetesTodos[p.id] = p;
                }
                for (final p in paquetesSalieron) {
                  paquetesTodos[p.id] = p;
                }
                final listaTodos = paquetesTodos.values.toList();

                // Conteo para los puntitos del calendario
                final Map<DateTime, int> countPorDia = {};
                for (final p in todos) {
                  final dLlegada = du.DateUtils.normalizeDay(p.fechaLlegada);
                  countPorDia[dLlegada] = (countPorDia[dLlegada] ?? 0) + 1;
                  if (p.fechaEnvio != null) {
                    final dEnvio = du.DateUtils.normalizeDay(p.fechaEnvio!);
                    countPorDia[dEnvio] = (countPorDia[dEnvio] ?? 0) + 1;
                  }
                }

                List<Paquete> getEvents(DateTime day) {
                  final count = countPorDia[du.DateUtils.normalizeDay(day)] ?? 0;
                  return List.generate(
                    count,
                    (_) => Paquete(
                      id: '',
                      numero: '',
                      descripcion: '',
                      fechaLlegada: day,
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    // ── 1. CALENDARIO MENSUAL FÁCIL E INTUITIVO ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.divider, width: 1.3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: TableCalendar<Paquete>(
                              firstDay: DateTime(2020),
                              lastDay: DateTime(2030),
                              focusedDay: focusedDay,
                              selectedDayPredicate: (day) =>
                                  du.DateUtils.isSameDay(day, selectedDay),
                              rangeSelectionMode: RangeSelectionMode.disabled,
                              onDaySelected: (selected, focused) {
                                ref.read(_selectedDayCalProvider.notifier).state = selected;
                                ref.read(_focusedDayCalProvider.notifier).state = focused;
                              },
                              onPageChanged: (focused) =>
                                  ref.read(_focusedDayCalProvider.notifier).state = focused,
                              eventLoader: getEvents,
                              locale: 'es_ES',
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              calendarFormat: CalendarFormat.month,
                              availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
                              rowHeight: 52,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                ),
                                leftChevronIcon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: AppTheme.accent,
                                    size: 26,
                                  ),
                                ),
                                rightChevronIcon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.accent,
                                    size: 26,
                                  ),
                                ),
                                headerPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              daysOfWeekHeight: 34,
                              daysOfWeekStyle: const DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: AppTheme.textMedium,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                                weekendStyle: TextStyle(
                                  color: AppTheme.danger,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,
                                defaultTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                  fontSize: 16,
                                ),
                                weekendTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.danger,
                                  fontSize: 16,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: AppTheme.accentLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.accent, width: 2),
                                ),
                                todayTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.accent,
                                  fontSize: 16,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                cellMargin: const EdgeInsets.all(4),
                              ),
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, day, events) {
                                  if (events.isEmpty) return const SizedBox();
                                  final isSel = du.DateUtils.isSameDay(day, selectedDay);
                                  return Positioned(
                                    bottom: 3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSel ? Colors.white : AppTheme.accent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${events.length}',
                                        style: TextStyle(
                                          color: isSel ? AppTheme.accent : Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 250.ms),
                    ),

                    // ── 2. DÍA SELECCIONADO Y PESTAÑAS CLARAS ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.divider, width: 1.3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.event_note_rounded,
                                      color: AppTheme.accent,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          du.DateUtils.formatFriendly(selectedDay),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        if (du.DateUtils.isToday(selectedDay))
                                          const Text(
                                            'Hoy (día actual)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.accent,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Botones de filtro: Llegaron, Salieron, Todos
                              Row(
                                children: [
                                  _FiltroTab(
                                    label: 'Llegaron',
                                    icono: Icons.inventory_2_rounded,
                                    count: paquetesLlegaron.length,
                                    color: AppTheme.inStock,
                                    colorLight: AppTheme.inStockLight,
                                    selected: tipoFiltro == TipoFiltroCalendario.llegaron,
                                    onTap: () => ref.read(_tipoFiltroCalProvider.notifier).state =
                                        TipoFiltroCalendario.llegaron,
                                  ),
                                  const SizedBox(width: 8),
                                  _FiltroTab(
                                    label: 'Salieron',
                                    icono: Icons.local_shipping_rounded,
                                    count: paquetesSalieron.length,
                                    color: AppTheme.sent,
                                    colorLight: AppTheme.sentLight,
                                    selected: tipoFiltro == TipoFiltroCalendario.salieron,
                                    onTap: () => ref.read(_tipoFiltroCalProvider.notifier).state =
                                        TipoFiltroCalendario.salieron,
                                  ),
                                  const SizedBox(width: 8),
                                  _FiltroTab(
                                    label: 'Todos',
                                    icono: Icons.checklist_rounded,
                                    count: listaTodos.length,
                                    color: AppTheme.accent,
                                    colorLight: AppTheme.accentLight,
                                    selected: tipoFiltro == TipoFiltroCalendario.todos,
                                    onTap: () => ref.read(_tipoFiltroCalProvider.notifier).state =
                                        TipoFiltroCalendario.todos,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── 3. LISTADO DE PAQUETES ──
                    () {
                      final List<Paquete> lista = switch (tipoFiltro) {
                        TipoFiltroCalendario.llegaron => paquetesLlegaron,
                        TipoFiltroCalendario.salieron => paquetesSalieron,
                        TipoFiltroCalendario.todos => listaTodos,
                      };

                      if (lista.isEmpty) {
                        final String mensaje = switch (tipoFiltro) {
                          TipoFiltroCalendario.salieron => 'No salió ningún paquete en esta fecha',
                          TipoFiltroCalendario.llegaron => 'No llegó ningún paquete en esta fecha',
                          TipoFiltroCalendario.todos => 'No hubo movimientos en esta fecha',
                        };

                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.surfaceWarm,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      tipoFiltro == TipoFiltroCalendario.salieron
                                          ? Icons.local_shipping_outlined
                                          : Icons.inventory_2_outlined,
                                      size: 38,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    mensaje,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Toca otro día en el calendario de arriba para ver sus paquetes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _TarjetaPaqueteCalendario(
                            paquete: lista[i],
                          ),
                          childCount: lista.length,
                        ),
                      );
                    }(),

                    const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroTab extends StatelessWidget {
  final String label;
  final IconData icono;
  final int count;
  final Color color;
  final Color colorLight;
  final bool selected;
  final VoidCallback onTap;

  const _FiltroTab({
    required this.label,
    required this.icono,
    required this.count,
    required this.color,
    required this.colorLight,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? color : colorLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : color.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icono, size: 15, color: selected ? Colors.white : color),
                    const SizedBox(width: 5),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white.withValues(alpha: 0.95) : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaPaqueteCalendario extends ConsumerWidget {
  final Paquete paquete;

  const _TarjetaPaqueteCalendario({required this.paquete});

  void _mostrarDetalle(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                    paquete.codigoVisible,
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
                      color: paquete.enviado ? AppTheme.sentLight : AppTheme.inStockLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (paquete.enviado ? AppTheme.sent : AppTheme.inStock).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      paquete.enviado ? 'ENVIADO' : 'EN ALMACÉN',
                      style: TextStyle(
                        color: paquete.enviado ? AppTheme.sent : AppTheme.inStock,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
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
              const SizedBox(height: 2),
              Text(
                paquete.paraQuien.isEmpty ? 'Sin nombre' : paquete.paraQuien,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textDark),
              ),
              if (paquete.detalle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  paquete.detalle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
                ),
              ],
              const SizedBox(height: 14),
              // Fechas
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _fechaDetalle(
                    Icons.inventory_2_rounded,
                    'Llegó: ${du.DateUtils.formatFull(paquete.fechaLlegada)}',
                    AppTheme.inStockLight,
                    AppTheme.inStock,
                  ),
                  if (paquete.fechaEnvio != null)
                    _fechaDetalle(
                      Icons.local_shipping_rounded,
                      'Salió: ${du.DateUtils.formatFull(paquete.fechaEnvio!)}',
                      AppTheme.sentLight,
                      AppTheme.sent,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fechaDetalle(IconData icon, String text, Color bg, Color color) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool yaEnviado = paquete.enviado;

    return InkWell(
      onTap: () => _mostrarDetalle(context, ref),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: yaEnviado
                ? AppTheme.sent.withValues(alpha: 0.3)
                : AppTheme.inStock.withValues(alpha: 0.3),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Código y Estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      paquete.codigoVisible,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: yaEnviado ? AppTheme.sentLight : AppTheme.inStockLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (yaEnviado ? AppTheme.sent : AppTheme.inStock).withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          yaEnviado ? Icons.check_circle_rounded : Icons.inventory_2_rounded,
                          size: 15,
                          color: yaEnviado ? AppTheme.sent : AppTheme.inStock,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          yaEnviado ? 'ENVIADO' : 'EN ALMACÉN',
                          style: TextStyle(
                            color: yaEnviado ? AppTheme.sent : AppTheme.inStock,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Para quién
              Text(
                paquete.paraQuien.isEmpty ? 'Sin nombre' : paquete.paraQuien,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (paquete.detalle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  paquete.detalle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
                ),
              ],
              const SizedBox(height: 10),

              // Fechas claras
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.inStockLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.login_rounded, size: 13, color: AppTheme.inStock),
                        const SizedBox(width: 4),
                        Text(
                          'Llegó: ${du.DateUtils.formatDate(paquete.fechaLlegada)} (${du.DateUtils.formatTime(paquete.fechaLlegada)})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.inStock,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (yaEnviado && paquete.fechaEnvio != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.sentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_shipping_rounded, size: 13, color: AppTheme.sent),
                          const SizedBox(width: 4),
                          Text(
                            'Salió: ${du.DateUtils.formatDate(paquete.fechaEnvio!)} (${du.DateUtils.formatTime(paquete.fechaEnvio!)})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.sent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
