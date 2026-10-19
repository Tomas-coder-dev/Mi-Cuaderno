import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paquete.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import '../utils/grupos_envio.dart';
import '../widgets/barra_superior_navegacion.dart';
import '../widgets/tarjeta_historial.dart';

enum FiltroHistorial { todos, hoy, semana, mes }

final filtroHistorialProvider = StateProvider<FiltroHistorial>(
  (_) => FiltroHistorial.todos,
);

class HistorialScreen extends ConsumerStatefulWidget {
  const HistorialScreen({super.key});

  @override
  ConsumerState<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends ConsumerState<HistorialScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Paquete> _filtrar(
    List<Paquete> list,
    FiltroHistorial filtro,
    String busqueda,
  ) {
    var resultado = switch (filtro) {
      FiltroHistorial.todos => list,
      FiltroHistorial.hoy =>
        list.where((p) => p.fechaEnvio != null && du.DateUtils.isToday(p.fechaEnvio!)).toList(),
      FiltroHistorial.semana =>
        list.where((p) => p.fechaEnvio != null && du.DateUtils.isThisWeek(p.fechaEnvio!)).toList(),
      FiltroHistorial.mes =>
        list.where((p) => p.fechaEnvio != null && du.DateUtils.isThisMonth(p.fechaEnvio!)).toList(),
    };

    final query = busqueda.trim().toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado.where((p) => p.coincideCon(query)).toList();
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final enviados = ref.watch(paquetesEnviadosProvider);
    final viajes = ref.watch(viajesProvider).valueOrNull ?? [];
    final filtro = ref.watch(filtroHistorialProvider);
    final busqueda = ref.watch(busquedaHistorialProvider);
    final totalEnviados = enviados.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Barra Superior Única ──
          BarraSuperiorNavegacion(
            titulo: 'Historial de Envíos',
            icono: Icons.checklist_rounded,
            colorTema: AppTheme.history,
            accionDerecha: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.historyLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.history.withValues(alpha: 0.25)),
              ),
              child: Text(
                '$totalEnviados salieron',
                style: const TextStyle(
                  color: AppTheme.history,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // ── Contenido ──
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Buscador
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.divider, width: 1.3),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        onChanged: (val) {
                          ref.read(busquedaHistorialProvider.notifier).state = val;
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar en paquetes enviados...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.history, size: 22),
                          suffixIcon: busqueda.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppTheme.textLight, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(busquedaHistorialProvider.notifier).state = '';
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                // Filtros de fecha en pastillas
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        (FiltroHistorial.todos, 'Todos los que salieron'),
                        (FiltroHistorial.hoy, 'Salieron Hoy'),
                        (FiltroHistorial.semana, 'Esta Semana'),
                        (FiltroHistorial.mes, 'Este Mes'),
                      ].map((opt) {
                        final (value, label) = opt;
                        final isSelected = filtro == value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) => ref.read(filtroHistorialProvider.notifier).state = value,
                            selectedColor: AppTheme.history,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? AppTheme.history : AppTheme.divider,
                              width: 1.3,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textMedium,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Lista de paquetes entregados
                enviados.when(
                  data: (lista) {
                    final filtrada = _filtrar(lista, filtro, busqueda);

                    if (filtrada.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyHistorial(
                          filtro: filtro,
                          busqueda: busqueda,
                          onLimpiarBusqueda: () {
                            _searchController.clear();
                            ref.read(busquedaHistorialProvider.notifier).state = '';
                          },
                        ),
                      );
                    }

                    final grupos = agruparEnvios(filtrada, viajes);
                    final hayEnviosAgrupados = grupos.any((grupo) => !grupo.suelto);

                    return SliverMainAxisGroup(
                      slivers: [
                        for (final grupo in grupos) ...[
                          if (!grupo.suelto || hayEnviosAgrupados)
                            SliverToBoxAdapter(child: _TituloGrupo(grupo: grupo)),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => TarjetaHistorial(paquete: grupo.paquetes[i], index: i),
                              childCount: grupo.paquetes.length,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.history),
                    ),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text('Error: $e')),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloGrupo extends StatelessWidget {
  final GrupoEnvio grupo;
  const _TituloGrupo({required this.grupo});

  @override
  Widget build(BuildContext context) {
    final cantidad = grupo.paquetes.length;
    final cuando = du.DateUtils.isToday(grupo.fecha)
        ? 'Hoy ${du.DateUtils.formatTime(grupo.fecha)}'
        : du.DateUtils.formatFull(grupo.fecha);
    final nota = grupo.viaje?.nota.trim() ?? '';
    final titulo = grupo.suelto
        ? 'Salidas sin agrupar'
        : '$cuando${nota.isEmpty ? '' : ' · $nota'}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        '$titulo · $cantidad',
        style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.history, fontSize: 14),
      ),
    );
  }
}

class _EmptyHistorial extends StatelessWidget {
  final FiltroHistorial filtro;
  final String busqueda;
  final VoidCallback onLimpiarBusqueda;

  const _EmptyHistorial({
    required this.filtro,
    required this.busqueda,
    required this.onLimpiarBusqueda,
  });

  @override
  Widget build(BuildContext context) {
    if (busqueda.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 54, color: AppTheme.textLight),
              const SizedBox(height: 14),
              Text(
                'No hay envíos con "$busqueda"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onLimpiarBusqueda,
                child: const Text('Limpiar búsqueda', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      );
    }

    final msgs = {
      FiltroHistorial.todos: 'Aún no hay paquetes marcados como enviados.',
      FiltroHistorial.hoy: 'No salieron paquetes hoy.',
      FiltroHistorial.semana: 'No hubo salidas esta semana.',
      FiltroHistorial.mes: 'No hubo salidas este mes.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist_rounded, size: 56, color: AppTheme.textLight),
            const SizedBox(height: 14),
            Text(
              msgs[filtro] ?? 'Sin resultados.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
