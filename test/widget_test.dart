import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_cuaderno/models/paquete.dart';
import 'package:mi_cuaderno/models/viaje.dart';
import 'package:mi_cuaderno/utils/cuaderno_csv.dart';
import 'package:mi_cuaderno/utils/date_utils.dart' as du;
import 'package:mi_cuaderno/utils/grupos_envio.dart';
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

    test('isThisWeek cubre de lunes a domingo y no fechas futuras', () {
      final domingo = DateTime(2026, 10, 18, 21);
      expect(du.DateUtils.isThisWeek(DateTime(2026, 10, 12, 0, 5), domingo), isTrue);
      expect(du.DateUtils.isThisWeek(DateTime(2026, 10, 18, 23), domingo), isTrue);
      expect(du.DateUtils.isThisWeek(DateTime(2026, 10, 11, 23), domingo), isFalse);
      expect(du.DateUtils.isThisWeek(DateTime(2026, 10, 19, 0, 1), domingo), isFalse);
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
      expect(AppTheme.primary, const Color(0xFF15803D));
      expect(AppTheme.sent, const Color(0xFFEA580C));
      expect(AppTheme.inStock, const Color(0xFF15803D));
    });
  });

  group('Cuaderno', () {
    test('un paquete lleva los días que corresponde en el local', () {
      final paquete = Paquete(
        id: '1',
        numero: 'FZ30',
        destinatario: 'Doña Carmen',
        fechaLlegada: DateTime(2026, 10, 16, 9),
      );
      expect(paquete.diasEnLocal(DateTime(2026, 10, 18, 20)), 2);
      expect(paquete.codigoVisible, '#FZ30');
      expect(paquete.coincideCon('carmen'), isTrue);
    });

    test('la copia csv conserva comas, comillas y el envío', () {
      final viaje = Viaje(id: 'v1', fecha: DateTime.utc(2026, 10, 18, 15), nota: 'Guía, "norte"');
      final paquete = Paquete(
        id: 'p1',
        numero: 'AB22',
        descripcion: 'Caja\nde ropa',
        destinatario: 'María',
        telefono: '51987654321',
        fechaLlegada: DateTime.utc(2026, 10, 18, 10),
        fechaEnvio: DateTime.utc(2026, 10, 18, 15),
        viajeId: 'v1',
      );
      final texto = exportarRespaldo(RespaldoCuaderno(paquetes: [paquete], viajes: [viaje]));
      final leido = importarRespaldo(texto);
      expect(leido.viajes.single.nota, 'Guía, "norte"');
      expect(leido.paquetes.single.descripcion, 'Caja\nde ropa');
      expect(leido.paquetes.single.viajeId, 'v1');
      expect(leido.paquetes.single.telefono, '51987654321');
    });

    test('los paquetes de un mismo envío quedan juntos', () {
      final viaje = Viaje(id: 'v1', fecha: DateTime(2026, 10, 18, 18), nota: 'Tarde');
      final a = Paquete(
        id: 'a',
        numero: 'A',
        fechaLlegada: DateTime(2026, 10, 18, 9),
        fechaEnvio: viaje.fecha,
        viajeId: viaje.id,
      );
      final b = Paquete(
        id: 'b',
        numero: 'B',
        fechaLlegada: DateTime(2026, 10, 18, 9),
        fechaEnvio: viaje.fecha,
        viajeId: viaje.id,
      );
      final suelto = Paquete(
        id: 'c',
        numero: 'C',
        fechaLlegada: DateTime(2026, 10, 17),
        fechaEnvio: DateTime(2026, 10, 17, 12),
      );
      final grupos = agruparEnvios([suelto, a, b], [viaje]);
      expect(grupos.first.viajeId, 'v1');
      expect(grupos.first.paquetes, hasLength(2));
      expect(grupos.last.suelto, isTrue);
    });
  });
}
