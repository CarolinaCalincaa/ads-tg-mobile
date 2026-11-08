import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/auth/presentation/widgets/delete_account_dialog.dart';
import 'package:produtividade_tcc/features/auth/presentation/widgets/sleep_hours_selector_card.dart';

/// Tela da 4ª Aba (`Config.` — `/config`): Perfil, Horas de Sono (`RF05` / `RN02`) e Exclusão Definitiva LGPD (`RNF07`) (`E02-T05`).
class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  late final TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    final String initialName =
        ref.read(authNotifierProvider).usuario?.nomeCompleto ?? '';
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final String trimmed = _nameController.text.trim();
    if (trimmed.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome deve ter ao menos 2 caracteres.'),
          backgroundColor: AppColors.fatigueCritical,
        ),
      );
      return;
    }

    final Result<UsuarioEntity> result = await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(nomeCompleto: trimmed);

    if (!mounted) {
      return;
    }

    result.fold(
      onFailure: (AppFailure failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.fatigueCritical,
          ),
        );
      },
      onSuccess: (_) {
        setState(() {
          _isEditingName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nome atualizado com sucesso.'),
          ),
        );
      },
    );
  }

  Future<void> _saveSleepHours(int newSleepHours) async {
    final Result<UsuarioEntity> result = await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(horasSonoDiarias: newSleepHours);

    if (!mounted) {
      return;
    }

    result.fold(
      onFailure: (AppFailure failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.fatigueCritical,
          ),
        );
      },
      onSuccess: (UsuarioEntity updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sono atualizado para ${updated.horasSonoDiarias}h/noite (limite saudável: ${updated.limiteFadigaMinutos} min).',
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) {
      return;
    }
    GoRouter.maybeOf(context)?.go(AppRoutes.login);
  }

  Future<void> _openDeleteAccountDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return DeleteAccountDialog(
          onConfirmDelete: () async {
            final Result<void> result = await ref
                .read(authNotifierProvider.notifier)
                .deleteAccount();
            if (!mounted) {
              return;
            }
            result.fold(
              onFailure: (AppFailure failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(failure.message),
                    backgroundColor: AppColors.fatigueCritical,
                  ),
                );
              },
              onSuccess: (_) {
                GoRouter.maybeOf(context)?.go(AppRoutes.login);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authNotifierProvider);
    final UsuarioEntity user =
        authState.usuario ??
        const UsuarioEntity(
          id: 'guest',
          nomeCompleto: 'Usuária',
          email: 'usuario@exemplo.com',
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.bottomFabPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. Cartão de Perfil do Usuário
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user.iniciais,
                                style: AppTypography.sectionTitle.copyWith(
                                  color: AppColors.surfaceCard,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    user.nomeCompleto,
                                    style: AppTypography.cardTitle,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    user.email,
                                    style: AppTypography.bodyMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: 2,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.surfaceSubtle,
                                      borderRadius: AppSpacing.chipRadius,
                                    ),
                                    child: Text(
                                      'Acesso via ${user.provedorOauth.displayLabel}',
                                      style: AppTypography.chipLabel.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: const Key('toggle_edit_name_button'),
                              tooltip: 'Editar nome',
                              onPressed: () {
                                setState(() {
                                  _nameController.text = user.nomeCompleto;
                                  _isEditingName = !_isEditingName;
                                });
                              },
                              icon: Icon(
                                _isEditingName
                                    ? Icons.close_rounded
                                    : Icons.edit_outlined,
                                color: AppColors.primaryBrand,
                              ),
                            ),
                          ],
                        ),
                        if (_isEditingName) ...<Widget>[
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Editar nome completo',
                            style: AppTypography.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  key: const Key('config_name_field'),
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Seu nome completo',
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              ElevatedButton(
                                key: const Key('save_name_button'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBrand,
                                  foregroundColor: AppColors.surfaceCard,
                                  minimumSize: const Size(
                                    0,
                                    AppSpacing.minTapTarget,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppSpacing.inputRadius,
                                  ),
                                ),
                                onPressed: authState.isLoading
                                    ? null
                                    : _saveName,
                                child: const Text('Salvar'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Seletor de Horas de Sono (RF05 / RN02)
                  SleepHoursSelectorCard(
                    initialSleepHours: user.horasSonoDiarias,
                    isSaving: authState.isLoading,
                    onSave: _saveSleepHours,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Sessão
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: OutlinedButton.icon(
                      key: const Key('logout_button'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          AppSpacing.minTapTarget,
                        ),
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.inputRadius,
                        ),
                      ),
                      onPressed: authState.isLoading ? null : _handleLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sair da conta'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 4. Zona Crítica de Privacidade e LGPD (RNF07)
                  AppCard(
                    backgroundColor: AppColors.fatigueBg,
                    borderColor: AppColors.fatigueBorder,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.shield_outlined,
                              color: AppColors.fatigueCritical,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Privacidade e LGPD (RNF07)',
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.fatigueCritical,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Você possui controle integral sobre seus dados pessoais e de produtividade. Ao excluir sua conta, todos os registros são removidos permanentemente do servidor.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          key: const Key('open_delete_account_dialog_button'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fatigueCritical,
                            foregroundColor: AppColors.surfaceCard,
                            minimumSize: const Size(
                              double.infinity,
                              AppSpacing.minTapTarget,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppSpacing.inputRadius,
                            ),
                          ),
                          onPressed: authState.isLoading
                              ? null
                              : _openDeleteAccountDialog,
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text(
                            'Excluir minha conta e todos os dados definitivamente',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
