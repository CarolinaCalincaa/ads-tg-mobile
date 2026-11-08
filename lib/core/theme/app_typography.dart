import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';

/// Tokens tipográficos do Design System "Calma Cognitiva" (`Tech Doc 05 — Seção 1.2`).
///
/// - Títulos principais / Display: **Fraunces** (charme editorial com `letterSpacing: -0.5`).
/// - Corpo, Labels, Números e Controles: **Inter** (com `FontFeature.tabularFigures()`
///   para horários `06:30`, cronômetro `24:59` e porcentagens `82%`).
///
/// Em testes offline (`GoogleFonts.config.allowRuntimeFetching == false`), utiliza
/// fallback direto para evitar tentativas de busca na rede ou falhas de AssetManifest.
abstract final class AppTypography {
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextStyle _displayFont(TextStyle baseStyle) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return baseStyle.copyWith(fontFamily: 'Fraunces');
    }
    return GoogleFonts.fraunces(textStyle: baseStyle);
  }

  static TextStyle _bodyFont(TextStyle baseStyle) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return baseStyle.copyWith(fontFamily: 'Inter');
    }
    return GoogleFonts.inter(textStyle: baseStyle);
  }

  /// Título principal de tela (`24px`, Bold `700`, `letterSpacing: -0.5px`).
  static TextStyle get displayLarge => _displayFont(
    const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.25,
      color: AppColors.textPrimary,
    ),
  );

  /// Título de tela padrão (`Painel do Dia`, `Fechamento Semanal` — `24px`, Bold `700`).
  static TextStyle get displayTitle => _displayFont(
    const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
  );

  /// Subtítulo de seção editorial (`20px`, SemiBold `600`).
  static TextStyle get sectionTitle => _displayFont(
    const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.35,
      color: AppColors.textPrimary,
    ),
  );

  /// Título de card ou item de linha do tempo (`16px`, SemiBold `600`).
  static TextStyle get cardTitle => _bodyFont(
    const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
  );

  /// Corpo de texto principal (`15px`, Regular `400`).
  static TextStyle get bodyLarge => _bodyFont(
    const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
  );

  /// Corpo secundário, subtítulos e descrições (`14px`, Regular `400`).
  static TextStyle get bodyMedium => _bodyFont(
    const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textSecondary,
    ),
  );

  /// Labels de botões e controles (`14px`, SemiBold `600`).
  static TextStyle get labelLarge => _bodyFont(
    const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: AppColors.textPrimary,
    ),
  );

  /// Chips de pilares e tags de prioridade (`12px`, SemiBold `600`).
  static TextStyle get chipLabel => _bodyFont(
    const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: AppColors.textPrimary,
    ),
  );

  /// Números tabulares para horários (`06:30`), durações (`30min`), Pomodoro (`24:59`) e porcentagens (`82%`).
  static TextStyle get tabularNumber => _bodyFont(
    const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: AppColors.textPrimary,
      fontFeatures: tabularFigures,
    ),
  );

  /// Constrói o [TextTheme] completo compatível com Material 3.
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayTitle,
    headlineMedium: displayTitle,
    headlineSmall: sectionTitle,
    titleLarge: sectionTitle,
    titleMedium: cardTitle,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelLarge: labelLarge,
    labelMedium: chipLabel,
    labelSmall: tabularNumber,
  );
}
