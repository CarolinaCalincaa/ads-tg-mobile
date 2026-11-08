import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Metadados de cada destino de navegação principal (4 abas canônicas do TCC).
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Shell adaptativo das 4 abas (`Painel`, `Relatórios`, `Alertas`, `Config.`) (`RNF03` e `Tech Doc 05 — Seção 2.6`).
///
/// - Telas `< 768px` (Mobile): `NavigationBar` inferior.
/// - Telas `>= 768px` (Tablet/Desktop Web SPA): `NavigationRail` lateral esquerda.
class ResponsiveShellScaffold extends StatelessWidget {
  const ResponsiveShellScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const List<ShellDestination> destinations = <ShellDestination>[
    ShellDestination(
      label: 'Painel',
      icon: Icons.wb_sunny_outlined,
      selectedIcon: Icons.wb_sunny_rounded,
    ),
    ShellDestination(
      label: 'Relatórios',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
    ),
    ShellDestination(
      label: 'Alertas',
      icon: Icons.notifications_none_rounded,
      selectedIcon: Icons.notifications_rounded,
    ),
    ShellDestination(
      label: 'Config.',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWideScreen =
            constraints.maxWidth >= AppSpacing.tabletBreakpoint;
        final bool isDesktopExpanded =
            constraints.maxWidth >= AppSpacing.desktopBreakpoint;

        if (!isWideScreen) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
                destinations: destinations
                    .map(
                      (ShellDestination item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: <Widget>[
              NavigationRail(
                extended: isDesktopExpanded,
                labelType: isDesktopExpanded
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: AppColors.surfaceCard,
                          size: 20,
                        ),
                      ),
                      if (isDesktopExpanded) ...<Widget>[
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Calma Cognitiva',
                          style: AppTypography.cardTitle,
                        ),
                      ],
                    ],
                  ),
                ),
                destinations: destinations
                    .map(
                      (ShellDestination item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(growable: false),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}
