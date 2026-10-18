import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_cuaderno/models/paquete.dart';
import 'package:mi_cuaderno/utils/date_utils.dart' as du;
import 'package:mi_cuaderno/theme/app_theme.dart';

void main() {
  group('Paquete Model Tests', () {
    test('Paquete en almacén no debe estar enviado', () {
      final paquete = Paquete(
        id: '1',
        numero: 'P-001',
        descripcion: 'Caja con zapatos',
        fechaLlegada: DateTime.now(),
      );

      expect(paquete.enviado, isFalse);
      expect(paquete.fechaEnvio, isNull);
    });

    test('Paquete con fechaEnvio debe estar enviado', () {
      final now = DateTime.now();
      final paquete = Paquete(
        id: '2',
        numero: 'P-002',
        descripcion: 'Bolsa con ropa',
        fechaLlegada: now.subtract(const Duration(days: 1)),
        fechaEnvio: now,
      );

      expect(paquete.enviado, isTrue);
      expect(paquete.fechaEnvio, isNotNull);
    });
  });

  group('DateUtils Tests', () {
    test('isSameDay detecta días iguales correctamente', () {
      final d1 = DateTime(2026, 10, 18, 9, 30);
      final d2 = DateTime(2026, 10, 18, 18, 45);
      final d3 = DateTime(2026, 10, 19, 9, 30);

      expect(du.DateUtils.isSameDay(d1, d2), isTrue);
      expect(du.DateUtils.isSameDay(d1, d3), isFalse);
    });

    test('normalizeDay reinicia horas, minutos y segundos a cero', () {
      final dt = DateTime(2026, 10, 18, 14, 25, 30);
      final normal = du.DateUtils.normalizeDay(dt);

      expect(normal.year, equals(2026));
      expect(normal.month, equals(10));
      expect(normal.day, equals(18));
      expect(normal.hour, equals(0));
      expect(normal.minute, equals(0));
      expect(normal.second, equals(0));
    });
  });

  group('AppTheme Tests', () {
    test('AppTheme contiene los colores de diseño adecuados', () {
      expect(AppTheme.primary, const Color(0xFF2E9D68));
      expect(AppTheme.sent, const Color(0xFF16A34A));
      expect(AppTheme.inStock, const Color(0xFF2563EB));
    });
  });
}
