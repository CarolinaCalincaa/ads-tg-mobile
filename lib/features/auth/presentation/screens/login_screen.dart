import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/primary_gradient_button.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/auth/presentation/widgets/oauth_buttons_row.dart';

/// Tela de Login Local e Social OAuth 2.0 (`RF03`, `Tech Doc 05 — Seção 3.1`, `E02-T04`).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
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

  String? _validatePassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Informe sua senha.';
    }
    return null;
  }

  Future<void> _submitLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool success = await ref
        .read(authNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          senha: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      GoRouter.maybeOf(context)?.go(AppRoutes.painel);
    } else {
      final String message =
          ref.read(authNotifierProvider).errorMessage ??
          'Não foi possível entrar. Verifique suas credenciais.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.fatigueCritical,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final bool success =
        await ref.read(authNotifierProvider.notifier).loginWithGoogle();

    if (!mounted) {
      return;
    }

    if (success) {
      GoRouter.maybeOf(context)?.go(AppRoutes.painel);
    } else {
      final String? message = ref.read(authNotifierProvider).errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.fatigueCritical,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    final bool success = await ref
        .read(authNotifierProvider.notifier)
        .loginWithApple(
          mockEmail: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      GoRouter.maybeOf(context)?.go(AppRoutes.painel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: AppColors.surfaceCard,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Calma Cognitiva',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Produtividade pessoal equilibrada, sem sobrecarga mental.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Entrar na sua conta',
                            style: AppTypography.sectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (authState.errorMessage != null) ...<Widget>[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.fatigueBg,
                                borderRadius: AppSpacing.inputRadius,
                                border: Border.all(
                                  color: AppColors.fatigueBorder,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.fatigueCritical,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.fatigueCritical,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          Text(
                            'E-mail',
                            style: AppTypography.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          TextFormField(
                            key: const Key('login_email_field'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                            decoration: const InputDecoration(
                              hintText: 'seu.email@exemplo.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                'Senha',
                                style: AppTypography.labelLarge,
                              ),
                              TextButton(
                                key: const Key('forgot_password_link'),
                                onPressed: () => GoRouter.maybeOf(
                                  context,
                                )?.push(AppRoutes.forgotPassword),
                                child: Text(
                                  'Esqueci minha senha',
                                  style: AppTypography.chipLabel.copyWith(
                                    color: AppColors.primaryBrand,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            key: const Key('login_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            onFieldSubmitted: (_) => _submitLogin(),
                            decoration: InputDecoration(
                              hintText: 'Digite sua senha',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Mostrar senha'
                                    : 'Ocultar senha',
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
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryGradientButton(
                            key: const Key('login_submit_button'),
                            label: 'Entrar',
                            icon: Icons.login_rounded,
                            isLoading: authState.isLoading,
                            onPressed: _submitLogin,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: <Widget>[
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                child: Text(
                                  'ou continue com',
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OAuthButtonsRow(
                            isLoading: authState.isLoading,
                            onGooglePressed: _handleGoogleLogin,
                            onApplePressed: _handleAppleLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        'Ainda não tem conta?',
                        style: AppTypography.bodyMedium,
                      ),
                      TextButton(
                        key: const Key('go_to_register_link'),
                        onPressed: () => GoRouter.maybeOf(
                          context,
                        )?.push(AppRoutes.register),
                        child: Text(
                          'Criar conta',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primaryBrand,
                          ),
                        ),
                      ),
                    ],
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
