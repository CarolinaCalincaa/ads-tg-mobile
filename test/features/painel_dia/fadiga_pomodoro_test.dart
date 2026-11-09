import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/theme/app_theme.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/capacidade_dia_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_semana_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/repositories/painel_repository.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/pomodoro_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/screens/painel_dia_screen.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/active_pomodoro_mini_bar.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/compact_capacity_bar.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/fadiga_alert_banner.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/fatigue_blocked_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/pomodoro_player_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/smart_schedule_fab.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/task_form_sheet.dart';

class _FakePainelRepositoryMock implements PainelRepository {
  _FakePainelRepositoryMock({
    required this.bundle,
    List<Map<String, dynamic>>? diasLivres,
  }) : diasLivres = diasLivres ??
            <Map<String, dynamic>>[
              <String, dynamic>{
                'data': '2026-10-16',
                'percentualOcupacao': 25,
              },
              <String, dynamic>{
                'data': '2026-10-17',
                'percentualOcupacao': 40,
              },
              <String, dynamic>{
                'data': '2026-10-18',
                'percentualOcupacao': 50,
              },
            ];

  PainelDiaBundle bundle;
  final List<Map<String, dynamic>> diasLivres;
  final List<Map<String, dynamic>> sessoesPomodoro = <Map<String, dynamic>>[];

  @override
  Future<Result<PainelDiaBundle>> getPainelDia(String data) async {
    return Success<PainelDiaBundle>(bundle);
  }

  @override
  Future<Result<PainelSemanaBundle>> getPainelSemana(String dataReferencia) async {
    return Success<PainelSemanaBundle>(
      PainelSemanaBundle(
        dataReferencia: dataReferencia,
        inicioSemana: dataReferencia,
        fimSemana: dataReferencia,
        dias: const <DiaSemanaResumoEntity>[],
      ),
    );
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getDiasLivres({
    required String dataOrigem,
    int duracaoMinutos = 60,
  }) async {
    return Success<List<Map<String, dynamic>>>(diasLivres);
  }

  @override
  Future<Result<Map<String, dynamic>>> registrarSessaoPomodoro(
    Map<String, dynamic> payload,
  ) async {
    sessoesPomodoro.add(payload);
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': 'sessao-${sessoesPomodoro.length}',
      ...payload,
    });
  }

  @override
  Future<Result<void>> toggleTaskStatus(String id, bool concluido) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> createTask(
    Map<String, dynamic> payload,
  ) async {
    return const Success<Map<String, dynamic>>(<String, dynamic>{'id': 't-new'});
  }

  @override
  Future<Result<Map<String, dynamic>>> updateTask(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return Success<Map<String, dynamic>>(<String, dynamic>{'id': id});
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<List<ProjetoEntity>>> getProjetos({String? status}) async {
    return const Success<List<ProjetoEntity>>(<ProjetoEntity>[]);
  }

  @override
  Future<Result<ProjetoEntity>> createProjeto(Map<String, dynamic> payload) async {
    return const Success<ProjetoEntity>(
      ProjetoEntity(id: 'p-1', nome: 'Projeto'),
    );
  }

  @override
  Future<Result<List<ChecklistEntity>>> getChecklists({bool? ehModelo}) async {
    return const Success<List<ChecklistEntity>>(<ChecklistEntity>[]);
  }

  @override
  Future<Result<ChecklistEntity>> createChecklist(Map<String, dynamic> payload) async {
    return const Success<ChecklistEntity>(
      ChecklistEntity(id: 'c-1', titulo: 'Checklist'),
    );
  }

  @override
  Future<Result<ChecklistEntity>> cloneChecklist({
    required String idModelo,
    String? idTarefa,
    String? idHabito,
  }) async {
    return const Success<ChecklistEntity>(
      ChecklistEntity(id: 'c-clone', titulo: 'Clone'),
    );
  }

  @override
  Future<Result<void>> toggleChecklistItem({
    required String idChecklist,
    required String itemId,
    required bool concluido,
  }) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<ItemChecklistEntity>> addChecklistItem({
    required String idChecklist,
    required String descricao,
  }) async {
    return Success<ItemChecklistEntity>(
      ItemChecklistEntity(
        id: 'it-1',
        idChecklist: idChecklist,
        descricao: descricao,
        concluido: false,
      ),
    );
  }
}

