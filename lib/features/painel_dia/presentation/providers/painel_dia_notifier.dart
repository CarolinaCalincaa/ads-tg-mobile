import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_semana_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/repositories/painel_repository.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';

enum PainelStatus { initial, loading, success, error }
enum VisaoModo { dia, semana }
enum AbaDependencia { minhasAcoes, emEspera }

class PainelDiaState extends Equatable {
  const PainelDiaState({
    required this.status,
    this.bundle,
    this.semanaBundle,
    this.visaoModo = VisaoModo.dia,
    this.abaDependencia = AbaDependencia.minhasAcoes,
    this.expandedChecklistIds = const <String>{},
    this.failure,
  });

  const PainelDiaState.initial()
      : this(status: PainelStatus.initial);

  final PainelStatus status;
  final PainelDiaBundle? bundle;
  final PainelSemanaBundle? semanaBundle;
  final VisaoModo visaoModo;
  final AbaDependencia abaDependencia;
  final Set<String> expandedChecklistIds;
  final AppFailure? failure;

  bool get isLoading => status == PainelStatus.loading;
  bool get hasError => status == PainelStatus.error && failure != null;

  PainelDiaState copyWith({
    PainelStatus? status,
    PainelDiaBundle? bundle,
    PainelSemanaBundle? semanaBundle,
    VisaoModo? visaoModo,
    AbaDependencia? abaDependencia,
    Set<String>? expandedChecklistIds,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return PainelDiaState(
      status: status ?? this.status,
      bundle: bundle ?? this.bundle,
      semanaBundle: semanaBundle ?? this.semanaBundle,
      visaoModo: visaoModo ?? this.visaoModo,
      abaDependencia: abaDependencia ?? this.abaDependencia,
      expandedChecklistIds: expandedChecklistIds ?? this.expandedChecklistIds,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        bundle,
        semanaBundle,
        visaoModo,
        abaDependencia,
        expandedChecklistIds,
        failure,
      ];
}

class PainelDiaNotifier extends Notifier<PainelDiaState> {
  PainelRepository get _repository => ref.read(painelRepositoryProvider);
  bool _disposed = false;

  @override
  PainelDiaState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });

