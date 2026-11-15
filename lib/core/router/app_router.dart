import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/responsive_shell_scaffold.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
// A tela de Alertas (AlertasScreen) permanece preservada no codebase em features/alertas,
// mas foi desativada do menu principal e substituída pela aba Rotina (RotinaScreen).
// import 'package:produtividade_tcc/features/alertas/presentation/screens/alertas_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/config_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/login_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/register_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/screens/fechamento_history_screen.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/screens/fechamento_screen.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/screens/painel_dia_screen.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/screens/process_templates_screen.dart';
import 'package:produtividade_tcc/features/pilares/presentation/screens/monthly_pillars_screen.dart';
import 'package:produtividade_tcc/features/rotina/presentation/screens/rotina_screen.dart';

/// Rotas nomeadas canônicas da aplicação.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String painel = '/painel';
  static const String relatorios = '/relatorios';
  static const String rotina = '/rotina';
  static const String alertas = '/alertas'; // Mantida por compatibilidade; desativada do menu
  static const String config = '/config';
  static const String modelosProcessos = '/modelos-processos';
  static const String pilaresMensais = '/pilares-mensais';
  static const String fechamento = '/fechamento';
  static const String fechamentoHistorico = '/fechamento/historico';

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
/// (`Painel`, `Relatórios`, `Rotina`, `Config.`) e proteção reativa de rotas via [AuthNotifier].
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
        path: AppRoutes.modelosProcessos,
        builder: (BuildContext context, GoRouterState state) {
          return const ProcessTemplatesScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.pilaresMensais,
        builder: (BuildContext context, GoRouterState state) {
          return const MonthlyPillarsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.fechamento,
        builder: (BuildContext context, GoRouterState state) {
          final String? tipo = state.uri.queryParameters['tipoCiclo'];
          final String? dataRef = state.uri.queryParameters['dataRef'];
          return FechamentoScreen(
            initialTipoCiclo: tipo ?? 'SEMANAL',
            initialDataRef: dataRef,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.fechamentoHistorico,
        builder: (BuildContext context, GoRouterState state) {
          return const FechamentoHistoryScreen();
        },
      ),
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
                  return const PainelDiaScreen();
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
                    appBar: AppBar(
                      title: const Text('Relatórios & Evolução'),
                      actions: <Widget>[
                        IconButton(
                          key: const Key('btn_historico_fechamentos_relatorios'),
                          tooltip: 'Histórico de Fechamentos',
                          icon: const Icon(Icons.history_outlined),
                          onPressed: () {
                            context.push(AppRoutes.fechamentoHistorico);
                          },
                        ),
                      ],
                    ),
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const EmptyStateView(
                              icon: Icons.insights_outlined,
                              title: 'Evolução & Fechamento Reflexivo',
                              description:
                                  'Seus gráficos de consistência, engajamento nos 3 pilares e ritos de reflexão aparecerão aqui.',
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              key: const Key('btn_abrir_fechamento_relatorios'),
                              icon: const Icon(Icons.auto_stories_outlined),
                              label: const Text('Realizar Fechamento Reflexivo'),
                              onPressed: () {
                                context.push(AppRoutes.fechamento);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.rotina,
                builder: (BuildContext context, GoRouterState state) {
                  return const RotinaScreen();
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
                  return const ConfigScreen();
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

/// Adaptador `ChangeNotifier` que notifica o [GoRouter] sempre que o estado de
/// autenticação em [authNotifierProvider] é alterado.
class RouterAuthRefreshNotifier extends ChangeNotifier {
  RouterAuthRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authNotifierProvider,
      (AuthState? previous, AuthState next) {
        if (previous?.status != next.status ||
            previous?.isAuthenticated != next.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
