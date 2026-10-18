import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/barra_superior_navegacion.dart';
import '../widgets/tarjeta_paquete.dart';
import 'home_shell.dart';

class InventarioScreen extends ConsumerStatefulWidget {
  const InventarioScreen({super.key});

  @override
  ConsumerState<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends ConsumerState<InventarioScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirModalIngreso(BuildContext context) {
    final codigoCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Anotar Paquete que Llegó',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Escribe el código del paquete y para quién es.',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
                  ),
                  const SizedBox(height: 20),
                  // Código
                  const Text(
                    'Código del Paquete',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: codigoCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    decoration: const InputDecoration(
                      hintText: 'Ej: FZ30, GUIA-102, B22...',
                      prefixIcon: Icon(Icons.tag_rounded, color: AppTheme.inStock, size: 24),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Escribe el código del paquete' : null,
                  ),
                  const SizedBox(height: 16),
                  // Descripción
                  const Text(
                    '¿Para quién es o qué contiene?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Ej: Ropa de Doña Carmen, caja de zapatos...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Icon(Icons.description_rounded, color: AppTheme.inStock, size: 24),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Escribe para quién es o el contenido' : null,
                  ),
                  const SizedBox(height: 24),
                  // Botón Guardar
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.inStock),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final codigo = codigoCtrl.text.trim().toUpperCase();
                        final desc = descCtrl.text.trim();

                        await ref.read(paqueteRepositoryProvider.notifier).agregarPaquete(
                              numero: codigo,
                              descripcion: desc,
                            );

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Paquete #$codigo anotado en el almacén'),
                              backgroundColor: AppTheme.inStock,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 22),
                      label: const Text('Guardar en Almacén', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paquetesFiltradosAsync = ref.watch(paquetesFiltradosAlmacenProvider);
    final todosEnAlmacenAsync = ref.watch(paquetesEnAlmacenProvider);
    final busqueda = ref.watch(busquedaInventarioProvider);
    final totalAlmacen = todosEnAlmacenAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Barra superior única (Sin doble botón de regresar) ──
          BarraSuperiorNavegacion(
            titulo: 'Paquetes en Local',
            icono: Icons.inventory_2_rounded,
            colorTema: AppTheme.inStock,
            accionDerecha: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.inStockLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.inStock.withValues(alpha: 0.25)),
              ),
              child: Text(
                '$totalAlmacen en espera',
                style: const TextStyle(
                  color: AppTheme.inStock,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // ── Contenido de la pantalla ──
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Solo si HAY paquetes en el almacén mostramos el botón superior y buscador
                if (totalAlmacen > 0) ...[
                  // Botón para anotar nuevo paquete + acceso rápido a Despachar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () => _abrirModalIngreso(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.inStock,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                                label: const Text(
                                  'Anotar Paquete',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ref.read(pantallaActualProvider.notifier).state = Pantalla.despachar;
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.sent,
                                  side: const BorderSide(color: AppTheme.sent, width: 1.5),
                                  backgroundColor: AppTheme.sentLight,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.local_shipping_rounded, size: 20),
                                label: const Text(
                                  'Enviar',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Buscador
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                            ref.read(busquedaInventarioProvider.notifier).state = val;
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar por código o persona...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.inStock, size: 22),
                            suffixIcon: busqueda.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: AppTheme.textLight, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(busquedaInventarioProvider.notifier).state = '';
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
                ],

                // ── Lista o Estado Vacío ──
                paquetesFiltradosAsync.when(
                  data: (paquetes) {
                    // Si el almacén está completamente vacío (SOLO UN BOTÓN CENTRAL)
                    if (totalAlmacen == 0) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.inStockLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 52,
                                    color: AppTheme.inStock,
                                  ),
                                ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                                const SizedBox(height: 20),
                                const Text(
                                  '¡Almacén al día!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No tienes paquetes en espera en el local en este momento.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textMedium,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Único botón de la pantalla en estado vacío
                                SizedBox(
                                  height: 54,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _abrirModalIngreso(context),
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                                    label: const Text(
                                      'Anotar Paquete que Llegó',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.inStock,
                                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Búsqueda sin resultados
                    if (paquetes.isEmpty && busqueda.isNotEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 54, color: AppTheme.textLight),
                                const SizedBox(height: 14),
                                Text(
                                  'No hay paquetes con "$busqueda"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(busquedaInventarioProvider.notifier).state = '';
                                  },
                                  child: const Text('Mostrar todos', style: TextStyle(fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => TarjetaPaquete(paquete: paquetes[i]),
                        childCount: paquetes.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.inStock),
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
