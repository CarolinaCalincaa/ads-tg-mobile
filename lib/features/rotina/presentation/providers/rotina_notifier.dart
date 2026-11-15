import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/rotina/data/repositories/rotina_repository_impl.dart';
import 'package:produtividade_tcc/features/rotina/domain/entities/rotina_entities.dart';
import 'package:produtividade_tcc/features/rotina/domain/repositories/rotina_repository.dart';

enum RotinaSegmento {
  tarefas,
  habitos,
  emEspera,
}

enum RotinaFiltroStatusTarefa {
  todas,
  pendentes,
  concluidas,
}

class RotinaState extends Equatable {
  const RotinaState({
    this.isLoading = false,
    this.tarefas = const <RotinaTarefaEntity>[],
    this.habitos = const <RotinaHabitoEntity>[],
    this.segmento = RotinaSegmento.tarefas,
    this.filtroStatusTarefa = RotinaFiltroStatusTarefa.todas,
    this.filtroPilarId,
    this.busca = '',
    this.apenasHabitosAtivos = false,
    this.failure,
  });

  final bool isLoading;
  final List<RotinaTarefaEntity> tarefas;
  final List<RotinaHabitoEntity> habitos;
  final RotinaSegmento segmento;
  final RotinaFiltroStatusTarefa filtroStatusTarefa;
  final int? filtroPilarId;
  final String busca;
  final bool apenasHabitosAtivos;
  final AppFailure? failure;

  /// Tarefas de ação direta (`MINHAS_ACOES`).
  List<RotinaTarefaEntity> get minhasAcoes => tarefas
      .where((t) => !t.ehEmEspera && t.status.toUpperCase() != 'CANCELADA')
      .toList();

  /// Tarefas em espera (`EM_ESPERA`).
  List<RotinaTarefaEntity> get tarefasEmEspera => tarefas
      .where((t) => t.ehEmEspera && t.status.toUpperCase() != 'CANCELADA')
      .toList();

  /// Total de tarefas pendentes em Minhas Ações.
  int get totalPendentes =>
      minhasAcoes.where((t) => !t.concluido).length;

  /// Total de tarefas concluídas.
  int get totalConcluidas =>
      tarefas.where((t) => t.concluido).length;

  /// Total de hábitos ativos.
  int get totalHabitosAtivos =>
      habitos.where((h) => h.statusAtivo).length;

  /// Maior sequência (streak) dentre os hábitos cadastrados.
  int get maiorStreakHabitos => habitos.isEmpty
      ? 0
      : habitos.map((h) => h.streakAtual).reduce((a, b) => a > b ? a : b);

  /// Lista de tarefas filtradas para o segmento `tarefas` ou `emEspera`.
  List<RotinaTarefaEntity> get tarefasFiltradas {
    final List<RotinaTarefaEntity> base =
        segmento == RotinaSegmento.emEspera ? tarefasEmEspera : minhasAcoes;

    final String q = busca.trim().toLowerCase();

    final List<RotinaTarefaEntity> result = base.where((t) {
      if (filtroPilarId != null && t.pilar.idPilar != filtroPilarId) {
        return false;
      }
      if (segmento == RotinaSegmento.tarefas) {
        if (filtroStatusTarefa == RotinaFiltroStatusTarefa.pendentes &&
            t.concluido) {
          return false;
        }
        if (filtroStatusTarefa == RotinaFiltroStatusTarefa.concluidas &&
            !t.concluido) {
          return false;
        }
      }
      if (q.isNotEmpty) {
        final bool matchNome = t.nome.toLowerCase().contains(q);
        final bool matchDesc =
            (t.descricao ?? '').toLowerCase().contains(q);
        final bool matchProj =
            (t.projeto?.nome ?? '').toLowerCase().contains(q);
        final bool matchPilar =
            t.pilar.nome.toLowerCase().contains(q);
        if (!matchNome && !matchDesc && !matchProj && !matchPilar) {
          return false;
        }
      }
      return true;
    }).toList();

    // Ordena: pendentes primeiro, depois por data mais próxima e prioridade
    result.sort((a, b) {
      if (a.concluido != b.concluido) {
        return a.concluido ? 1 : -1;
      }
      final int cmpData = a.dataAgendamento.compareTo(b.dataAgendamento);
      if (cmpData != 0) return cmpData;
      return (a.horarioInicio ?? '23:59')
          .compareTo(b.horarioInicio ?? '23:59');
    });

    return result;
  }

