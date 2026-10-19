import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'calendario_screen.dart';
import 'despachar_screen.dart';
import 'historial_screen.dart';
import 'inicio_screen.dart';
import 'inventario_screen.dart';

enum Pantalla { menu, almacen, despachar, historial, calendario }

final pantallaActualProvider = StateProvider<Pantalla>((ref) => Pantalla.menu);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantalla = ref.watch(pantallaActualProvider);

    ref.listen<Pantalla>(pantallaActualProvider, (previous, next) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });

    final ancho = Responsive.isWide(context) ? Responsive.contentMaxWidth(context) : 680.0;

    return PopScope(
      canPop: pantalla == Pantalla.menu,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(pantallaActualProvider.notifier).state = Pantalla.menu;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ancho),
              child: switch (pantalla) {
                Pantalla.menu => const InicioScreen(),
                Pantalla.almacen => const InventarioScreen(),
                Pantalla.despachar => const DespacharScreen(),
                Pantalla.historial => const HistorialScreen(),
                Pantalla.calendario => const CalendarioScreen(),
              },
            ),
          ),
        ),
      ),
    );
  }
}
