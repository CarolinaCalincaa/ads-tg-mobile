import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';
import 'package:produtividade_tcc/features/pilares/data/repositories/pilares_repository_impl.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';
import 'package:produtividade_tcc/features/pilares/domain/repositories/pilares_repository.dart';

enum PilaresStatus { initial, loading, success, error }

class PilaresState extends Equatable {
  const PilaresState({
    required this.status,
    required this.pilaresMestres,
    required this.mesAno,
    required this.activePillarIds,
    this.warningMessage,
    this.failure,
  });

  const PilaresState.initial({String? mesAno})
      : this(
          status: PilaresStatus.initial,
          pilaresMestres: PilarEntity.pilaresMestresCanonicos,
          mesAno: mesAno ?? '2026-10-01',
          activePillarIds: const <int>{},
        );

  final PilaresStatus status;
  final List<PilarEntity> pilaresMestres;
  final String mesAno;
  final Set<int> activePillarIds;
  final String? warningMessage;
  final AppFailure? failure;

  bool get isLoading => status == PilaresStatus.loading;
  bool get hasWarning => warningMessage != null && warningMessage!.isNotEmpty;
  bool get hasError => status == PilaresStatus.error && failure != null;

  PilaresState copyWith({
    PilaresStatus? status,
    List<PilarEntity>? pilaresMestres,
    String? mesAno,
    Set<int>? activePillarIds,
    String? warningMessage,
    bool clearWarning = false,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return PilaresState(
      status: status ?? this.status,
      pilaresMestres: pilaresMestres ?? this.pilaresMestres,
      mesAno: mesAno ?? this.mesAno,
      activePillarIds: activePillarIds ?? this.activePillarIds,
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        pilaresMestres,
        mesAno,
        activePillarIds,
        warningMessage,
        failure,
      ];
}

class PilaresNotifier extends Notifier<PilaresState> {
  PilaresRepository get _repository => ref.read(pilaresRepositoryProvider);
  bool _disposed = false;

  @override
  PilaresState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });

    final DateTime now = DateTime.now();
    final String currentMesAno = DateFormat('yyyy-MM-01').format(now);

    Future<void>.microtask(() {
      if (!_disposed) {
        loadPilares(currentMesAno);
      }
    });

    return PilaresState.initial(mesAno: currentMesAno);
  }

  /// Carrega os 7 pilares mestres e os pilares ativos para o mês informado.
  Future<void> loadPilares(String mesAno) async {
    if (_disposed) return;
    state = state.copyWith(
      status: PilaresStatus.loading,
      mesAno: mesAno,
      clearWarning: true,
      clearFailure: true,
    );

    final Result<List<PilarEntity>> pilaresResult =
        await _repository.getPilares();
    if (_disposed) return;
    final List<PilarEntity> mestres = pilaresResult.fold(
      onFailure: (_) => PilarEntity.pilaresMestresCanonicos,
      onSuccess: (data) => data.isNotEmpty
          ? data
          : PilarEntity.pilaresMestresCanonicos,
    );

    final Result<List<int>> ativosResult =
        await _repository.getPilaresAtivos(mesAno);
    if (_disposed) return;
    final Set<int> ativos = ativosResult.fold(
      onFailure: (_) => state.activePillarIds,
      onSuccess: (ids) => ids.toSet(),
    );

    state = state.copyWith(
      status: PilaresStatus.success,
      pilaresMestres: mestres,
      activePillarIds: ativos,
    );
  }

  /// Alterna a ativação de um pilar no mês respeitando estritamente a RN01.
  ///
  /// Se tentar ativar um 4º pilar quando já existem 3 selecionados:
  /// Bloqueia na UI imediatamente (sem efetuar requisição de rede) e exibe o alerta:
  /// `"Selecione apenas 3 pilares por mês!"`.
  void togglePilar(int idPilar) {
    final Set<int> current = Set<int>.from(state.activePillarIds);

    if (current.contains(idPilar)) {
      current.remove(idPilar);
      state = state.copyWith(
        activePillarIds: current,
        clearWarning: true,
        clearFailure: true,
      );
    } else {
      if (current.length >= 3) {
        // Bloqueio imediato RN01 (Critério Formal de Aceite do TCC)
        state = state.copyWith(
          warningMessage: 'Selecione apenas 3 pilares por mês!',
        );
        return;
      }
      current.add(idPilar);
      state = state.copyWith(
        activePillarIds: current,
        clearWarning: true,
        clearFailure: true,
      );
    }
  }

  /// Salva os pilares ativos no backend NestJS.
  Future<bool> salvar() async {
    if (state.activePillarIds.length > 3) {
      state = state.copyWith(
        warningMessage: 'Selecione apenas 3 pilares por mês!',
      );
      return false;
    }

    state = state.copyWith(status: PilaresStatus.loading, clearWarning: true);

    final Result<List<int>> result = await _repository.setPilaresAtivos(
      state.mesAno,
      state.activePillarIds.toList(),
    );

    return result.fold(
      onFailure: (AppFailure failure) {
        final String message = failure is MaxActivePillarsExceededFailure
            ? 'Selecione apenas 3 pilares por mês!'
            : failure.message;
        state = state.copyWith(
          status: PilaresStatus.error,
          failure: failure,
          warningMessage: message,
        );
        return false;
      },
      onSuccess: (savedIds) {
        state = state.copyWith(
          status: PilaresStatus.success,
          activePillarIds: savedIds.toSet(),
          clearWarning: true,
          clearFailure: true,
        );

        // Recarrega o Painel do Dia para atualizar os chips e filtros
        try {
          final String currentDate = ref.read(selectedDateStringProvider);
          ref.read(painelDiaNotifierProvider.notifier).loadDia(currentDate);
        } catch (_) {}

        return true;
      },
    );
  }

  void clearWarning() {
    state = state.copyWith(clearWarning: true);
  }
}

final NotifierProvider<PilaresNotifier, PilaresState> pilaresNotifierProvider =
    NotifierProvider<PilaresNotifier, PilaresState>(PilaresNotifier.new);
