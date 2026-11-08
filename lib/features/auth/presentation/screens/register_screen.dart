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
import 'package:produtividade_tcc/features/auth/presentation/widgets/password_strength_checklist.dart';

/// Tela de Cadastro de Usuário (`RF01`, `RF02`, `RF05`, `RNF07`, `E02-T04`).
///
/// Valida em tempo real os 5 critérios de força de senha (`RF02`), permite definir
/// a média inicial de horas de sono (`8h` padrão — `RN02`) e exige consentimento LGPD (`RNF07`).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  int _horasSonoDiarias = 8;
  bool _lgpdAccepted = false;
  bool _showLgpdError = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final String name = (value ?? '').trim();
    if (name.length < 2) {
      return 'Informe seu nome completo (mínimo 2 caracteres).';
    }
    if (name.length > 150) {
      return 'O nome deve ter no máximo 150 caracteres.';
    }
    return null;
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

  Future<void> _submitRegister() async {
    final bool formValid = _formKey.currentState?.validate() ?? false;
    if (!_lgpdAccepted) {
      setState(() {
        _showLgpdError = true;
      });
    }
    if (!formValid || !_lgpdAccepted) {
      return;
    }

    final bool success = await ref
        .read(authNotifierProvider.notifier)
        .register(
          nomeCompleto: _nameController.text.trim(),
          email: _emailController.text.trim(),
          senha: _passwordController.text,
          horasSonoDiarias: _horasSonoDiarias,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      GoRouter.maybeOf(context)?.go(AppRoutes.painel);
    } else {
      final String message =
          ref.read(authNotifierProvider).errorMessage ??
          'Não foi possível concluir o cadastro.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.fatigueCritical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authNotifierProvider);
    final int horasUteis = 24 - _horasSonoDiarias;
    final int minutosUteis = horasUteis * 60;
    final int limiteSaudavel = (minutosUteis * 0.8).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Comece sua rotina sustentável',
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Configure seu perfil e suas horas de sono para calibrar seu limite saudável de energia diária.',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (authState.errorMessage != null) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.fatigueBg,
                            borderRadius: AppSpacing.inputRadius,
                            border: Border.all(color: AppColors.fatigueBorder),
                          ),
                          child: Text(
                            authState.errorMessage!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.fatigueCritical,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      Text('Nome completo', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      TextFormField(
                        key: const Key('register_name_field'),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                        decoration: const InputDecoration(
                          hintText: 'Ex.: Carolina Silva',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('E-mail', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      TextFormField(
                        key: const Key('register_email_field'),
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
                      Text('Senha', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      TextFormField(
                        key: const Key('register_password_field'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: PasswordStrengthValidator.validateField,
                        decoration: InputDecoration(
                          hintText: 'Crie uma senha forte',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.pilarSonoBg,
                          borderRadius: AppSpacing.inputRadius,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.bedtime_outlined,
                                  size: 18,
                                  color: AppColors.pilarSono,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    'Média de sono por noite',
                                    style: AppTypography.labelLarge,
                                  ),
                                ),
                                Text(
                                  '${_horasSonoDiarias}h',
                                  style: AppTypography.tabularNumber.copyWith(
                                    color: AppColors.pilarSono,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              key: const Key('register_sleep_slider'),
                              value: _horasSonoDiarias.toDouble(),
                              min: 4,
                              max: 12,
                              divisions: 8,
                              label: '${_horasSonoDiarias}h',
                              activeColor: AppColors.pilarSono,
                              onChanged: (double value) {
                                setState(() {
                                  _horasSonoDiarias = value.round();
                                });
                              },
                            ),
                            Text(
                              'Capacidade útil diária: ${horasUteis}h ($minutosUteis min) • Limite saudável (80%): $limiteSaudavel min',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InkWell(
                        key: const Key('register_lgpd_checkbox'),
                        borderRadius: AppSpacing.inputRadius,
                        onTap: () {
                          setState(() {
                            _lgpdAccepted = !_lgpdAccepted;
                            if (_lgpdAccepted) {
                              _showLgpdError = false;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxs,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                value: _lgpdAccepted,
                                activeColor: AppColors.primaryBrand,
                                onChanged: (bool? checked) {
                                  setState(() {
                                    _lgpdAccepted = checked ?? false;
                                    if (_lgpdAccepted) {
                                      _showLgpdError = false;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    'Concordo com o tratamento dos meus dados de produtividade conforme a LGPD (RNF07), ciente de que posso excluir minha conta permanentemente a qualquer momento.',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showLgpdError) ...<Widget>[
                        Text(
                          'Confirme o consentimento LGPD para criar sua conta.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.fatigueCritical,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      PrimaryGradientButton(
                        key: const Key('register_submit_button'),
                        label: 'Criar minha conta',
                        icon: Icons.person_add_alt_1_rounded,
                        isLoading: authState.isLoading,
                        onPressed: _submitRegister,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => GoRouter.maybeOf(
                          context,
                        )?.go(AppRoutes.login),
                        child: Text(
                          'Já tenho uma conta • Fazer login',
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
