import 'package:flutter/material.dart';

/// Tokens canônicos de cores do Design System "Calma Cognitiva" (`Tech Doc 05 — Seção 1.1` e `Tech Doc 02`).
///
/// Todos os contrastes foram calibrados para conformidade WCAG 2.1 AA (`>= 4.5:1`).
abstract final class AppColors {
  // Superfícies e Bordas
  static const Color backgroundCanvas = Color(0xFFF8FAFC); // #F8FAFC (Slate 50)
  static const Color surfaceCard = Color(0xFFFFFFFF); // #FFFFFF
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // #F1F5F9
  static const Color borderSubtle = Color(0xFFE2E8F0); // #E2E8F0

  // Textos
  static const Color textPrimary = Color(0xFF0F172A); // #0F172A
  static const Color textSecondary = Color(0xFF64748B); // #64748B

  // Marca e Destaque IA
  static const Color primaryBrand = Color(0xFF6366F1); // #6366F1 (Indigo 500)
  static const Color primaryBrandDark = Color(0xFF4F46E5); // #4F46E5
  static const Color accentViolet = Color(0xFF7C3AED); // #7C3AED

  // Fadiga Mental (RN02) e Capacidade Diária
  static const Color fatigueBg = Color(0xFFFEF2F2); // #FEF2F2
  static const Color fatigueBorder = Color(0xFFFECACA); // #FECACA
  static const Color fatigueCritical = Color(0xFFDC2626); // #DC2626 (> 80%)
  static const Color capacityWarning = Color(0xFFD97706); // #D97706 (61%-80%)
  static const Color capacityHealthy = Color(0xFF10B981); // #10B981 (<= 60%)

  // Prioridades (PriorityBadge — RNF04 / WCAG AA)
  static const Color priorityHighBg = Color(0xFFFEE2E2); // #FEE2E2
  static const Color priorityHighFg = Color(0xFFDC2626); // #DC2626
  static const Color priorityQuickBg = Color(0xFFFEF3C7); // #FEF3C7
  static const Color priorityQuickFg = Color(0xFFB45309); // #B45309
  static const Color priorityDeferBg = Color(0xFFF1F5F9); // #F1F5F9
  static const Color priorityDeferFg = Color(0xFF475569); // #475569

  // Paleta Oficial dos 7 Pilares de Vida (Tech Doc 02 — Seção 2)
  // 1: SAUDE (Saúde)
  static const Color pilarSaude = Color(0xFFEF4444); // #EF4444
  static const Color pilarSaudeBg = Color(0xFFFEF2F2); // #FEF2F2
  // 2: MOVIMENTO (Movimento)
  static const Color pilarMovimento = Color(0xFFF97316); // #F97316
  static const Color pilarMovimentoBg = Color(0xFFFFF7ED); // #FFF7ED
  // 3: SONO (Sono)
  static const Color pilarSono = Color(0xFF6366F1); // #6366F1
  static const Color pilarSonoBg = Color(0xFFEEF2FF); // #EEF2FF
  // 4: MENTE (Mente)
  static const Color pilarMente = Color(0xFF8B5CF6); // #8B5CF6
  static const Color pilarMenteBg = Color(0xFFF5F3FF); // #F5F3FF
  // 5: ESTUDOS (Estudos)
  static const Color pilarEstudos = Color(0xFF10B981); // #10B981
  static const Color pilarEstudosBg = Color(0xFFECFDF5); // #ECFDF5
  // 6: FINANCAS (Finanças)
  static const Color pilarFinancas = Color(0xFFCA8A04); // #CA8A04
  static const Color pilarFinancasBg = Color(0xFFFEFCE8); // #FEFCE8
  // 7: CARREIRA (Carreira)
  static const Color pilarCarreira = Color(0xFF0EA5E9); // #0EA5E9
  static const Color pilarCarreiraBg = Color(0xFFF0F9FF); // #F0F9FF

  /// Gradiente oficial de botões primários (`#6366F1` -> `#7C3AED`).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[primaryBrand, accentViolet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Converte uma string hexadecimal (`#RRGGBB` ou `RRGGBB`) em [Color].
  static Color fromHex(
    String hexString, {
    Color fallback = primaryBrand,
  }) {
    final String cleaned = hexString.trim().replaceFirst('#', '');
    if (cleaned.length == 6) {
      final int? parsed = int.tryParse('FF$cleaned', radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    } else if (cleaned.length == 8) {
      final int? parsed = int.tryParse(cleaned, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return fallback;
  }
}
