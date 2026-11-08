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
import 'package:produtividade_tcc/features/auth/presentation/widgets/password_strength_checklist.dart';

/// Tela de Redefinição de Senha com Código de 6 Dígitos (`RF02`, `RF04`, `E02-T04`).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }
    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Informe um endereço de e-mail válido.';
    }
    return null;
  }

  String? _validateCode(String? value) {
    final String code = (value ?? '').trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'Informe o código numérico de 6 dígitos.';
    }
    return null;
  }

  Future<void> _submitResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final Result<void> result = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(
          email: _emailController.text.trim(),
          codigo: _codeController.text.trim(),
          novaSenha: _passwordController.text,
        );

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
              'Senha redefinida com sucesso! Faça login com sua nova senha.',
            ),
          ),
        );
        GoRouter.maybeOf(context)?.go(AppRoutes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
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
                        'Definir nova senha',
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Digite o código de 6 dígitos enviado para seu e-mail e escolha uma nova senha forte (RF02, RF04).',
                        style: AppTypography.bodyMedium,
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
                      Text('E-mail', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      TextFormField(
                        key: const Key('reset_email_field'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          hintText: 'seu.email@exemplo.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Código de 6 dígitos',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      TextFormField(
                        key: const Key('reset_code_field'),
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: _validateCode,
                        decoration: const InputDecoration(
                          hintText: '000000',
                          counterText: '',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Nova senha', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      TextFormField(
                        key: const Key('reset_password_field'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: PasswordStrengthValidator.validateField,
                        decoration: InputDecoration(
                          hintText: 'Digite sua nova senha forte',
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      PasswordStrengthChecklist(
                        password: _passwordController.text,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryGradientButton(
                        key: const Key('reset_submit_button'),
                        label: 'Redefinir senha',
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _submitResetPassword,
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
