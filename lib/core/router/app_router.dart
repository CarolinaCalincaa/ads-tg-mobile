import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/responsive_shell_scaffold.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/login_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/register_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/reset_password_screen.dart';

/// Rotas nomeadas canônicas da aplicação.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String painel = '/painel';
  static const String relatorios = '/relatorios';
  static const String alertas = '/alertas';
  static const String config = '/config';

  static const Set<String> publicAuthRoutes = <String>{
    login,
    register,
    forgotPassword,
    resetPassword,
  };
}

/// Avalia a regra de redirecionamento de autenticação (`Auth Guard — E02-T03`).
///
/// - Usuários não autenticados são redirecionados para `/login` (exceto quando já estão em
///   `/login`, `/register`, `/forgot-password` ou `/reset-password`).
/// - Usuários autenticados que tentem acessar `/login` ou `/register` são redirecionados para `/painel`.
String? evaluateAuthRedirect({
  required AuthState authState,
  required String matchedLocation,
}) {
  if (authState.status == AuthStatus.initial) {
    return null;
  }

  final bool isAuthenticated = authState.isAuthenticated;
  final bool isPublicRoute = AppRoutes.publicAuthRoutes.contains(
    matchedLocation,
  );

  if (!isAuthenticated && !isPublicRoute) {
    return AppRoutes.login;
  }

  if (isAuthenticated &&
      (matchedLocation == AppRoutes.login ||
          matchedLocation == AppRoutes.register)) {
    return AppRoutes.painel;
  }

  return null;
}

/// Constrói o [GoRouter] com `StatefulShellRoute.indexedStack` para as 4 abas principais
/// e proteção reativa de rotas via [AuthNotifier].
GoRouter createAppRouter({
  String initialLocation = AppRoutes.painel,
  Listenable? refreshListenable,
  AuthState Function()? readAuthState,
  WidgetBuilder? configBuilder,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      if (readAuthState == null) {
        return null;
      }
      return evaluateAuthRedirect(
        authState: readAuthState(),
        matchedLocation: state.matchedLocation,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (BuildContext context, GoRouterState state) {
          final String? email = state.uri.queryParameters['email'];
          return ResetPasswordScreen(initialEmail: email);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return ResponsiveShellScaffold(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.painel,
                builder: (BuildContext context, GoRouterState state) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Painel do Dia')),
                    body: const EmptyStateView(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Seu Painel do Dia está pronto',
                      description:
                          'A Linha do Tempo unificada de tarefas, compromissos e hábitos será conectada nos próximos épicos.',
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.relatorios,
                builder: (BuildContext context, GoRouterState state) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Relatórios & Evolução')),
                    body: const EmptyStateView(
                      icon: Icons.insights_outlined,
                      title: 'Evolução & Fechamento Reflexivo',
                      description:
                          'Seus gráficos de consistência, engajamento nos 3 pilares e ritos de reflexão aparecerão aqui.',
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.alertas,
                builder: (BuildContext context, GoRouterState state) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Alertas Saudáveis')),
                    body: const EmptyStateView(
                      icon: Icons.notifications_none_rounded,
                      title: 'Lembretes de Saúde Cognitiva',
                      description:
                          'Configure lembretes periódicos de água, pausa ativa, sono e fechamento semanal.',
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.config,
                builder: (BuildContext context, GoRouterState state) {
                  if (configBuilder != null) {
                    return configBuilder(context);
                  }
                  return Scaffold(
                    appBar: AppBar(title: const Text('Configurações')),
                    body: const EmptyStateView(
                      icon: Icons.settings_outlined,
                      title: 'Preferências, Modelos & LGPD',
                      description:
                          'Ajuste suas horas diárias de sono (RN02), gerencie modelos de processos e controle seus dados.',
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Provider global do [GoRouter] integrado ao guard de autenticação ([authNotifierProvider]).
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final RouterAuthRefreshNotifier refreshNotifier = RouterAuthRefreshNotifier(
    ref,
  );
  ref.onDispose(refreshNotifier.dispose);

  final GoRouter router = createAppRouter(
    refreshListenable: refreshNotifier,
    readAuthState: () => ref.read(authNotifierProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});