  /// Lista de hábitos filtrados para o segmento `habitos`.
  List<RotinaHabitoEntity> get habitosFiltrados {
    final String q = busca.trim().toLowerCase();

    final List<RotinaHabitoEntity> result = habitos.where((h) {
      if (apenasHabitosAtivos && !h.statusAtivo) {
        return false;
      }
      if (filtroPilarId != null && h.pilar.idPilar != filtroPilarId) {
        return false;
      }
      if (q.isNotEmpty) {
        final bool matchNome = h.nome.toLowerCase().contains(q);
        final bool matchDesc =
            (h.descricao ?? '').toLowerCase().contains(q);
        final bool matchPilar =
            h.pilar.nome.toLowerCase().contains(q);
        if (!matchNome && !matchDesc && !matchPilar) {
          return false;
        }
      }
      return true;
    }).toList();

    result.sort((a, b) {
      if (a.statusAtivo != b.statusAtivo) {
        return a.statusAtivo ? -1 : 1;
      }
      return (a.horarioPadrao ?? '23:59')
          .compareTo(b.horarioPadrao ?? '23:59');
    });

    return result;
  }

  RotinaState copyWith({
    bool? isLoading,
    List<RotinaTarefaEntity>? tarefas,
    List<RotinaHabitoEntity>? habitos,
    RotinaSegmento? segmento,
    RotinaFiltroStatusTarefa? filtroStatusTarefa,
    int? filtroPilarId,
    bool clearFiltroPilar = false,
    String? busca,
    bool? apenasHabitosAtivos,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return RotinaState(
      isLoading: isLoading ?? this.isLoading,
      tarefas: tarefas ?? this.tarefas,
      habitos: habitos ?? this.habitos,
      segmento: segmento ?? this.segmento,
      filtroStatusTarefa: filtroStatusTarefa ?? this.filtroStatusTarefa,
      filtroPilarId:
          clearFiltroPilar ? null : (filtroPilarId ?? this.filtroPilarId),
      busca: busca ?? this.busca,
      apenasHabitosAtivos: apenasHabitosAtivos ?? this.apenasHabitosAtivos,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoading,
        tarefas,
        habitos,
        segmento,
        filtroStatusTarefa,
        filtroPilarId,
        busca,
        apenasHabitosAtivos,
        failure,
      ];
}

class RotinaNotifier extends Notifier<RotinaState> {
  RotinaRepository get _repository => ref.read(rotinaRepositoryProvider);
  bool _disposed = false;

  @override
  RotinaState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });

    Future<void>.microtask(() {
      if (!_disposed) {
        carregarTudo();
      }
    });

