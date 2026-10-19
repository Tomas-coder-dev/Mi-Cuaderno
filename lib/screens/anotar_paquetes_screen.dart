import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/paquete_provider.dart';
import '../theme/app_theme.dart';
import '../utils/foto_archivo.dart';
import '../widgets/miniatura_foto.dart';

class AnotarPaquetesScreen extends ConsumerStatefulWidget {
  const AnotarPaquetesScreen({super.key});

  @override
  ConsumerState<AnotarPaquetesScreen> createState() => _AnotarPaquetesScreenState();
}

class _FilaPaquete {
  final codigo = TextEditingController();
  final persona = TextEditingController();
  final telefono = TextEditingController();
  final nota = TextEditingController();
  final focoCodigo = FocusNode();
  String? fotoPath;
  String? error;

  bool get vacia =>
      codigo.text.trim().isEmpty &&
      persona.text.trim().isEmpty &&
      telefono.text.trim().isEmpty &&
      nota.text.trim().isEmpty &&
      (fotoPath == null || fotoPath!.isEmpty);

  void dispose() {
    codigo.dispose();
    persona.dispose();
    telefono.dispose();
    nota.dispose();
    focoCodigo.dispose();
  }
}

class _AnotarPaquetesScreenState extends ConsumerState<AnotarPaquetesScreen> {
  final List<_FilaPaquete> _filas = [];
  bool _guardando = false;
  bool _guardado = false;
  bool _cerrando = false;

  @override
  void initState() {
    super.initState();
    _crearFila();
    _crearFila();
  }

  @override
  void dispose() {
    _cerrando = true;
    for (final fila in _filas) {
      if (!_guardado && fila.fotoPath != null) {
        borrarArchivoFoto(fila.fotoPath);
      }
      fila.dispose();
    }
    super.dispose();
  }

  bool get _hayCambios => _filas.any((fila) => !fila.vacia);

  _FilaPaquete _crearFila() {
    final fila = _FilaPaquete();
    void refrescar() {
      if (!mounted || _cerrando) return;
      setState(() {});
    }

    fila.codigo.addListener(refrescar);
    fila.persona.addListener(refrescar);
    fila.telefono.addListener(refrescar);
    fila.nota.addListener(refrescar);
    _filas.add(fila);
    return fila;
  }