TimelineItemEntity _criarTarefaExemplo({
  String id = 't-1',
  String nome = 'Implementar RN02 e Pomodoro',
  int pomodorosConcluidos = 0,
}) {
  return TimelineItemEntity(
    id: id,
    natureza: NaturezaItem.tarefa,
    tipoItem: 'TAREFA',
    horario: '10:00',
    nome: nome,
    duracaoEstimadaMinutos: 90,
    prioridade: TaskPriority.prioridade,
    indicadorDependencia: 'MINHAS_ACOES',
    concluido: false,
    pomodorosConcluidos: pomodorosConcluidos,
    pilar: const PilarResumoEntity(
      idPilar: 7,
      codigo: 'CARREIRA',
      nome: 'Carreira',
      corHex: '#0EA5E9',
      corFundoHex: '#F0F9FF',
      icone: 'briefcase',
    ),
    checklists: const <ChecklistEntity>[],
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Fadiga Mental RN02 (Mockup 01 / E04-T02 / E04-T03)', () {
    testWidgets(
      'exibe FadigaAlertBanner (82%) e SmartScheduleFab bloqueado ao ultrapassar 80% das horas úteis',
      (tester) async {
        final bundleFadiga = PainelDiaBundle(
          data: '2026-10-15',
          pilaresAtivosMes: const <PilarResumoEntity>[
            PilarResumoEntity(
              idPilar: 7,
              codigo: 'CARREIRA',
              nome: 'Carreira',
              corHex: '#0EA5E9',
              corFundoHex: '#F0F9FF',
              icone: 'briefcase',
            ),
          ],
          capacidadeDia: const CapacidadeDiaEntity(
            horasSonoDiarias: 8,
            minutosUteis: 960,
            limiteFadigaMinutos: 768,
            minutosTarefas: 787,
            minutosHabitos: 0,
            minutosComprometidos: 787,
            percentualOcupacao: 82, // Mockup 01 canônico
            nivel: NivelFadiga.riscoFadiga,
            emAlertaFadiga: true,
            novosAgendamentosBloqueados: true,
          ),
          itensLinhaTempo: <TimelineItemEntity>[
            _criarTarefaExemplo(),
          ],
          itensEmEspera: const <TimelineItemEntity>[],
        );

        final repo = _FakePainelRepositoryMock(bundle: bundleFadiga);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              painelRepositoryProvider.overrideWithValue(repo),
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

        // 1. Valida FadigaAlertBanner
        expect(find.byType(FadigaAlertBanner), findsOneWidget);
        expect(find.text('Risco de Fadiga Mental'), findsOneWidget);
        expect(find.text('82%'), findsOneWidget);
        expect(
          find.text(
            '82% das horas úteis comprometidas. Novos agendamentos bloqueados.',
          ),
          findsOneWidget,
        );
        expect(find.text('Remanejar atividades ->'), findsOneWidget);

        // Não deve exibir a CompactCapacityBar quando em alerta
        expect(find.byType(CompactCapacityBar), findsNothing);

        // 2. Valida SmartScheduleFab Bloqueado
        expect(find.byType(SmartScheduleFab), findsOneWidget);
        expect(
          find.byKey(const Key('nova_atividade_fab_bloqueado')),
          findsOneWidget,
        );
        expect(find.text('Bloqueado (Fadiga)'), findsOneWidget);
        expect(find.byKey(const Key('nova_atividade_fab')), findsNothing);

        // 3. Toca no FAB bloqueado e valida abertura do FatigueBlockedSheet
        await tester.tap(find.byKey(const Key('nova_atividade_fab_bloqueado')));
        await tester.pumpAndSettle();

        expect(find.byType(FatigueBlockedSheet), findsOneWidget);
        expect(
          find.text('Limite de horas atingido, reagende a atividade.'),
          findsOneWidget,
        );
        expect(find.text('Sugestões de Dias Livres'), findsOneWidget);

        // Valida chips dos 3 dias livres sugeridos
        expect(find.byKey(const Key('chip_dia_livre_2026-10-16')), findsOneWidget);
        expect(find.byKey(const Key('chip_dia_livre_2026-10-17')), findsOneWidget);
        expect(find.byKey(const Key('chip_dia_livre_2026-10-18')), findsOneWidget);

        // Valida botões secundário e terciário de alívio cognitivo
        expect(find.byKey(const Key('registrar_em_espera_btn')), findsOneWidget);
        expect(find.byKey(const Key('desafogar_hoje_btn')), findsOneWidget);

        // Toca em um chip de dia livre e verifica abertura do TaskFormSheet pré-configurado
        await tester.tap(find.byKey(const Key('chip_dia_livre_2026-10-16')));
        await tester.pumpAndSettle();

        expect(find.byType(TaskFormSheet), findsOneWidget);
        expect(find.text('Data agendada: 2026-10-16'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe CompactCapacityBar quando ocupação <= 80% e FAB normal liberado',
      (tester) async {
        final bundleNormal = PainelDiaBundle(
          data: '2026-10-15',
          pilaresAtivosMes: const <PilarResumoEntity>[],
          capacidadeDia: const CapacidadeDiaEntity(
            horasSonoDiarias: 8,
            minutosUteis: 960,
            limiteFadigaMinutos: 768,
            minutosTarefas: 150,
            minutosHabitos: 0,
            minutosComprometidos: 150,
            percentualOcupacao: 16,
            nivel: NivelFadiga.equilibrado,
            emAlertaFadiga: false,
            novosAgendamentosBloqueados: false,
          ),
          itensLinhaTempo: <TimelineItemEntity>[
            _criarTarefaExemplo(),
          ],
          itensEmEspera: const <TimelineItemEntity>[],
        );

        final repo = _FakePainelRepositoryMock(bundle: bundleNormal);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              painelRepositoryProvider.overrideWithValue(repo),
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

        expect(find.byType(CompactCapacityBar), findsOneWidget);
        expect(find.text('Capacidade do Dia'), findsOneWidget);
        expect(find.text('16%'), findsOneWidget);
        expect(find.byType(FadigaAlertBanner), findsNothing);

        // FAB normal liberado
        expect(find.byKey(const Key('nova_atividade_fab')), findsOneWidget);
        expect(find.text('Nova Atividade'), findsOneWidget);
      },
    );
  });

  group('Temporizador Pomodoro (E04-T04 / E04-T05 / RF16)', () {
    test('PomodoroNotifier opera ciclo drift-safe e registra sessao ao concluir', () async {
      final fakeRepo = _FakePainelRepositoryMock(
        bundle: const PainelDiaBundle.vazio('2026-10-15'),
      );
      final container = ProviderContainer(
        overrides: [
          painelRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(pomodoroNotifierProvider.notifier);
      final tarefa = _criarTarefaExemplo(id: 'tarefa-pomodoro-1');

      // 1. Iniciar Pomodoro
      notifier.start(tarefa, duracaoMinutos: 25);
      final state1 = container.read(pomodoroNotifierProvider);
      expect(state1.isRunning, isTrue);
      expect(state1.idTarefa, equals('tarefa-pomodoro-1'));
      expect(state1.segundosRestantes, equals(1500));
      expect(state1.startedAtUtc, isNotNull);

      // 2. Pausar Pomodoro
      notifier.pause();
      final state2 = container.read(pomodoroNotifierProvider);
      expect(state2.isPaused, isTrue);
      expect(state2.startedAtUtc, isNull);

      // 3. Retomar Pomodoro
      notifier.resume();
      final state3 = container.read(pomodoroNotifierProvider);
      expect(state3.isRunning, isTrue);
      expect(state3.startedAtUtc, isNotNull);

      // 4. Concluir Sessão antecipada
      await notifier.completeEarly();
      final state4 = container.read(pomodoroNotifierProvider);
      expect(state4.isCompleted, isTrue);
      expect(state4.segundosRestantes, equals(0));

      // Verifica chamada ao repository
      expect(fakeRepo.sessoesPomodoro.length, equals(1));
      expect(
        fakeRepo.sessoesPomodoro.first['idTarefa'],
        equals('tarefa-pomodoro-1'),
      );
      expect(fakeRepo.sessoesPomodoro.first['concluido'], isTrue);
    });

    testWidgets(
      'inicia Pomodoro pelo botão ▶, minimiza para ActivePomodoroMiniBar e conclui ciclo',
      (tester) async {
        final itemTarefa = _criarTarefaExemplo(id: 't-pom-widget');
        final bundle = PainelDiaBundle(
          data: '2026-10-15',
          pilaresAtivosMes: const <PilarResumoEntity>[],
          capacidadeDia: const CapacidadeDiaEntity.padrao(),
          itensLinhaTempo: <TimelineItemEntity>[itemTarefa],
          itensEmEspera: const <TimelineItemEntity>[],
        );

        final repo = _FakePainelRepositoryMock(bundle: bundle);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              painelRepositoryProvider.overrideWithValue(repo),
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

        // 1. Toca no botão ▶ para abrir o PomodoroPlayerSheet
        final playBtn = find.byKey(const Key('iniciar_pomodoro_t-pom-widget'));
        expect(playBtn, findsOneWidget);

        await tester.tap(playBtn);
        await tester.pumpAndSettle();

        // 2. Valida player sheet aberto com contador 25:00 e título
        expect(find.byType(PomodoroPlayerSheet), findsOneWidget);
        expect(find.byKey(const Key('pomodoro_countdown_text')), findsOneWidget);
        final countdownWidget = tester.widget<Text>(
          find.byKey(const Key('pomodoro_countdown_text')),
        );
        expect(countdownWidget.data, equals('25:00'));
        expect(find.text('Implementar RN02 e Pomodoro'), findsWidgets);

        // 3. Minimiza o player sheet
        await tester.tap(find.byKey(const Key('minimizar_pomodoro_btn')));
        await tester.pumpAndSettle();

        // 4. Valida exibição da ActivePomodoroMiniBar flutuante
        expect(find.byType(ActivePomodoroMiniBar), findsOneWidget);
        expect(find.byKey(const Key('mini_bar_countdown_text')), findsOneWidget);
        final miniBarCountdown = tester.widget<Text>(
          find.byKey(const Key('mini_bar_countdown_text')),
        );
        expect(miniBarCountdown.data, equals('25:00'));
        expect(find.byKey(const Key('mini_bar_play_pause_btn')), findsOneWidget);

        // 5. Reabre o player tocando na ActivePomodoroMiniBar
        await tester.tap(find.byType(ActivePomodoroMiniBar));
        await tester.pumpAndSettle();

        expect(find.byType(PomodoroPlayerSheet), findsOneWidget);

        // 6. Conclui o ciclo antecipadamente
        await tester.tap(find.byKey(const Key('pomodoro_complete_early_btn')));
        await tester.pumpAndSettle();

        expect(find.text('Parabéns! 25 minutos concluídos.'), findsOneWidget);
        expect(repo.sessoesPomodoro.length, equals(1));
      },
    );
  });
}
