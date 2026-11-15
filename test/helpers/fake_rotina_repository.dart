import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/rotina/domain/entities/rotina_entities.dart';
import 'package:produtividade_tcc/features/rotina/domain/repositories/rotina_repository.dart';

class FakeRotinaRepository implements RotinaRepository {
  FakeRotinaRepository({
    List<RotinaTarefaEntity>? tarefasIniciais,
    List<RotinaHabitoEntity>? habitosIniciais,
  })  : tarefas = tarefasIniciais ?? _defaultTarefas,
        habitos = habitosIniciais ?? _defaultHabitos;

  List<RotinaTarefaEntity> tarefas;
  List<RotinaHabitoEntity> habitos;

  static const List<RotinaTarefaEntity> _defaultTarefas = <RotinaTarefaEntity>[
    RotinaTarefaEntity(
      id: 't1',
      tipoItem: 'TAREFA',
      nome: 'Redigir Capítulo de Resultados',
      descricao: 'Consolidar dados do experimento',
      duracaoEstimadaMinutos: 60,
      prioridade: TaskPriority.prioridade,
      indicadorDependencia: 'MINHAS_ACOES',
      dataAgendamento: '2026-11-15',
      horarioInicio: '09:00',
      status: 'PENDENTE',
      concluido: false,
      pilar: PilarResumoEntity(
        idPilar: 5,
        codigo: 'ESTUDOS',
        nome: 'Estudos',
        corHex: '#10B981',
        corFundoHex: '#ECFDF5',
        icone: 'book_open',
      ),
    ),
    RotinaTarefaEntity(
      id: 't2',
      tipoItem: 'TAREFA',
      nome: 'Aguardando Parecer da Banca',
      duracaoEstimadaMinutos: 15,
      prioridade: TaskPriority.postergavel,
      indicadorDependencia: 'EM_ESPERA',
      dataAgendamento: '2026-11-15',
      status: 'PENDENTE',
      concluido: false,
      pilar: PilarResumoEntity(
        idPilar: 7,
        codigo: 'CARREIRA',
        nome: 'Carreira',
        corHex: '#0EA5E9',
        corFundoHex: '#F0F9FF',
        icone: 'briefcase',
      ),
    ),
  ];

  static const List<RotinaHabitoEntity> _defaultHabitos = <RotinaHabitoEntity>[
    RotinaHabitoEntity(
      id: 'h1',
      nome: 'Beber 2.5L de Água',
      descricao: 'Hidratação constante',
      duracaoEstimadaMinutos: 5,
      frequenciaSemanal: 7,
      diasSemana: <int>[1, 2, 3, 4, 5, 6, 7],
      horarioPadrao: '08:00',
      statusAtivo: true,
      streakAtual: 9,
      pilar: PilarResumoEntity(
        idPilar: 1,
        codigo: 'SAUDE',
        nome: 'Saúde',
        corHex: '#22C55E',
        corFundoHex: '#F0FDF4',
        icone: 'heart_pulse',
      ),
    ),
  ];

  @override
  Future<Result<List<RotinaTarefaEntity>>> getAllTarefas() async {
    return Success<List<RotinaTarefaEntity>>(
      List<RotinaTarefaEntity>.from(tarefas),
    );
  }

  @override
  Future<Result<List<RotinaHabitoEntity>>> getAllHabitos() async {
    return Success<List<RotinaHabitoEntity>>(
      List<RotinaHabitoEntity>.from(habitos),
    );
  }

  @override
  Future<Result<void>> toggleTarefaStatus(String id, bool concluido) async {
    tarefas = tarefas.map((t) {
      if (t.id == id) {
        return t.copyWith(
          concluido: concluido,
          status: concluido ? 'CONCLUIDA' : 'PENDENTE',
        );
      }
      return t;
    }).toList();
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> deleteTarefa(String id) async {
    tarefas = tarefas.where((t) => t.id != id).toList();
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> toggleHabitoAtivo(String id, bool statusAtivo) async {
    habitos = habitos.map((h) {
      if (h.id == id) {
        return h.copyWith(statusAtivo: statusAtivo);
      }
      return h;
    }).toList();
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> deleteHabito(String id) async {
    habitos = habitos.where((h) => h.id != id).toList();
    return const Success<void>(null);
  }
}