  void _agregarFila() {
    final fila = _crearFila();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) fila.focoCodigo.requestFocus();
    });
  }

  Future<void> _quitarFila(int indice) async {
    if (_filas.length == 1) {
      final fila = _filas.first;
      final foto = fila.fotoPath;
      fila.codigo.clear();
      fila.persona.clear();
      fila.telefono.clear();
      fila.nota.clear();
      fila.fotoPath = null;
      fila.error = null;
      if (foto != null) await borrarArchivoFoto(foto);
      setState(() {});
      return;
    }
    final fila = _filas.removeAt(indice);
    final foto = fila.fotoPath;
    fila.dispose();
    if (foto != null) await borrarArchivoFoto(foto);
    setState(() {});
  }

  Future<void> _elegirFoto(_FilaPaquete fila) async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppTheme.inStock),
              title: const Text('Tomar foto', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.inStock),
              title: const Text('Elegir de la galería', style: TextStyle(fontWeight: FontWeight.w800)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origen == null) return;
    try {
      final foto = await ImagePicker().pickImage(
        source: origen,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (foto == null || !mounted) return;
      final path = await copiarFotoAlCuaderno(foto.path);
      if (!mounted) return;
      if (path == null) {
        _aviso('La foto queda guardada en el teléfono, no en el navegador');
        return;
      }
      final anterior = fila.fotoPath;
      setState(() => fila.fotoPath = path);
      if (anterior != null) await borrarArchivoFoto(anterior);
    } catch (_) {
      if (mounted) _aviso('No pude abrir la foto');
    }
  }

  Future<void> _quitarFoto(_FilaPaquete fila) async {
    final path = fila.fotoPath;
    setState(() => fila.fotoPath = null);
    await borrarArchivoFoto(path);
  }

  Future<bool> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Salir sin guardar?'),
        content: const Text('Hay paquetes escritos que todavía no están en el almacén.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Seguir anotando')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    return salir == true;
  }

  Future<void> _guardar() async {
    final activas = _filas.where((fila) => !fila.vacia).toList();
    if (activas.isEmpty) {
      _aviso('Escribe al menos un paquete');
      return;
    }

    var hayError = false;
    final conteo = <String, int>{};
    for (final fila in _filas) {
      fila.error = null;
      if (fila.vacia) continue;
      if (fila.codigo.text.trim().isEmpty) {
        fila.error = 'Falta el código';
        hayError = true;
      } else if (fila.persona.text.trim().isEmpty) {
        fila.error = 'Falta para quién es';
        hayError = true;
      } else {
        final clave = fila.codigo.text.trim().toLowerCase();
        conteo[clave] = (conteo[clave] ?? 0) + 1;
      }
    }
    for (final fila in activas) {
      final clave = fila.codigo.text.trim().toLowerCase();
      if (clave.isNotEmpty && (conteo[clave] ?? 0) > 1) {
        fila.error = 'Este código está repetido en la lista';
        hayError = true;
      }
    }
    setState(() {});
    if (hayError) return;

    final repetidos = ref.read(paqueteRepositoryProvider.notifier).codigosEnUso(
          activas.map((fila) => fila.codigo.text),
        );
    if (repetidos.isNotEmpty && mounted) {
      final seguir = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Códigos que ya existen'),
          content: Text(
            repetidos.length == 1
                ? '${repetidos.first} ya está en el cuaderno. ¿Lo guardas otra vez?'
                : '${repetidos.join(', ')} ya están en el cuaderno. ¿Los guardas otra vez?',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Revisar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar igual')),
          ],
        ),
      );
      if (seguir != true) return;
    }

    setState(() => _guardando = true);
    try {
      await ref.read(paqueteRepositoryProvider.notifier).agregarVarios([
        for (final fila in activas)
          EntradaPaquete(
            numero: fila.codigo.text,
            destinatario: fila.persona.text,
            telefono: fila.telefono.text,
            descripcion: fila.nota.text,
            fotoPath: fila.fotoPath,
          ),
      ]);
      _guardado = true;
      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context, activas.length);
      }
    } catch (_) {
      if (mounted) _aviso('No pude guardar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _filas.where((fila) => !fila.vacia).length;
    return PopScope(
      canPop: !_hayCambios || _guardado,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final salir = await _confirmarSalida();
        if (salir && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Anotar paquetes')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            for (var i = 0; i < _filas.length; i++) ...[
              _TarjetaFila(
                indice: i,
                fila: _filas[i],
                onQuitar: () => _quitarFila(i),
                onFoto: () => _elegirFoto(_filas[i]),
                onQuitarFoto: () => _quitarFoto(_filas[i]),
              ),
              const SizedBox(height: 12),
            ],
              OutlinedButton.icon(
              onPressed: _agregarFila,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Otro paquete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.inStock,
                side: const BorderSide(color: AppTheme.inStock, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.inStock),
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.inventory_2_rounded),
                label: Text(
                  n == 0 ? 'Escribe al menos un paquete' : 'Guardar $n en el almacén',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaFila extends StatelessWidget {
  final int indice;
  final _FilaPaquete fila;
  final VoidCallback onQuitar;
  final VoidCallback onFoto;
  final VoidCallback onQuitarFoto;

  const _TarjetaFila({
    required this.indice,
    required this.fila,
    required this.onQuitar,
    required this.onFoto,
    required this.onQuitarFoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: fila.error == null ? AppTheme.divider : AppTheme.danger,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Paquete ${indice + 1}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textDark),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Quitar este paquete',
                onPressed: onQuitar,
                icon: const Icon(Icons.close_rounded, color: AppTheme.textLight),
              ),
            ],
          ),
          TextField(
            controller: fila.codigo,
            focusNode: fila.focoCodigo,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
            decoration: const InputDecoration(
              labelText: 'Código',
              hintText: 'FZ30, GUIA-102',
              prefixIcon: Icon(Icons.tag_rounded, color: AppTheme.inStock),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: fila.persona,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '¿Para quién es?',
              hintText: 'Doña Carmen',
              prefixIcon: Icon(Icons.person_rounded, color: AppTheme.inStock),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: fila.telefono,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Teléfono (opcional)',
              hintText: 'Ej. 987 654 321',
              prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.inStock),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: fila.nota,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Qué contiene (opcional)',
              hintText: 'Caja de ropa, sobre, zapatos',
              prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.inStock),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onFoto,
                icon: const Icon(Icons.photo_camera_rounded, size: 18),
                label: Text(fila.fotoPath == null ? 'Foto' : 'Cambiar foto'),
              ),
              const SizedBox(width: 10),
              MiniaturaFoto(path: fila.fotoPath, size: 48),
              if (fila.fotoPath != null)
                IconButton(
                  tooltip: 'Quitar foto',
                  onPressed: onQuitarFoto,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
                ),
            ],
          ),
          if (fila.error != null) ...[
            const SizedBox(height: 6),
            Text(fila.error!, style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}
