import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'inicio_screen.dart';
import 'inventario_screen.dart';
import 'despachar_screen.dart';
import 'historial_screen.dart';
import 'calendario_screen.dart';

enum Pantalla { menu, almacen, despachar, historial, calendario }

final pantallaActualProvider = StateProvider<Pantalla>((ref) => Pantalla.menu);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantalla = ref.watch(pantallaActualProvider);

    // Limpia cualquier SnackBar al cambiar de pantalla para que jamás se quede pegado
    ref.listen<Pantalla>(pantallaActualProvider, (previous, next) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
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
    );
  }
}
