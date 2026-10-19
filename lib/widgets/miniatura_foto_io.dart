import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/foto_archivo.dart';

class MiniaturaFoto extends StatelessWidget {
  final String? path;
  final double size;

  const MiniaturaFoto({super.key, required this.path, this.size = 64});

  @override
  Widget build(BuildContext context) {
    if (!fotoDisponible(path)) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