    return const RotinaState(isLoading: true);
  }

  Future<void> carregarTudo() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, clearFailure: true);

    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      _repository.getAllTarefas(),
      _repository.getAllHabitos(),
    ]);

    if (_disposed) return;

    final Result<List<RotinaTarefaEntity>> resTarefas =
        results[0] as Result<List<RotinaTarefaEntity>>;
    final Result<List<RotinaHabitoEntity>> resHabitos =
        results[1] as Result<List<RotinaHabitoEntity>>;

    List<RotinaTarefaEntity> tarefas = state.tarefas;
    List<RotinaHabitoEntity> habitos = state.habitos;
    AppFailure? erro;

    resTarefas.fold(
      onFailure: (f) => erro = f,
      onSuccess: (data) => tarefas = data,
    );

    resHabitos.fold(
      onFailure: (f) => erro ??= f,
      onSuccess: (data) => habitos = data,
    );

    state = state.copyWith(
      isLoading: false,
      tarefas: tarefas,
      habitos: habitos,
      failure: erro,
    );
  }

  void selecionarSegmento(RotinaSegmento novoSegmento) {
    state = state.copyWith(segmento: novoSegmento);
  }

  void selecionarFiltroStatusTarefa(RotinaFiltroStatusTarefa status) {
    state = state.copyWith(filtroStatusTarefa: status);
  }

  void selecionarFiltroPilar(int? idPilar) {
    if (idPilar == null || state.filtroPilarId == idPilar) {
      state = state.copyWith(clearFiltroPilar: true);
    } else {
      state = state.copyWith(filtroPilarId: idPilar);
    }
  }

  void atualizarBusca(String termo) {
    state = state.copyWith(busca: termo);
  }

  void alternarApenasHabitosAtivos(bool valor) {
    state = state.copyWith(apenasHabitosAtivos: valor);
  }

  /// Alterna conclusão da tarefa com Optimistic UI (RNF04).
  Future<void> toggleTarefaStatus(String id) async {
    final int idx = state.tarefas.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final RotinaTarefaEntity original = state.tarefas[idx];
    final bool novoStatus = !original.concluido;

    final List<RotinaTarefaEntity> otimista =
        List<RotinaTarefaEntity>.from(state.tarefas);
    otimista[idx] = original.copyWith(
      concluido: novoStatus,
      status: novoStatus ? 'CONCLUIDA' : 'PENDENTE',
    );
    state = state.copyWith(tarefas: otimista, clearFailure: true);

    final Result<void> result =
        await _repository.toggleTarefaStatus(id, novoStatus);
    if (_disposed) return;

    result.fold(
      onFailure: (failure) {
        final List<RotinaTarefaEntity> revertida =
            List<RotinaTarefaEntity>.from(state.tarefas);
        final int revIdx = revertida.indexWhere((t) => t.id == id);
        if (revIdx != -1) {
          revertida[revIdx] = original;
        }
        state = state.copyWith(tarefas: revertida, failure: failure);
      },
      onSuccess: (_) {},
    );
  }

  /// Exclui tarefa com Optimistic UI.
  Future<bool> excluirTarefa(String id) async {
    final List<RotinaTarefaEntity> backup = state.tarefas;
    state = state.copyWith(
      tarefas: state.tarefas.where((t) => t.id != id).toList(),
      clearFailure: true,
    );

    final Result<void> result = await _repository.deleteTarefa(id);
    if (_disposed) return false;

    return result.fold(
      onFailure: (failure) {
        state = state.copyWith(tarefas: backup, failure: failure);
        return false;
      },
      onSuccess: (_) => true,
    );
  }

  /// Alterna status ativo de um hábito com Optimistic UI.
  Future<void> toggleHabitoAtivo(String id, bool ativo) async {
    final int idx = state.habitos.indexWhere((h) => h.id == id);
    if (idx == -1) return;

    final RotinaHabitoEntity original = state.habitos[idx];
    final List<RotinaHabitoEntity> otimista =
        List<RotinaHabitoEntity>.from(state.habitos);
    otimista[idx] = original.copyWith(statusAtivo: ativo);
    state = state.copyWith(habitos: otimista, clearFailure: true);

    final Result<void> result =
        await _repository.toggleHabitoAtivo(id, ativo);
    if (_disposed) return;

    result.fold(
      onFailure: (failure) {
        final List<RotinaHabitoEntity> revertida =
            List<RotinaHabitoEntity>.from(state.habitos);
        final int revIdx = revertida.indexWhere((h) => h.id == id);
        if (revIdx != -1) {
          revertida[revIdx] = original;
        }
        state = state.copyWith(habitos: revertida, failure: failure);
      },
      onSuccess: (_) {},
    );
  }

  /// Exclui hábito com Optimistic UI.
  Future<bool> excluirHabito(String id) async {
    final List<RotinaHabitoEntity> backup = state.habitos;
    state = state.copyWith(
      habitos: state.habitos.where((h) => h.id != id).toList(),
      clearFailure: true,
    );

    final Result<void> result = await _repository.deleteHabito(id);
    if (_disposed) return false;

    return result.fold(
      onFailure: (failure) {
        state = state.copyWith(habitos: backup, failure: failure);
        return false;
      },
      onSuccess: (_) => true,
    );
  }
}

final NotifierProvider<RotinaNotifier, RotinaState> rotinaNotifierProvider =
    NotifierProvider<RotinaNotifier, RotinaState>(RotinaNotifier.new);
