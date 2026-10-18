import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/paquete.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import '../widgets/barra_superior_navegacion.dart';

final _rangeStartProvider = StateProvider<DateTime?>((ref) => null);
final _rangeEndProvider = StateProvider<DateTime?>((ref) => null);
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
    final rangeStart = ref.watch(_rangeStartProvider);
    final rangeEnd = ref.watch(_rangeEndProvider);
    final selectedDay = ref.watch(_selectedDayCalProvider);
    final focusedDay = ref.watch(_focusedDayCalProvider);
    final tipoFiltro = ref.watch(_tipoFiltroCalProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Barra Superior Única (Sin doble botón de regresar) ──
          BarraSuperiorNavegacion(
            titulo: 'Calendario y Fechas',
            icono: Icons.calendar_month_rounded,
            colorTema: AppTheme.accent,
            accionDerecha: TextButton.icon(
              onPressed: () {
                final hoy = DateTime.now();
                ref.read(_rangeStartProvider.notifier).state = null;
                ref.read(_rangeEndProvider.notifier).state = null;
                ref.read(_selectedDayCalProvider.notifier).state =
                    DateTime(hoy.year, hoy.month, hoy.day);
                ref.read(_focusedDayCalProvider.notifier).state = hoy;
              },
              icon: const Icon(Icons.today_rounded, size: 18),
              label: const Text('Hoy', style: TextStyle(fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
            ),
          ),

          // ── Contenido de la pantalla ──
          Expanded(
            child: paquetesAsync.when(
              data: (todos) {
                // Filtrado según día único o rango de fechas
                final bool esRango = rangeStart != null && rangeEnd != null;

                bool fechaEnRango(DateTime dt) {
                  final soloFecha = DateTime(dt.year, dt.month, dt.day);
                  if (esRango) {
                    final inicio = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
                    final fin = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
                    return !soloFecha.isBefore(inicio) && !soloFecha.isAfter(fin);
                  } else if (rangeStart != null) {
                    return du.DateUtils.isSameDay(soloFecha, rangeStart);
                  } else {
                    return du.DateUtils.isSameDay(soloFecha, selectedDay);
                  }
                }

                // Paquetes que LLEGARON (Registrados) en esta fecha/rango
                final paquetesLlegaron = todos.where((p) {
                  return fechaEnRango(p.fechaLlegada);
                }).toList();

                // Paquetes que SALIERON (Enviados) en esta fecha/rango
                final paquetesSalieron = todos.where((p) {
                  return p.fechaEnvio != null && fechaEnRango(p.fechaEnvio!);
                }).toList();

                // Todos los que tuvieron movimiento en esta fecha
                final paquetesTodos = <String, Paquete>{};
                for (final p in paquetesLlegaron) {
                  paquetesTodos[p.id] = p;
                }
                for (final p in paquetesSalieron) {
                  paquetesTodos[p.id] = p;
                }
                final listaTodos = paquetesTodos.values.toList();

                // Marcadores de actividad en el calendario
                Map<DateTime, int> countPorDia = {};
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
                    // ── 1. PRIMERO: EL CALENDARIO (ARRIBA) ────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Guía rápida compacta
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentLight,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.touch_app_rounded, color: AppTheme.accent, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Toca un día o toca 2 días seguidos para marcar un rango',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TableCalendar<Paquete>(
                                firstDay: DateTime(2020),
                                lastDay: DateTime(2030),
                                focusedDay: focusedDay,
                                selectedDayPredicate: (day) =>
                                    rangeStart == null && du.DateUtils.isSameDay(day, selectedDay),
                                rangeStartDay: rangeStart,
                                rangeEndDay: rangeEnd,
                                rangeSelectionMode: RangeSelectionMode.toggledOn,
                                onRangeSelected: (start, end, focused) {
                                  ref.read(_rangeStartProvider.notifier).state = start;
                                  ref.read(_rangeEndProvider.notifier).state = end;
                                  ref.read(_focusedDayCalProvider.notifier).state = focused;
                                  if (start != null && end == null) {
                                    ref.read(_selectedDayCalProvider.notifier).state = start;
                                  }
                                },
                                onDaySelected: (selected, focused) {
                                  ref.read(_rangeStartProvider.notifier).state = null;
                                  ref.read(_rangeEndProvider.notifier).state = null;
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
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textDark,
                                  ),
                                  leftChevronIcon: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: AppTheme.accent,
                                    size: 26,
                                  ),
                                  rightChevronIcon: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.accent,
                                    size: 26,
                                  ),
                                  headerPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    color: AppTheme.textMedium,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                  weekendStyle: TextStyle(
                                    color: AppTheme.danger,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  defaultTextStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                    fontSize: 15,
                                  ),
                                  weekendTextStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.danger,
                                    fontSize: 15,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: AppTheme.accent.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.accent,
                                    fontSize: 15,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  rangeStartDecoration: const BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  rangeEndDecoration: const BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  rangeHighlightColor: AppTheme.accent.withValues(alpha: 0.16),
                                  cellMargin: const EdgeInsets.all(3),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, day, events) {
                                    if (events.isEmpty) return const SizedBox();
                                    return Positioned(
                                      bottom: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${events.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 250.ms),
                    ),

                    // ── 2. SEGUNDO: DETALLE DE FECHAS SELECCIONADAS (ABAJO) ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.divider, width: 1.3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      esRango ? 'RANGO SELECCIONADO' : 'FECHA SELECCIONADA',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (esRango)
                                    TextButton(
                                      onPressed: () {
                                        ref.read(_rangeStartProvider.notifier).state = null;
                                        ref.read(_rangeEndProvider.notifier).state = null;
                                      },
                                      child: const Text('Quitar rango', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                esRango
                                    ? 'Del ${du.DateUtils.formatDayMonth(rangeStart)} al ${du.DateUtils.formatDayMonth(rangeEnd)}'
                                    : '${du.DateUtils.formatDayMonth(selectedDay)} (${du.DateUtils.formatDate(selectedDay)})',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Pestañas: Llegaron vs Salieron vs Todos
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ChoiceChip(
                                      label: Text('Llegaron (${paquetesLlegaron.length})'),
                                      selected: tipoFiltro == TipoFiltroCalendario.llegaron,
                                      onSelected: (_) => ref.read(_tipoFiltroCalProvider.notifier).state =
                                          TipoFiltroCalendario.llegaron,
                                      selectedColor: AppTheme.inStock,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: tipoFiltro == TipoFiltroCalendario.llegaron
                                            ? AppTheme.inStock
                                            : AppTheme.divider,
                                      ),
                                      labelStyle: TextStyle(
                                        color: tipoFiltro == TipoFiltroCalendario.llegaron
                                            ? Colors.white
                                            : AppTheme.textDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: Text('Salieron (${paquetesSalieron.length})'),
                                      selected: tipoFiltro == TipoFiltroCalendario.salieron,
                                      onSelected: (_) => ref.read(_tipoFiltroCalProvider.notifier).state =
                                          TipoFiltroCalendario.salieron,
                                      selectedColor: AppTheme.sent,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: tipoFiltro == TipoFiltroCalendario.salieron
                                            ? AppTheme.sent
                                            : AppTheme.divider,
                                      ),
                                      labelStyle: TextStyle(
                                        color: tipoFiltro == TipoFiltroCalendario.salieron
                                            ? Colors.white
                                            : AppTheme.textDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: Text('Todos (${listaTodos.length})'),
                                      selected: tipoFiltro == TipoFiltroCalendario.todos,
                                      onSelected: (_) => ref.read(_tipoFiltroCalProvider.notifier).state =
                                          TipoFiltroCalendario.todos,
                                      selectedColor: AppTheme.accent,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: tipoFiltro == TipoFiltroCalendario.todos
                                            ? AppTheme.accent
                                            : AppTheme.divider,
                                      ),
                                      labelStyle: TextStyle(
                                        color: tipoFiltro == TipoFiltroCalendario.todos
                                            ? Colors.white
                                            : AppTheme.textDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── 3. LISTA DE PAQUETES (CON ESTADO VISIBLE Y SIN BOTÓN ENVIAR) ──
                    () {
                      final List<Paquete> lista = switch (tipoFiltro) {
                        TipoFiltroCalendario.llegaron => paquetesLlegaron,
                        TipoFiltroCalendario.salieron => paquetesSalieron,
                        TipoFiltroCalendario.todos => listaTodos,
                      };

                      if (lista.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    tipoFiltro == TipoFiltroCalendario.salieron
                                        ? Icons.local_shipping_outlined
                                        : Icons.inventory_2_outlined,
                                    size: 46,
                                    color: AppTheme.textLight,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    tipoFiltro == TipoFiltroCalendario.salieron
                                        ? 'No salió ningún paquete en esta fecha'
                                        : tipoFiltro == TipoFiltroCalendario.llegaron
                                            ? 'No llegó ningún paquete en esta fecha'
                                            : 'No hay paquetes registrados en esta fecha',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textLight,
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
                      color: paquete.enviado ? AppTheme.sentLight : AppTheme.inStockLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (paquete.enviado ? AppTheme.sent : AppTheme.inStock).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      paquete.enviado ? 'YA SALIÓ / ENVIADO' : 'EN ALMACÉN',
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
              if (paquete.fechaEnvio != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping_rounded, size: 18, color: AppTheme.sent),
                    const SizedBox(width: 8),
                    Text(
                      'Salió / Enviado: ${du.DateUtils.formatFull(paquete.fechaEnvio!)}',
                      style: const TextStyle(fontSize: 14, color: AppTheme.textMedium, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
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
              // Fila superior: Código y Estado Explícito (En almacén vs Ya salió)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      paquete.numero.startsWith('#') ? paquete.numero : '#${paquete.numero}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // BADGE OBLIGATORIO: SALE SI ESTÁ EN ALMACÉN O ENVIADO
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
                          yaEnviado ? 'YA SALIÓ / ENVIADO' : 'EN ALMACÉN',
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

              // Descripción
              Text(
                paquete.descripcion,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
                          'Llegó: ${du.DateUtils.formatDate(paquete.fechaLlegada)}',
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
                            'Salió: ${du.DateUtils.formatDate(paquete.fechaEnvio!)}',
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
