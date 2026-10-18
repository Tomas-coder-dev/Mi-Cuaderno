import 'package:flutter/material.dart';

/// Breakpoints para diseño responsivo
class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileBreakpoint && w < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint;

  /// Ancho máximo para el contenido principal (centrado en web)
  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreakpoint) return 900;
    if (w >= tabletBreakpoint) return 720;
    return double.infinity;
  }

  /// Número de columnas para grid de tarjetas
  static int cardColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreakpoint) return 3;
    if (w >= tabletBreakpoint) return 2;
    return 1;
  }
}
