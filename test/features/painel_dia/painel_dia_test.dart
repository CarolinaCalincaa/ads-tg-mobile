import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
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
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/screens/painel_dia_screen.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/animated_circle_checkbox.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/task_form_sheet.dart';

class _FakePainelRepository implements PainelRepository {
  bool toggleTaskCalled = false;
  bool shouldFailToggle = false;
  String? lastToggledId;
  bool? lastToggledConcluido;

  PainelDiaBundle dummyBundle = const PainelDiaBundle(
    data: '2026-10-15',
    pilaresAtivosMes: <PilarResumoEntity>[
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
      minutosTarefas: 120,
      minutosHabitos: 30,
      minutosComprometidos: 150,
      percentualOcupacao: 16,
      nivel: NivelFadiga.equilibrado,
      emAlertaFadiga: false,
      novosAgendamentosBloqueados: false,
    ),
    itensLinhaTempo: <TimelineItemEntity>[
      TimelineItemEntity(
        id: 't-1',
        natureza: NaturezaItem.tarefa,
        tipoItem: 'TAREFA',
        horario: '09:00',
        nome: 'Sprint foco — entrega MVP',
        duracaoEstimadaMinutos: 120,
        prioridade: TaskPriority.prioridade,
        indicadorDependencia: 'MINHAS_ACOES',
        concluido: false,
        pilar: PilarResumoEntity(
          idPilar: 7,
          codigo: 'CARREIRA',
          nome: 'Carreira',
          corHex: '#0EA5E9',
          corFundoHex: '#F0F9FF',
          icone: 'briefcase',
        ),
        checklists: <ChecklistEntity>[
          ChecklistEntity(
            id: 'chk-1',
            titulo: 'Requisitos',
            totalItens: 2,
            itensConcluidos: 1,
            itens: <ItemChecklistEntity>[
              ItemChecklistEntity(
                id: 'it-1',
                idChecklist: 'chk-1',
                descricao: 'Subitem 1',
                concluido: true,
              ),
              ItemChecklistEntity(
                id: 'it-2',
                idChecklist: 'chk-1',
                descricao: 'Subitem 2',
                concluido: false,
              ),
            ],
          ),
        ],
      ),
    ],
    itensEmEspera: <TimelineItemEntity>[],
  );

  @override
  Future<Result<PainelDiaBundle>> getPainelDia(String data) async {
    return Success<PainelDiaBundle>(dummyBundle);
  }

  @override
  Future<Result<PainelSemanaBundle>> getPainelSemana(
    String dataReferencia,
  ) async {
    return Success<PainelSemanaBundle>(
      PainelSemanaBundle(
        dataReferencia: dataReferencia,
        inicioSemana: '2026-10-12',
        fimSemana: '2026-10-18',
        dias: const <DiaSemanaResumoEntity>[],
      ),
    );
  }

