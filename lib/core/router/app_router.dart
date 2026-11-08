import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/responsive_shell_scaffold.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';

/// Rotas nomeadas canônicas da aplicação.
abstract final class AppRoutes {
  static const String painel = '/painel';
  static const String relatorios = '/relatorios';
  static const String alertas = '/alertas';
  static const String config = '/config';
}

/// Constrói o [GoRouter] com `StatefulShellRoute.indexedStack` para as 4 abas principais.
GoRouter createAppRouter({String initialLocation = AppRoutes.painel}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
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

/// Provider global do [GoRouter].
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  return createAppRouter();
});
