import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pomodoro_timer_state.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/repositories/painel_repository.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';

/// Notifier do temporizador Pomodoro (`Tech Doc 04 — Seção 4` e `E04-T04`).
///
/// Implementa relógio UTC drift-safe: calcula o tempo decorrido com base na diferença
/// `DateTime.now().toUtc().difference(startedAtUtc)` para nunca atrasar em segundo plano
/// ou quando a tela for bloqueada.
class PomodoroNotifier extends Notifier<PomodoroTimerState> {
  Timer? _timer;

  PainelRepository get _repository => ref.read(painelRepositoryProvider);

  @override
  PomodoroTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const PomodoroTimerState.initial();
  }

  /// Inicia o temporizador Pomodoro para uma tarefa específica.
  void start(TimelineItemEntity item, {int duracaoMinutos = 25}) {
    // Se a mesma tarefa já estiver rodando, mantém
    if (state.idTarefa == item.id && state.isRunning) {
      return;
    }

    _timer?.cancel();
    final int duracaoSegundos = duracaoMinutos * 60;

    state = PomodoroTimerState(
      idTarefa: item.id,
      nomeTarefa: item.nome,
      nomePilar: item.pilar.nome,
      corPilarHex: item.pilar.corHex,
      corFundoHex: item.pilar.corFundoHex,
      duracaoTotalSegundos: duracaoSegundos,
      segundosRestantes: duracaoSegundos,
      status: PomodoroStatus.running,
      startedAtUtc: DateTime.now().toUtc(),
      accumulatedElapsedSeconds: 0,
    );

    _iniciarTicker();
  }

  /// Pausa a contagem regressiva preservando o tempo acumulado drift-safe.
  void pause() {
    if (!state.isRunning) return;

    _timer?.cancel();
    final DateTime? start = state.startedAtUtc;
    final int elapsedNow =
        start != null ? DateTime.now().toUtc().difference(start).inSeconds : 0;
    final int newAccumulated = state.accumulatedElapsedSeconds + elapsedNow;
    final int remaining = (state.duracaoTotalSegundos - newAccumulated)
        .clamp(0, state.duracaoTotalSegundos);

    state = state.copyWith(
      status: PomodoroStatus.paused,
      clearStartedAtUtc: true,
      accumulatedElapsedSeconds: newAccumulated,
      segundosRestantes: remaining,
    );
  }

  /// Retoma a contagem a partir do ponto pausado.
  void resume() {
    if (state.status != PomodoroStatus.paused) return;

    state = state.copyWith(
      status: PomodoroStatus.running,
      startedAtUtc: DateTime.now().toUtc(),
    );

    _iniciarTicker();
  }

  /// Reinicia o ciclo de foco da tarefa atual.
  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      status: PomodoroStatus.idle,
      clearStartedAtUtc: true,
      accumulatedElapsedSeconds: 0,
      segundosRestantes: state.duracaoTotalSegundos,
    );
  }

  /// Conclui o ciclo de foco antecipadamente e registra a sessão.
  Future<void> completeEarly() async {
    await _finalizarSessao();
  }

  /// Inicia ou reanexa o ticker periódico de 500ms para atualização visual suave.
  void _iniciarTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _tick();
    });
  }

  void _tick() {
    if (!state.isRunning || state.startedAtUtc == null) return;

    final int elapsedSinceStart =
        DateTime.now().toUtc().difference(state.startedAtUtc!).inSeconds;
    final int totalElapsed =
        state.accumulatedElapsedSeconds + elapsedSinceStart;
    final int remaining = state.duracaoTotalSegundos - totalElapsed;

    if (remaining <= 0) {
      _finalizarSessao();
    } else if (remaining != state.segundosRestantes) {
      state = state.copyWith(segundosRestantes: remaining);
    }
  }

  Future<void> _finalizarSessao() async {
    _timer?.cancel();
    final String idTarefa = state.idTarefa;
    final int duracaoMinutos = state.duracaoTotalSegundos ~/ 60;

    state = state.copyWith(
      status: PomodoroStatus.completed,
      clearStartedAtUtc: true,
      segundosRestantes: 0,
    );

    if (idTarefa.isNotEmpty) {
      final payload = <String, dynamic>{
        'idTarefa': idTarefa,
        'duracaoMinutos': duracaoMinutos,
        'concluido': true,
        'dataInicio': DateTime.now()
            .toUtc()
            .subtract(Duration(minutes: duracaoMinutos))
            .toIso8601String(),
        'dataFim': DateTime.now().toUtc().toIso8601String(),
      };

      await _repository.registrarSessaoPomodoro(payload);
      try {
        ref
            .read(painelDiaNotifierProvider.notifier)
            .incrementPomodoroCount(idTarefa);
      } catch (_) {}
    }
  }
}

final NotifierProvider<PomodoroNotifier, PomodoroTimerState>
    pomodoroNotifierProvider =
    NotifierProvider<PomodoroNotifier, PomodoroTimerState>(PomodoroNotifier.new);
