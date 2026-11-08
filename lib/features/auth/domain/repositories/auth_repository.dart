import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';

/// Contrato abstrato do repositório de Autenticação e Perfil (`RF01–RF05`, `RNF05`, `RNF07`).
///
/// Mantém a camada `domain/` livre de dependências de rede (`Dio`) ou banco local (`Drift`).
abstract interface class AuthRepository {
  /// Autentica usuário por e-mail e senha (`POST /api/v1/auth/login` — `RF03`).
  Future<Result<AuthSessionEntity>> login({
    required String email,
    required String senha,
  });

  /// Registra nova conta local com validação de senha forte (`POST /api/v1/auth/register` — `RF01`, `RF02`).
  Future<Result<AuthSessionEntity>> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  });

  /// Autentica ou cria conta via Google OAuth 2.0 (`POST /api/v1/auth/oauth/google` — `RF03`).
  Future<Result<AuthSessionEntity>> loginWithGoogle({
    required String idToken,
  });

  /// Autentica ou cria conta via Apple Sign-In (`POST /api/v1/auth/oauth/apple` — `RF03`).
  Future<Result<AuthSessionEntity>> loginWithApple({
    required String idToken,
    String? nomeCompleto,
  });

  /// Solicita código temporário de 6 dígitos por e-mail (`POST /api/v1/auth/forgot-password` — `RF04`).
  Future<Result<void>> forgotPassword({
    required String email,
  });

  /// Redefine a senha utilizando o código de 6 dígitos recebido (`POST /api/v1/auth/reset-password` — `RF04`).
  Future<Result<void>> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  });

  /// Obtém o perfil atualizado do usuário autenticado (`GET /api/v1/usuarios/me`).
  Future<Result<UsuarioEntity>> getMe();

  /// Atualiza dados de perfil ou horas diárias de sono (`PATCH /api/v1/usuarios/me` — `RF05`).
  Future<Result<UsuarioEntity>> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  });

  /// Exclui definitivamente a conta e todos os dados em cascata (`DELETE /api/v1/usuarios/me` — `RNF07`).
  Future<Result<void>> deleteAccount({
    String confirmacao = 'EXCLUIR',
  });

  /// Encerra a sessão atual no servidor e limpa tokens locais (`POST /api/v1/auth/logout`).
  Future<Result<void>> logout();

  /// Recupera usuário hidratado do armazenamento seguro caso exista sessão válida.
  Future<UsuarioEntity?> getHydratedUser();
}
