import 'package:flutter/material.dart';

class MiniaturaFoto extends StatelessWidget {
  final String? path;
  final double size;

  const MiniaturaFoto({super.key, required this.path, this.size = 64});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
