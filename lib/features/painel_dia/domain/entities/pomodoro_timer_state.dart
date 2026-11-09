import 'package:equatable/equatable.dart';

enum PomodoroStatus {
  idle,
  running,
  paused,
  completed,
}

/// Estado imutável do temporizador Pomodoro (`Tech Doc 04 — Seção 4` e `E04-T04`).
class PomodoroTimerState extends Equatable {
  const PomodoroTimerState({
    required this.idTarefa,
    required this.nomeTarefa,
    required this.nomePilar,
    required this.corPilarHex,
    this.corFundoHex = '#EEF2FF',
    required this.duracaoTotalSegundos,
    required this.segundosRestantes,
    required this.status,
    this.startedAtUtc,
    this.accumulatedElapsedSeconds = 0,
  });

  const PomodoroTimerState.initial()
      : idTarefa = '',
        nomeTarefa = '',
        nomePilar = '',
        corPilarHex = '#6366F1',
        corFundoHex = '#EEF2FF',
        duracaoTotalSegundos = 1500, // 25 min padrão
        segundosRestantes = 1500,
        status = PomodoroStatus.idle,
        startedAtUtc = null,
        accumulatedElapsedSeconds = 0;

  final String idTarefa;
  final String nomeTarefa;
  final String nomePilar;
  final String corPilarHex;
  final String corFundoHex;
  final int duracaoTotalSegundos;
  final int segundosRestantes;
  final PomodoroStatus status;
  final DateTime? startedAtUtc;
  final int accumulatedElapsedSeconds;

  bool get isActive =>
      status == PomodoroStatus.running || status == PomodoroStatus.paused;

  bool get isRunning => status == PomodoroStatus.running;
  bool get isPaused => status == PomodoroStatus.paused;
  bool get isCompleted => status == PomodoroStatus.completed;
  bool get isIdle => status == PomodoroStatus.idle;

  double get progress => duracaoTotalSegundos > 0
      ? (1.0 - (segundosRestantes / duracaoTotalSegundos)).clamp(0.0, 1.0)
      : 0.0;

  String get tempoFormatado {
    final int m = segundosRestantes ~/ 60;
    final int s = segundosRestantes % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  PomodoroTimerState copyWith({
    String? idTarefa,
    String? nomeTarefa,
    String? nomePilar,
    String? corPilarHex,
    String? corFundoHex,
    int? duracaoTotalSegundos,
    int? segundosRestantes,
    PomodoroStatus? status,
    DateTime? startedAtUtc,
    bool clearStartedAtUtc = false,
    int? accumulatedElapsedSeconds,
  }) {
    return PomodoroTimerState(
      idTarefa: idTarefa ?? this.idTarefa,
      nomeTarefa: nomeTarefa ?? this.nomeTarefa,
      nomePilar: nomePilar ?? this.nomePilar,
      corPilarHex: corPilarHex ?? this.corPilarHex,
      corFundoHex: corFundoHex ?? this.corFundoHex,
      duracaoTotalSegundos: duracaoTotalSegundos ?? this.duracaoTotalSegundos,
      segundosRestantes: segundosRestantes ?? this.segundosRestantes,
      status: status ?? this.status,
      startedAtUtc:
          clearStartedAtUtc ? null : (startedAtUtc ?? this.startedAtUtc),
      accumulatedElapsedSeconds:
          accumulatedElapsedSeconds ?? this.accumulatedElapsedSeconds,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        idTarefa,
        nomeTarefa,
        nomePilar,
        corPilarHex,
        corFundoHex,
        duracaoTotalSegundos,
        segundosRestantes,
        status,
        startedAtUtc,
        accumulatedElapsedSeconds,
      ];
}
