import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paquete.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import '../widgets/barra_superior_navegacion.dart';

class DespacharScreen extends ConsumerStatefulWidget {
  const DespacharScreen({super.key});

  @override
  ConsumerState<DespacharScreen> createState() => _DespacharScreenState();
}

class _DespacharScreenState extends ConsumerState<DespacharScreen> {
  final Set<String> _seleccionados = {};
  final _busqueda = TextEditingController();
  bool _enviando = false;
  String _consulta = '';

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _toggleSeleccion(String id) {
    setState(() {
      if (_seleccionados.contains(id)) {
        _seleccionados.remove(id);
      } else {
        _seleccionados.add(id);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _seleccionarVisibles(List<Paquete> lista) {
    final ids = lista.map((p) => p.id).toSet();
    final todos = ids.isNotEmpty && ids.every(_seleccionados.contains);
    setState(() {
      if (todos) {
        _seleccionados.removeAll(ids);
      } else {
        _seleccionados.addAll(ids);
      }
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _registrarSalidaDirecta() async {
    if (_seleccionados.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    final cantidad = _seleccionados.length;
    try {
      await ref.read(paqueteRepositoryProvider.notifier).despacharVarios(
            _seleccionados.toList(),
            nota: '',
          );
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _seleccionados.clear();
        _enviando = false;
      });
      // Mostrar confirmación con SnackBar y quedarse en la misma pantalla
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cantidad == 1
                      ? '✅ 1 paquete despachado'
                      : '✅ $cantidad paquetes despachados',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.sent,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pude registrar la salida')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enAlmacenAsync = ref.watch(paquetesEnAlmacenProvider);
    final hayPaquetes = enAlmacenAsync.valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const BarraSuperiorNavegacion(
            titulo: 'Despachar y enviar',
            icono: Icons.local_shipping_rounded,
            colorTema: AppTheme.sent,
          ),
          Expanded(
            child: enAlmacenAsync.when(
              data: (paquetes) {
                if (paquetes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(color: AppTheme.sentLight, shape: BoxShape.circle),
                            child: const Icon(Icons.check_circle_rounded, color: AppTheme.sent, size: 52),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '¡Almacén al día!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No hay paquetes en espera para despachar en este momento.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textMedium),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final visibles = paquetes.where((p) => p.coincideCon(_consulta)).toList();
                final todosVisibles = visibles.isNotEmpty && visibles.every((p) => _seleccionados.contains(p.id));

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: TextField(
                        controller: _busqueda,
                        onChanged: (valor) => setState(() => _consulta = valor),
                        decoration: InputDecoration(
                          hintText: 'Buscar por código, persona o teléfono',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.sent),
                          suffixIcon: _consulta.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _busqueda.clear();
                                    setState(() => _consulta = '');
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _seleccionados.isEmpty
                                    ? 'Marca los que salen juntos hoy'
                                    : '${_seleccionados.length} seleccionados',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _seleccionados.isEmpty ? AppTheme.textDark : AppTheme.sent,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: visibles.isEmpty ? null : () => _seleccionarVisibles(visibles),
                              child: Text(
                                todosVisibles ? 'Quitar' : 'Todos',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: visibles.isEmpty
                          ? const Center(
                              child: Text(
                                'Ningún paquete coincide con la búsqueda',
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMedium),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                              itemCount: visibles.length,
                              itemBuilder: (context, i) {
                                final p = visibles[i];
                                final seleccionado = _seleccionados.contains(p.id);
                                return _FilaDespacho(
                                  paquete: p,
                                  seleccionado: seleccionado,
                                  onTap: () => _toggleSeleccion(p.id),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.sent)),
              error: (_, _) => const Center(child: Text('No pude cargar los paquetes')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: hayPaquetes
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _seleccionados.isEmpty ? Colors.grey.shade400 : AppTheme.sent,
                      elevation: _seleccionados.isEmpty ? 0 : 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _seleccionados.isEmpty || _enviando ? null : _registrarSalidaDirecta,
                    icon: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.check_circle_rounded, size: 22),
                    label: Text(
                      _seleccionados.isEmpty
                          ? 'Toca los paquetes que van a salir'
                          : 'Dar salida a ${_seleccionados.length} ${_seleccionados.length == 1 ? "paquete" : "paquetes"} ahora',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _FilaDespacho extends StatelessWidget {
  final Paquete paquete;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FilaDespacho({
    required this.paquete,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dias = paquete.diasEnLocal();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: seleccionado ? AppTheme.sentLight : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: seleccionado ? AppTheme.sent : AppTheme.divider,
              width: seleccionado ? 2.2 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: seleccionado
                    ? AppTheme.sent.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: seleccionado ? AppTheme.sent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: seleccionado ? AppTheme.sent : AppTheme.divider,
                      width: 2,
                    ),
                  ),
                  child: seleccionado
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: seleccionado ? Colors.white : AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: seleccionado
                                  ? AppTheme.sent.withValues(alpha: 0.3)
                                  : AppTheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            paquete.codigoVisible,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: seleccionado ? AppTheme.sentDark : AppTheme.primaryDark,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (dias >= 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.sent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              du.DateUtils.textoEnLocal(dias),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.sentDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      paquete.paraQuien.isEmpty ? 'Sin nombre' : paquete.paraQuien,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                    ),
                    if (paquete.detalle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        paquete.detalle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Fecha destacada y clara
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: seleccionado ? Colors.white : AppTheme.surfaceWarm,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.inStock),
                          const SizedBox(width: 6),
                          Text(
                            'Llegó: ${du.DateUtils.formatFull(paquete.fechaLlegada)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
