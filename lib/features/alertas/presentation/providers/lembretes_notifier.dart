import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/notifications/local_notification_service.dart';
import 'package:produtividade_tcc/features/alertas/data/repositories/lembretes_repository_impl.dart';
import 'package:produtividade_tcc/features/alertas/domain/entities/lembrete_config_entity.dart';
import 'package:produtividade_tcc/features/alertas/domain/repositories/lembretes_repository.dart';

enum LembretesStatus { initial, loading, success, error }

class LembretesState extends Equatable {
  const LembretesState({
    required this.status,
    required this.configs,
    this.isSaving = false,
    this.failure,
  });

  const LembretesState.initial()
      : this(
          status: LembretesStatus.initial,
          configs: LembreteConfigEntity.padroes,
        );

  final LembretesStatus status;
  final List<LembreteConfigEntity> configs;
  final bool isSaving;
  final AppFailure? failure;

  bool get isLoading => status == LembretesStatus.loading;
  bool get hasError => status == LembretesStatus.error && failure != null;

  LembreteConfigEntity getByType(TipoLembrete tipo) {
    return configs.firstWhere(
      (c) => c.tipo == tipo,
      orElse: () => LembreteConfigEntity.padroes.firstWhere((c) => c.tipo == tipo),
    );
  }

  LembretesState copyWith({
    LembretesStatus? status,
    List<LembreteConfigEntity>? configs,
    bool? isSaving,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return LembretesState(
      status: status ?? this.status,
      configs: configs ?? this.configs,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        configs,
        isSaving,
        failure,
      ];
}

class LembretesNotifier extends Notifier<LembretesState> {
  LembretesRepository get _repository => ref.read(lembretesRepositoryProvider);
  LocalNotificationService get _notificationService =>
      ref.read(localNotificationServiceProvider);
  bool _disposed = false;

  @override
  LembretesState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });

    Future<void>.microtask(() {
      if (!_disposed) {
        loadLembretes();
      }
    });
    return const LembretesState.initial();
  }

  Future<void> loadLembretes() async {
    if (_disposed) return;
    state = state.copyWith(status: LembretesStatus.loading, clearFailure: true);
    final Result<List<LembreteConfigEntity>> result =
        await _repository.getLembretes();
    if (_disposed) return;

    result.fold(
      onFailure: (failure) {
        if (!_disposed) {
          state = state.copyWith(
            status: LembretesStatus.error,
            failure: failure,
          );
        }
      },
      onSuccess: (data) {
        if (!_disposed) {
          state = state.copyWith(
            status: LembretesStatus.success,
            configs: data.isNotEmpty ? data : LembreteConfigEntity.padroes,
          );
        }
      },
    );
  }

  void toggleAtivo(TipoLembrete tipo, bool ativo) {
    final List<LembreteConfigEntity> updated = state.configs.map((c) {
      if (c.tipo == tipo) {
        return c.copyWith(ativo: ativo);
      }
      return c;
    }).toList();

    state = state.copyWith(configs: updated);
    salvarTudo();
  }

  void updateConfig(LembreteConfigEntity config) {
    final List<LembreteConfigEntity> updated = state.configs.map((c) {
      if (c.tipo == config.tipo) {
        return config;
      }
      return c;
    }).toList();

    state = state.copyWith(configs: updated);
    salvarTudo();
  }

  Future<void> testarLembrete(TipoLembrete tipo) async {
    final LembreteConfigEntity config = state.getByType(tipo);
    await _notificationService.showTestNotification(
      id: tipo.index + 1,
      title: config.titulo,
      body: config.descricao,
    );
  }

  Future<bool> salvarTudo() async {
    state = state.copyWith(isSaving: true, clearFailure: true);
    final Result<List<LembreteConfigEntity>> result =
        await _repository.saveLembretes(state.configs);

    return result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isSaving: false,
          failure: failure,
        );
        return false;
      },
      onSuccess: (saved) {
        state = state.copyWith(
          isSaving: false,
          configs: saved,
        );
        return true;
      },
    );
  }
}

final NotifierProvider<LembretesNotifier, LembretesState> lembretesNotifierProvider =
    NotifierProvider<LembretesNotifier, LembretesState>(LembretesNotifier.new);
