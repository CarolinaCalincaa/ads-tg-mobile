import 'package:equatable/equatable.dart';

/// Provedor de autenticação da conta do usuário (`Tech Doc 02 — ProvedorOAuth`).
enum ProvedorOAuth {
  local('LOCAL', 'E-mail e Senha'),
  google('GOOGLE', 'Google'),
  apple('APPLE', 'Apple');

  const ProvedorOAuth(this.apiValue, this.displayLabel);

  final String apiValue;
  final String displayLabel;

  static ProvedorOAuth fromString(String? raw) {
    return switch (raw?.toUpperCase().trim()) {
      'GOOGLE' => ProvedorOAuth.google,
      'APPLE' => ProvedorOAuth.apple,
      _ => ProvedorOAuth.local,
    };
  }
}

/// Entidade de domínio do Usuário autenticado (`RF01–RF05`, `RN02`).
class UsuarioEntity extends Equatable {
  const UsuarioEntity({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    this.provedorOauth = ProvedorOAuth.local,
    this.horasSonoDiarias = 8,
    this.onboardingConcluido = false,
  });

  final String id;
  final String nomeCompleto;
  final String email;
  final ProvedorOAuth provedorOauth;
  final int horasSonoDiarias;
  final bool onboardingConcluido;

  /// Horas acordadas disponíveis no dia (`24 - horasSonoDiarias`).
  int get horasUteisDiarias => (24 - horasSonoDiarias).clamp(0, 24);

  /// Total de minutos úteis disponíveis no dia (`(24 - horasSonoDiarias) * 60` — `RN02`).
  int get minutosUteisDiarios => (24 - horasSonoDiarias) * 60;

  /// Limite saudável de ocupação diária sem fadiga mental (`80%` dos minutos úteis — `RN02`).
  int get limiteFadigaMinutos => (minutosUteisDiarios * 0.8).round();

  /// Primeiro nome para saudações no cabeçalho (`Bom dia, {primeiroNome}`).
  String get primeiroNome {
    final String trimmed = nomeCompleto.trim();
    if (trimmed.isEmpty) {
      return 'Usuário';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }

  /// Até 2 iniciais em maiúsculas para avatares (`CS` para `Carolina Silva`).
  String get iniciais {
    final List<String> parts = nomeCompleto
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final String first = parts.first.substring(0, 1).toUpperCase();
    final String last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }

  UsuarioEntity copyWith({
    String? id,
    String? nomeCompleto,
    String? email,
    ProvedorOAuth? provedorOauth,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  }) {
    return UsuarioEntity(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      provedorOauth: provedorOauth ?? this.provedorOauth,
      horasSonoDiarias: horasSonoDiarias ?? this.horasSonoDiarias,
      onboardingConcluido: onboardingConcluido ?? this.onboardingConcluido,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    nomeCompleto,
    email,
    provedorOauth,
    horasSonoDiarias,
    onboardingConcluido,
  ];
}

/// Sessão autenticada contendo o [UsuarioEntity] e o par de tokens JWT/Refresh (`ADR-005`).
class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
    required this.usuario,
    required this.accessToken,
    required this.refreshToken,
  });

  final UsuarioEntity usuario;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => <Object?>[usuario, accessToken, refreshToken];
}
