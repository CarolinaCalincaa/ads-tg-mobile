import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';

class PainelHeader extends ConsumerWidget {
  const PainelHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UsuarioEntity? usuario = ref.watch(authNotifierProvider).usuario;
    final String primeiroNome =
        usuario?.primeiroNome.isNotEmpty == true ? usuario!.primeiroNome : 'Carolina';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Olá, $primeiroNome 👋',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Painel do Dia',
                style: AppTypography.displayLarge.copyWith(fontSize: 22),
              ),
            ],
          ),
          InkWell(
            key: const Key('header_profile_button'),
            onTap: () {
              GoRouter.maybeOf(context)?.go(AppRoutes.config);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                usuario?.iniciais ?? 'CC',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.surfaceCard,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
