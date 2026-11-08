import 'package:flutter/material.dart';

/// Tokens de espaçamento, geometria, elevação e breakpoints responsivos (`Tech Doc 05 — Seção 1.2` e `2.6`).
abstract final class AppSpacing {
  // Grid de espaçamento (4px / 8px)
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  /// Espaçamento inferior reservado em listas para nunca encobrir cards com o FAB (`Tech Doc 05 — Seção 2.2`).
  static const double bottomFabPadding = 96.0;

  // Raios de borda
  static const double cardRadiusValue = 20.0;
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(cardRadiusValue),
  );

  static const double chipRadiusValue = 999.0;
  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(chipRadiusValue),
  );

  static const double inputRadiusValue = 14.0;
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(inputRadiusValue),
  );

  /// Área mínima de toque acessível (48x48dp — `RNF04`).
  static const double minTapTarget = 48.0;

  // Breakpoints Responsivos (RNF03)
  /// Abaixo de 768px: Mobile (`NavigationBar` inferior).
  /// Maior ou igual a 768px: Tablet/Desktop (`NavigationRail` lateral).
  static const double tabletBreakpoint = 768.0;

  /// Maior ou igual a 1100px: Desktop Web SPA (2 colunas no Painel do Dia).
  static const double desktopBreakpoint = 1100.0;

  /// Sombra difusa suave dos cards (`Tech Doc 05 — Seção 1.2`).
  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
