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
import 'package:produtividade_tcc/core/widgets/primary_gradient_button.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';

/// Tela de Solicitação de Recuperação de Senha (`RF04`, `Tech Doc 05 — Seção 3.1`, `E02-T04`).
///
/// Envia código temporário de 6 dígitos (expiração de 15 min) via `POST /api/v1/auth/forgot-password`.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Informe seu e-mail cadastrado.';
    }
    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Informe um endereço de e-mail válido.';
    }
    return null;
  }

  Future<void> _submitForgotPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final Result<void> result = await ref
        .read(authNotifierProvider.notifier)
        .forgotPassword(email: email);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      onFailure: (AppFailure failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Código de 6 dígitos enviado! Verifique seu e-mail (ou Mailpit em localhost:8025).',
            ),
          ),
        );
        GoRouter.maybeOf(context)?.push(
          Uri(
            path: AppRoutes.resetPassword,
            queryParameters: <String, String>{'email': email},
          ).toString(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Esqueceu sua senha?',
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Informe seu e-mail e enviaremos um código numérico de 6 dígitos com validade de 15 minutos.',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.pilarSonoBg,
                          borderRadius: AppSpacing.inputRadius,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.pilarSono,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Em ambiente local de desenvolvimento, consulte o código na caixa de entrada do Mailpit (http://localhost:8025).',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_errorMessage != null) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.fatigueBg,
                            borderRadius: AppSpacing.inputRadius,
                            border: Border.all(color: AppColors.fatigueBorder),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.fatigueCritical,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      Text('E-mail cadastrado', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      TextFormField(
                        key: const Key('forgot_email_field'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          hintText: 'seu.email@exemplo.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryGradientButton(
                        key: const Key('forgot_submit_button'),
                        label: 'Enviar código de 6 dígitos',
                        icon: Icons.send_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _submitForgotPassword,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        key: const Key('already_have_code_button'),
                        onPressed: () {
                          final String email = _emailController.text.trim();
                          GoRouter.maybeOf(context)?.push(
                            Uri(
                              path: AppRoutes.resetPassword,
                              queryParameters: email.isNotEmpty
                                  ? <String, String>{'email': email}
                                  : null,
                            ).toString(),
                          );
                        },
                        child: Text(
                          'Já tenho o código de 6 dígitos',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primaryBrand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