    final String dateStr = ref.watch(selectedDateStringProvider);
    Future<void>.microtask(() {
      if (!_disposed) {
        loadDia(dateStr);
      }
    });
    return const PainelDiaState.initial();
  }

  Future<void> loadDia(String dateStr) async {
    if (_disposed) return;
    state = state.copyWith(status: PainelStatus.loading, clearFailure: true);
    final Result<PainelDiaBundle> result = await _repository.getPainelDia(dateStr);

    if (_disposed) return;
    result.fold(
      onFailure: (AppFailure failure) {
        if (_disposed) return;
        state = state.copyWith(
          status: PainelStatus.error,
          failure: failure,
        );
      },
      onSuccess: (PainelDiaBundle bundle) {
        if (_disposed) return;
        state = state.copyWith(
          status: PainelStatus.success,
          bundle: bundle,
          clearFailure: true,
        );
      },
    );
  }

  Future<void> loadSemana(String dateStr) async {
    state = state.copyWith(status: PainelStatus.loading, clearFailure: true);
    final Result<PainelSemanaBundle> result =
        await _repository.getPainelSemana(dateStr);

    result.fold(
      onFailure: (AppFailure failure) {
        state = state.copyWith(
          status: PainelStatus.error,
          failure: failure,
        );
      },
      onSuccess: (PainelSemanaBundle semanaBundle) {
        state = state.copyWith(
          status: PainelStatus.success,
          semanaBundle: semanaBundle,
          clearFailure: true,
        );
      },
    );
  }

  void setVisaoModo(VisaoModo modo) {
    if (state.visaoModo == modo) return;
    state = state.copyWith(visaoModo: modo);
    final String dateStr = ref.read(selectedDateStringProvider);
    if (modo == VisaoModo.semana) {
      loadSemana(dateStr);
    } else {
      loadDia(dateStr);
    }
  }

  void setAbaDependencia(AbaDependencia aba) {
    state = state.copyWith(abaDependencia: aba);
  }

  void toggleChecklistAccordion(String idChecklist) {
    final Set<String> updated = Set<String>.from(state.expandedChecklistIds);
    if (updated.contains(idChecklist)) {
      updated.remove(idChecklist);
    } else {
      updated.add(idChecklist);
    }
    state = state.copyWith(expandedChecklistIds: updated);
  }

  /// Toggle OTIMISTA de conclusão em 1 clique (RNF04)
  Future<void> toggleItemCompletion(TimelineItemEntity item) async {
    final PainelDiaBundle? currentBundle = state.bundle;
    if (currentBundle == null) return;

    final bool newConcluido = !item.concluido;

    // 1. Atualização Otimista Imediata na UI
    final List<TimelineItemEntity> updatedLinha =
        currentBundle.itensLinhaTempo.map((t) {
      if (t.id == item.id) {
        return t.copyWith(concluido: newConcluido);
      }
      return t;
    }).toList();

    final List<TimelineItemEntity> updatedEspera =
        currentBundle.itensEmEspera.map((t) {
      if (t.id == item.id) {
        return t.copyWith(concluido: newConcluido);
      }
      return t;
    }).toList();

    state = state.copyWith(
      bundle: currentBundle.copyWith(
        itensLinhaTempo: updatedLinha,
        itensEmEspera: updatedEspera,
      ),
    );

    // 2. Persistência em background via API REST
    final Result<void> result = await _repository.toggleTaskStatus(
      item.id,
      newConcluido,
    );

    result.fold(
      onFailure: (AppFailure failure) {
        // Reverte imediatamente em caso de erro e exibe alerta
        state = state.copyWith(
          status: PainelStatus.error,
          bundle: currentBundle,
          failure: failure,
        );
      },
      onSuccess: (_) {
        // Sucesso garantido, o estado já estava sincronizado
      },
    );
  }

  /// Toggle OTIMISTA de subitem de checklist em 1 clique (RF20)
  Future<void> toggleChecklistItem({
    required String idChecklist,
    required String itemId,
    required bool currentConcluido,
  }) async {
    final PainelDiaBundle? currentBundle = state.bundle;
    if (currentBundle == null) return;

    final bool nextConcluido = !currentConcluido;

    // Atualização otimista em memória
    final List<TimelineItemEntity> updatedLinha =
        currentBundle.itensLinhaTempo.map((item) {
      final List<ChecklistEntity> updatedChecklists = item.checklists.map((c) {
        if (c.id == idChecklist) {
          final List<ItemChecklistEntity> updatedItens = c.itens.map((it) {
            if (it.id == itemId) {
              return it.copyWith(concluido: nextConcluido);
            }
            return it;
          }).toList();
          final int concluidos = updatedItens.where((i) => i.concluido).length;
          return c.copyWith(
            itens: updatedItens,
            itensConcluidos: concluidos,
          );
        }
        return c;
      }).toList();

      return item.copyWith(checklists: updatedChecklists);
    }).toList();

    state = state.copyWith(
      bundle: currentBundle.copyWith(itensLinhaTempo: updatedLinha),
    );

    final Result<void> result = await _repository.toggleChecklistItem(
      idChecklist: idChecklist,
      itemId: itemId,
      concluido: nextConcluido,
    );

    result.fold(
      onFailure: (AppFailure failure) {
        // Reverte em caso de falha
        state = state.copyWith(
          status: PainelStatus.error,
          bundle: currentBundle,
          failure: failure,
        );
      },
      onSuccess: (_) {},
    );
  }

  Future<bool> createTask(Map<String, dynamic> payload) async {
    state = state.copyWith(status: PainelStatus.loading, clearFailure: true);
    final Result<Map<String, dynamic>> result =
        await _repository.createTask(payload);

    return result.fold(
      onFailure: (AppFailure failure) {
        state = state.copyWith(
          status: PainelStatus.error,
          failure: failure,
        );
        return false;
      },
      onSuccess: (_) {
        final String dateStr = ref.read(selectedDateStringProvider);
        loadDia(dateStr);
        return true;
      },
    );
  }

  Future<bool> updateTask(String id, Map<String, dynamic> payload) async {
    state = state.copyWith(status: PainelStatus.loading, clearFailure: true);
    final Result<Map<String, dynamic>> result =
        await _repository.updateTask(id, payload);

    return result.fold(
      onFailure: (AppFailure failure) {
        state = state.copyWith(
          status: PainelStatus.error,
          failure: failure,
        );
        return false;
      },
      onSuccess: (_) {
        final String dateStr = ref.read(selectedDateStringProvider);
        loadDia(dateStr);
        return true;
      },
    );
  }

  Future<bool> rescheduleTask(String id, String novaData) async {
    return updateTask(id, <String, dynamic>{'dataAgendamento': novaData});
  }

  Future<bool> deleteTask(String id) async {
    final PainelDiaBundle? currentBundle = state.bundle;
    if (currentBundle != null) {
      // Remoção otimista visual
      state = state.copyWith(
        bundle: currentBundle.copyWith(
          itensLinhaTempo: currentBundle.itensLinhaTempo
              .where((t) => t.id != id)
              .toList(),
          itensEmEspera: currentBundle.itensEmEspera
              .where((t) => t.id != id)
              .toList(),
        ),
      );
    }

    final Result<void> result = await _repository.deleteTask(id);
    return result.fold(
      onFailure: (AppFailure failure) {
        if (currentBundle != null) {
          state = state.copyWith(
            status: PainelStatus.error,
            bundle: currentBundle,
            failure: failure,
          );
        }
        return false;
      },
      onSuccess: (_) {
        final String dateStr = ref.read(selectedDateStringProvider);
        loadDia(dateStr);
        return true;
      },
    );
  }

  void clearFailure() {
    state = state.copyWith(clearFailure: true);
  }

  void incrementPomodoroCount(String idTarefa) {
    final currentBundle = state.bundle;
    if (currentBundle == null) return;

    final updatedLinhaTempo = currentBundle.itensLinhaTempo.map((item) {
      if (item.id == idTarefa) {
        return item.copyWith(
          pomodorosConcluidos: item.pomodorosConcluidos + 1,
        );
      }
      return item;
    }).toList();

    final updatedEmEspera = currentBundle.itensEmEspera.map((item) {
      if (item.id == idTarefa) {
        return item.copyWith(
          pomodorosConcluidos: item.pomodorosConcluidos + 1,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      bundle: currentBundle.copyWith(
        itensLinhaTempo: updatedLinhaTempo,
        itensEmEspera: updatedEmEspera,
      ),
    );
  }
}

final NotifierProvider<PainelDiaNotifier, PainelDiaState> painelDiaNotifierProvider =
    NotifierProvider<PainelDiaNotifier, PainelDiaState>(PainelDiaNotifier.new);
