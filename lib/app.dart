import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/config/env_config.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/theme/app_theme.dart';

/// Widget raiz da aplicação configurando `MaterialApp.router`, `AppTheme` e `GoRouter`.
class ProdutividadeTccApp extends ConsumerWidget {
  const ProdutividadeTccApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: EnvConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
