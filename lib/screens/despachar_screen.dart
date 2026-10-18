import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paquete.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import '../widgets/barra_superior_navegacion.dart';
import 'home_shell.dart';

class DespacharScreen extends ConsumerStatefulWidget {
  const DespacharScreen({super.key});

  @override
  ConsumerState<DespacharScreen> createState() => _DespacharScreenState();
}

class _DespacharScreenState extends ConsumerState<DespacharScreen> {
  final Set<String> _seleccionados = {};
  bool _enviando = false;

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

  void _seleccionarTodos(List<Paquete> lista) {
    setState(() {
      if (_seleccionados.length == lista.length) {
        _seleccionados.clear();
      } else {
        _seleccionados.addAll(lista.map((p) => p.id));
      }
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _confirmarEnvio() async {
    if (_seleccionados.isEmpty) return;
    setState(() => _enviando = true);

    final cantidad = _seleccionados.length;
    final idsAEnviar = _seleccionados.toList();

    await ref
        .read(paqueteRepositoryProvider.notifier)
        .despacharMultiplesPaquetes(idsAEnviar);

    if (mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _seleccionados.clear();
        _enviando = false;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppTheme.sent, size: 34),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡Envío Registrado!',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ),
            ],
          ),
          content: Text(
            'Se marcaron $cantidad paquete${cantidad == 1 ? '' : 's'} como despachados y pasaron a tu historial de envíos.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(pantallaActualProvider.notifier).state = Pantalla.historial;
              },
              child: const Text('Ver en Historial', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(pantallaActualProvider.notifier).state = Pantalla.menu;
              },
              child: const Text('Volver al Menú'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enAlmacenAsync = ref.watch(paquetesEnAlmacenProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Barra Superior Única ──
          BarraSuperiorNavegacion(
            titulo: 'Despachar y Enviar',
            icono: Icons.local_shipping_rounded,
            colorTema: AppTheme.sent,
          ),

          // ── Contenido ──
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
                            decoration: const BoxDecoration(
                              color: AppTheme.sentLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inventory_2_outlined, color: AppTheme.sent, size: 52),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No hay paquetes para enviar',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'El almacén está vacío. Cuando anotes nuevos paquetes en el almacén, podrás seleccionarlos aquí para enviarlos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: AppTheme.textMedium),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.inStock),
                            onPressed: () {
                              ref.read(pantallaActualProvider.notifier).state = Pantalla.almacen;
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: const Text('Anotar Paquetes en Local'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final todosSeleccionados = _seleccionados.length == paquetes.length;

                return Column(
                  children: [
                    // Indicador de selección clara
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                    ? 'Marca los paquetes que saldrán en viaje:'
                                    : '${_seleccionados.length} seleccionado${_seleccionados.length == 1 ? '' : 's'} para enviar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _seleccionados.isEmpty ? AppTheme.textDark : AppTheme.sent,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _seleccionarTodos(paquetes),
                              icon: Icon(
                                todosSeleccionados ? Icons.clear_all_rounded : Icons.select_all_rounded,
                                size: 20,
                              ),
                              label: Text(
                                todosSeleccionados ? 'Desmarcar' : 'Seleccionar todos',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.sent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lista de paquetes para seleccionar
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                        itemCount: paquetes.length,
                        itemBuilder: (context, i) {
                          final p = paquetes[i];
                          final seleccionado = _seleccionados.contains(p.id);

                          return GestureDetector(
                            onTap: () => _toggleSeleccion(p.id),
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
                                        ? AppTheme.sent.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Checkbox visual grande y cómodo
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: seleccionado ? AppTheme.sent : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: seleccionado ? AppTheme.sent : AppTheme.divider,
                                        width: 2,
                                      ),
                                    ),
                                    child: seleccionado
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  // Datos del paquete
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              p.numero.startsWith('#') ? p.numero : '#${p.numero}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: seleccionado ? AppTheme.sentDark : AppTheme.textDark,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppTheme.inStockLight,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'En almacén',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.inStock,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.descripcion,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Llegó: ${du.DateUtils.formatFull(p.fechaLlegada)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textLight,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.sent)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      // Botón gigante flotante
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _seleccionados.isEmpty ? Colors.grey.shade400 : AppTheme.sent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _seleccionados.isEmpty || _enviando ? null : _confirmarEnvio,
              icon: _enviando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.local_shipping_rounded, size: 24),
              label: Text(
                _seleccionados.isEmpty
                    ? 'Marca los paquetes que saldrán'
                    : 'ENVIAR ${_seleccionados.length} PAQUETE${_seleccionados.length == 1 ? '' : 'S'} AHORA',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
