import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/theme/app_theme.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/habitos/presentation/widgets/habit_form_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/capacidade_dia_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/screens/painel_dia_screen.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/animated_circle_checkbox.dart';

import '../../helpers/fake_painel_repository.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Hábitos, Streaks e Filtro por Pilar (E05-T03 / E05-T04 / RF06 / RF15)', () {
    testWidgets(
      'renderiza badge de Hábito, badge de sequência 🔥 5d e conclui com 1 toque otimista',
      (WidgetTester tester) async {
        final fakeRepo = FakePainelRepository(
          diaBundle: const PainelDiaBundle(
            data: '2026-10-15',
            pilaresAtivosMes: <PilarResumoEntity>[
              PilarResumoEntity(
                idPilar: 2,
                codigo: 'MOVIMENTO',
                nome: 'Movimento',
                corHex: '#F97316',
                corFundoHex: '#FFF7ED',
                icone: 'activity',
              ),
              PilarResumoEntity(
                idPilar: 5,
                codigo: 'ESTUDOS',
                nome: 'Estudos',
                corHex: '#10B981',
                corFundoHex: '#ECFDF5',
                icone: 'book_open',
              ),
              PilarResumoEntity(
                idPilar: 7,
                codigo: 'CARREIRA',
                nome: 'Carreira',
                corHex: '#0EA5E9',
                corFundoHex: '#F0F9FF',
                icone: 'briefcase',
              ),
            ],
            capacidadeDia: CapacidadeDiaEntity(
              horasSonoDiarias: 8,
              minutosUteis: 960,
              limiteFadigaMinutos: 768,
              minutosTarefas: 60,
              minutosHabitos: 45,
              minutosComprometidos: 105,
              percentualOcupacao: 11,
              nivel: NivelFadiga.equilibrado,
              emAlertaFadiga: false,
              novosAgendamentosBloqueados: false,
            ),
            itensLinhaTempo: <TimelineItemEntity>[
              TimelineItemEntity(
                id: 'hab-1',
                natureza: NaturezaItem.habito,
                tipoItem: 'TAREFA',
                horario: '07:00',
                nome: 'Treino de Força / Mobilidade',
                duracaoEstimadaMinutos: 45,
                prioridade: TaskPriority.prioridade,
                indicadorDependencia: 'MINHAS_ACOES',
                concluido: false,
                streakAtual: 5,
                pilar: PilarResumoEntity(
                  idPilar: 2,
                  codigo: 'MOVIMENTO',
                  nome: 'Movimento',
                  corHex: '#F97316',
                  corFundoHex: '#FFF7ED',
                  icone: 'activity',
                ),
              ),
            ],
            itensEmEspera: <TimelineItemEntity>[],
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              painelRepositoryProvider.overrideWithValue(fakeRepo),
              authNotifierProvider.overrideWith(
                () => AuthNotifier(
                  initialState: const AuthState.authenticated(
                    UsuarioEntity(
                      id: 'u-1',
                      nomeCompleto: 'Carolina Calinca',
                      email: 'carolina@fatec.sp.gov.br',
                    ),
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const PainelDiaScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Verifica barra de 3 pilares ativos do mês no topo (Mockup 01)
        expect(find.byKey(const Key('pilar_filter_chip_2')), findsOneWidget); // Movimento
        expect(find.byKey(const Key('pilar_filter_chip_5')), findsOneWidget); // Estudos
        expect(find.byKey(const Key('pilar_filter_chip_7')), findsOneWidget); // Carreira
        expect(find.byKey(const Key('config_pilares_button')), findsOneWidget);

        // 2. Verifica exibição do Hábito na Linha do Tempo
        expect(find.text('Treino de Força / Mobilidade'), findsOneWidget);

        // Badge azul suave "Hábito"
        expect(find.byKey(const Key('badge_habito_hab-1')), findsOneWidget);
        expect(find.text('Hábito'), findsOneWidget);

        // Badge de Sequência "🔥 5d"
        expect(find.byKey(const Key('badge_streak_hab-1')), findsOneWidget);
        expect(find.text('5d'), findsOneWidget);

        // 3. Conclui com 1 toque no checkbox (Optimistic UI)
        final Finder checkboxFinder = find.byType(AnimatedCircleCheckbox);
        expect(checkboxFinder, findsOneWidget);

        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();

        // Streak deve ser incrementado otimisticamente para 6d
        expect(find.text('6d'), findsOneWidget);

        // 4. Testa botão de Novo Hábito no Header
        await tester.tap(find.byKey(const Key('novo_habito_button')));
        await tester.pumpAndSettle();

        expect(find.byType(HabitFormSheet), findsOneWidget);
        expect(find.byKey(const Key('habit_name_field')), findsOneWidget);
        expect(find.byKey(const Key('save_habit_button')), findsOneWidget);
      },
    );
  });
}
