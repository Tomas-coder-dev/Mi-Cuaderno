import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as du;
import 'home_shell.dart';

class AgregarPaqueteScreen extends ConsumerStatefulWidget {
  const AgregarPaqueteScreen({super.key});

  @override
  ConsumerState<AgregarPaqueteScreen> createState() =>
      _AgregarPaqueteScreenState();
}

class _AgregarPaqueteScreenState extends ConsumerState<AgregarPaqueteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaPersonalizada;
  bool _saving = false;

  @override
  void dispose() {
    _numeroController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaLlegada() async {
    final now = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaPersonalizada ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'SELECCIONA EL DÍA QUE LLEGÓ EL PAQUETE',
      confirmText: 'ACEPTAR',
      cancelText: 'CANCELAR',
    );

    if (fecha != null && mounted) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaPersonalizada ?? now),
        helpText: 'SELECCIONA LA HORA',
      );

      if (hora != null && mounted) {
        setState(() {
          _fechaPersonalizada = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final numero = _numeroController.text.trim().toUpperCase();

    await ref.read(paqueteRepositoryProvider.notifier).agregarPaquete(
          numero: numero,
          descripcion: _descripcionController.text.trim(),
          fechaLlegada: _fechaPersonalizada ?? DateTime.now(),
        );

    if (mounted) {
      HapticFeedback.lightImpact();
      _mostrarExito(numero);
      _numeroController.clear();
      _descripcionController.clear();
      setState(() {
        _fechaPersonalizada = null;
        _saving = false;
      });
    }
  }

  void _mostrarExito(String numero) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Paquete $numero guardado!',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VER EN ALMACÉN',
          textColor: Colors.white,
          onPressed: () {
            ref.read(pantallaActualProvider.notifier).state = Pantalla.almacen;
          },
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('✍️ Anotar Paquete'),
        leading: IconButton(
          tooltip: 'Volver al Menú Principal',
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: () {
            ref.read(pantallaActualProvider.notifier).state = Pantalla.menu;
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Botón superior destacado para volver al menú ───────────
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(pantallaActualProvider.notifier).state = Pantalla.menu;
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text('⬅️ Volver a los Botones Principales'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textDark,
                  side: const BorderSide(color: AppTheme.divider, width: 1.5),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Tarjeta de información ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registrar Entrada',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Anota los datos como en tu cuaderno físico',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms),

              const SizedBox(height: 24),

              // ── 1. Código del paquete ──────────────────────────────
              const Text(
                '1. Código o Número del Paquete *',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Escribe el código tal como viene en el paquete o guía',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _numeroController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: 1.2,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ej: FZ30, GUIA-104, B22...',
                  prefixIcon: Icon(
                    Icons.tag_rounded,
                    color: AppTheme.primary,
                    size: 26,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Por favor escribe el número o código del paquete';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── 2. Descripción o Destinatario ──────────────────────
              const Text(
                '2. ¿Para quién es o qué contiene? *',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Anota el nombre de la persona o qué tipo de bulto es',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ej: Caja de ropa para Doña María, zapatillas de Carlos Gómez...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.description_rounded,
                      color: AppTheme.primary,
                      size: 26,
                    ),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Por favor escribe una breve descripción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── 3. Fecha de llegada ────────────────────────────────
              InkWell(
                onTap: _seleccionarFechaLlegada,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _fechaPersonalizada != null
                          ? AppTheme.accent
                          : AppTheme.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _fechaPersonalizada != null
                              ? AppTheme.accentLight
                              : AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: _fechaPersonalizada != null
                              ? AppTheme.accent
                              : AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fechaPersonalizada == null
                                  ? 'Llegada: Hoy (Ahora mismo)'
                                  : 'Llegada: ${du.DateUtils.formatFull(_fechaPersonalizada!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fechaPersonalizada == null
                                  ? 'Toca aquí si el paquete llegó antes'
                                  : 'Toca para volver a cambiar la fecha',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.edit_calendar_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── Botón Guardar ──────────────────────────────────────
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _guardar,
                  icon: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bookmark_added_rounded, size: 26),
                  label: Text(
                    _saving ? 'Guardando en el cuaderno...' : '💾 Guardar en el Cuaderno',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