  @override
  Future<Result<void>> toggleTaskStatus(String id, bool concluido) async {
    toggleTaskCalled = true;
    lastToggledId = id;
    lastToggledConcluido = concluido;
    if (shouldFailToggle) {
      return const FailureResult<void>(
        NetworkFailure(message: 'Falha de conexão ao sincronizar.'),
      );
    }
    return const Success<void>(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> toggleHabitExecution(
    String id,
    String data,
    bool concluido,
  ) async {
    toggleTaskCalled = true;
    lastToggledId = id;
    lastToggledConcluido = concluido;
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': id,
      'concluido': concluido,
      'streakAtual': concluido ? 5 : 4,
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> createHabit(
    Map<String, dynamic> payload,
  ) async {
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': 'h-new',
      ...payload,
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> updateHabit(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': id,
      ...payload,
    });
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    return const Success<void>(null);
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
  Future<Result<List<Map<String, dynamic>>>> getDiasLivres({
    required String dataOrigem,
    int duracaoMinutos = 60,
  }) async {
    return const Success<List<Map<String, dynamic>>>(<Map<String, dynamic>>[]);
  }

  @override
  Future<Result<List<ProjetoEntity>>> getProjetos({String? status}) async {
    return const Success<List<ProjetoEntity>>(<ProjetoEntity>[]);
  }

  @override
  Future<Result<ProjetoEntity>> createProjeto(
    Map<String, dynamic> payload,
  ) async {
    return const Success<ProjetoEntity>(
      ProjetoEntity(id: 'p-1', nome: 'Proj 1'),
    );
  }

  @override
  Future<Result<List<ChecklistEntity>>> getChecklists({bool? ehModelo}) async {
    return const Success<List<ChecklistEntity>>(<ChecklistEntity>[]);
  }

  @override
  Future<Result<ChecklistEntity>> createChecklist(
    Map<String, dynamic> payload,
  ) async {
    return const Success<ChecklistEntity>(
      ChecklistEntity(id: 'c-1', titulo: 'Chk 1'),
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
  Future<Result<ItemChecklistEntity>> addChecklistItem({
    required String idChecklist,
    required String descricao,
  }) async {
    return Success<ItemChecklistEntity>(
      ItemChecklistEntity(
        id: 'it-new',
        idChecklist: idChecklist,
        descricao: descricao,
        concluido: false,
      ),
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> registrarSessaoPomodoro(
    Map<String, dynamic> payload,
  ) async {
    return const Success<Map<String, dynamic>>(<String, dynamic>{
      'id': 'sessao-1',
      'concluido': true,
    });
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PainelDiaNotifier (Optimistic UI — RNF04 / E03-T03)', () {
    late _FakePainelRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = _FakePainelRepository();
      container = ProviderContainer(
        overrides: [
          painelRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('toggleItemCompletion updates state immediately in 1 click (Optimistic UI)', () async {
      final notifier = container.read(painelDiaNotifierProvider.notifier);
      await notifier.loadDia('2026-10-15');

      final initialItem =
          container.read(painelDiaNotifierProvider).bundle!.itensLinhaTempo.first;
      expect(initialItem.concluido, isFalse);

      // Dispara o toggle
      final Future<void> toggleFuture = notifier.toggleItemCompletion(initialItem);

      // Imediatamente o estado em memória deve ser concluido: true
      final itemOtimista =
          container.read(painelDiaNotifierProvider).bundle!.itensLinhaTempo.first;
      expect(itemOtimista.concluido, isTrue);

      await toggleFuture;
      expect(fakeRepo.toggleTaskCalled, isTrue);
      expect(fakeRepo.lastToggledConcluido, isTrue);
    });

    test('toggleItemCompletion rolls back if remote API fails', () async {
      fakeRepo.shouldFailToggle = true;
      final notifier = container.read(painelDiaNotifierProvider.notifier);
      await notifier.loadDia('2026-10-15');

      final initialItem =
          container.read(painelDiaNotifierProvider).bundle!.itensLinhaTempo.first;
      expect(initialItem.concluido, isFalse);

      await notifier.toggleItemCompletion(initialItem);

      // Reverteu para false e registrou falha
      final reverted =
          container.read(painelDiaNotifierProvider).bundle!.itensLinhaTempo.first;
      expect(reverted.concluido, isFalse);
      expect(container.read(painelDiaNotifierProvider).hasError, isTrue);
    });
  });

  group('AnimatedCircleCheckbox Widget Test (RNF04)', () {
    testWidgets('renders and handles tap with 48dp minimum area', (tester) async {
      bool isChecked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCircleCheckbox(
              isChecked: isChecked,
              color: Colors.blue,
              onChanged: (val) => isChecked = val,
            ),
          ),
        ),
      );

      final finder = find.byType(AnimatedCircleCheckbox);
      expect(finder, findsOneWidget);

      final Size size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(finder);
      await tester.pumpAndSettle();
      expect(isChecked, isTrue);
    });
  });

  group('PainelDiaScreen Widget Tests (E03-T04 / E03-T06)', () {
    testWidgets('renders timeline item card and opens task sheet on FAB tap', (tester) async {
      final fakeRepo = _FakePainelRepository();

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

      // Verifica cabeçalho e saudação
      expect(find.text('Olá, Carolina 👋'), findsOneWidget);
      expect(find.text('Painel do Dia'), findsOneWidget);

      // Verifica item na linha do tempo
      expect(find.text('Sprint foco — entrega MVP'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('☑️ 1/2'), findsOneWidget);

      // Toca no chip de checklist para expandir acordeão inline (RF20)
      await tester.tap(find.text('☑️ 1/2'));
      await tester.pumpAndSettle();
      expect(find.text('Subitem 1'), findsOneWidget);
      expect(find.text('Subitem 2'), findsOneWidget);

      // Toca no FAB para abrir o TaskFormSheet
      await tester.tap(find.byKey(const Key('nova_atividade_fab')));
      await tester.pumpAndSettle();

      expect(find.byType(TaskFormSheet), findsOneWidget);
      expect(find.byKey(const Key('save_task_button')), findsOneWidget);
    });
  });
}
