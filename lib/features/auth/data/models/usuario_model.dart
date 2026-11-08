import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';

/// Modelo de serialização JSON para [UsuarioEntity] (`Tech Doc 02` e `Tech Doc 03`).
class UsuarioModel extends UsuarioEntity {
  const UsuarioModel({
    required super.id,
    required super.nomeCompleto,
    required super.email,
    super.provedorOauth,
    super.horasSonoDiarias,
    super.onboardingConcluido,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final String id =
        (source['id'] ?? source['idUsuario'] ?? source['id_usuario'] ?? '')
            .toString();
    final String nomeCompleto =
        (source['nomeCompleto'] ?? source['nome_completo'] ?? '').toString();
    final String email = (source['email'] ?? '').toString();
    final String? provedorRaw =
        (source['provedorOauth'] ?? source['provedor_oauth']) as String?;
    final num? horasSonoRaw =
        (source['horasSonoDiarias'] ?? source['horas_sono_diarias']) as num?;
    final bool onboardingConcluido =
        (source['onboardingConcluido'] ?? source['onboarding_concluido']) ==
        true;

    return UsuarioModel(
      id: id,
      nomeCompleto: nomeCompleto,
      email: email,
      provedorOauth: ProvedorOAuth.fromString(provedorRaw),
      horasSonoDiarias: horasSonoRaw?.toInt() ?? 8,
      onboardingConcluido: onboardingConcluido,
    );
  }

  factory UsuarioModel.fromEntity(UsuarioEntity entity) {
    return UsuarioModel(
      id: entity.id,
      nomeCompleto: entity.nomeCompleto,
      email: entity.email,
      provedorOauth: entity.provedorOauth,
      horasSonoDiarias: entity.horasSonoDiarias,
      onboardingConcluido: entity.onboardingConcluido,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'provedorOauth': provedorOauth.apiValue,
      'horasSonoDiarias': horasSonoDiarias,
      'onboardingConcluido': onboardingConcluido,
    };
  }
}

/// Modelo de serialização JSON para [AuthSessionEntity].
class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required UsuarioModel super.usuario,
    required super.accessToken,
    required super.refreshToken,
  });

  UsuarioModel get usuarioModel => usuario as UsuarioModel;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final Map<String, dynamic> userMap =
        source['usuario'] is Map<String, dynamic>
        ? source['usuario'] as Map<String, dynamic>
        : (source['user'] is Map<String, dynamic>
              ? source['user'] as Map<String, dynamic>
              : source);

    return AuthSessionModel(
      usuario: UsuarioModel.fromJson(userMap),
      accessToken:
          (source['accessToken'] ?? source['access_token'] ?? '').toString(),
      refreshToken:
          (source['refreshToken'] ?? source['refresh_token'] ?? '').toString(),
    );
  }
}
