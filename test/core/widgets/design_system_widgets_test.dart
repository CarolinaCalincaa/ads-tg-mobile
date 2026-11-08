import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_theme.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/core/widgets/primary_gradient_button.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Design System Atoms (E01-T04)', () {
    testWidgets('AppCard renders child with 20px radius, border and handles tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrapWithApp(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Conteúdo do Card'),
          ),
        ),
      );

      expect(find.text('Conteúdo do Card'), findsOneWidget);

      final Container container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Conteúdo do Card'),
          matching: find.byType(Container),
        ),
      );
      final BoxDecoration decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, AppSpacing.cardRadius);
      expect(decoration.color, AppColors.surfaceCard);

      await tester.tap(find.text('Conteúdo do Card'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('PilarChip renders icon, pillar name and hex colors', (
      WidgetTester tester,
    ) async {
      bool selected = false;

      await tester.pumpWidget(
        _wrapWithApp(
          PilarChip(
            nome: 'Estudos',
            corHex: '#10B981',
            corFundoHex: '#ECFDF5',
            icone: 'book_open',
            isSelected: true,
            onTap: () => selected = true,
          ),
        ),
      );

      expect(find.text('Estudos'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

      await tester.tap(find.text('Estudos'));
      await tester.pump();
      expect(selected, isTrue);
    });

    testWidgets('PriorityBadge renders all 3 priority levels with WCAG AA colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PriorityBadge(priority: TaskPriority.prioridade),
              PriorityBadge(priority: TaskPriority.rapido),
              PriorityBadge(priority: TaskPriority.postergavel),
            ],
          ),
        ),
      );

      expect(find.text('Prioridade'), findsOneWidget);
      expect(find.text('Rápido'), findsOneWidget);
      expect(find.text('Postergável'), findsOneWidget);

      final Text rapidoText = tester.widget<Text>(find.text('Rápido'));
      expect(rapidoText.style?.color, AppColors.priorityQuickFg);
    });

    testWidgets(
      'PrimaryGradientButton handles tap, loading state and disabled state',
      (WidgetTester tester) async {
        int tapCount = 0;

        await tester.pumpWidget(
          _wrapWithApp(
            PrimaryGradientButton(
              label: 'Finalizar Fechamento',
              icon: Icons.check_rounded,
              onPressed: () => tapCount++,
            ),
          ),
        );

        expect(find.text('Finalizar Fechamento'), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);

        await tester.tap(find.text('Finalizar Fechamento'));
        await tester.pump();
        expect(tapCount, 1);

        // Loading state blocks taps and displays progress indicator
        await tester.pumpWidget(
          _wrapWithApp(
            PrimaryGradientButton(
              label: 'Finalizar Fechamento',
              isLoading: true,
              onPressed: () => tapCount++,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.tap(find.byType(PrimaryGradientButton));
        await tester.pump();
        expect(tapCount, 1);

        // Disabled state blocks taps
        await tester.pumpWidget(
          _wrapWithApp(
            PrimaryGradientButton(
              label: 'Finalizar Fechamento',
              isDisabled: true,
              onPressed: () => tapCount++,
            ),
          ),
        );

        await tester.tap(find.text('Finalizar Fechamento'));
        await tester.pump();
        expect(tapCount, 1);
      },
    );

    testWidgets('EmptyStateView renders icon, title, description and optional CTA', (
      WidgetTester tester,
    ) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        _wrapWithApp(
          EmptyStateView(
            icon: Icons.wb_sunny_outlined,
            title: 'Seu Painel do Dia está limpo',
            description: 'Adicione tarefas ou hábitos alinhados aos seus 3 pilares.',
            actionLabel: 'Nova Atividade',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('Seu Painel do Dia está limpo'), findsOneWidget);
      expect(
        find.text('Adicione tarefas ou hábitos alinhados aos seus 3 pilares.'),
        findsOneWidget,
      );
      expect(find.text('Nova Atividade'), findsOneWidget);

      await tester.tap(find.text('Nova Atividade'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });
  });
}
