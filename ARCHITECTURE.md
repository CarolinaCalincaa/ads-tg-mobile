# Arquitetura do Front-end Flutter (`ads-tg-mobile`)

> **Arquivo vivo de arquitetura (`DEC-004`)**. Documenta a stack, estrutura de diretórios, camadas Clean Architecture, Design System "Calma Cognitiva", camada de rede/autenticação, navegação declarativa e decisões locais do cliente multiplataforma (**Android, iOS e Web SPA**) do **Sistema Integrado de Gestão de Produtividade Pessoal** (TCC — FATEC Campinas, 2026).

---

## 1. Visão Geral e Estratégia Arquitetural

O aplicativo `ads-tg-mobile` (`produtividade_tcc`) adota **Clean Architecture Feature-First** combinada com a evolução planejada em 2 fases (`ADR-001` e `ADR-002`):

1. **Fase 1 — MVP Online-First (Épicos 01 a 08)**:
   - **Sem SQLite/Drift e sem Sync Engine local**.
   - As implementações de `Repository` (`data/repositories/`) comunicam-se diretamente com a API REST **NestJS** via `RemoteDataSource` (`DioClient`), convertendo respostas e erros em `Result<T>` (`Success<T>` | `FailureResult<T>`).
   - Os `Notifiers` do **Riverpod** aplicam **Optimistic UI Updates** (`RNF04`) para garantir latência visual de `0ms` ao concluir tarefas/hábitos na Linha do Tempo.
2. **Fase 2 — Pós-MVP Offline-First (Épico 09)**:
   - Graças ao desacoplamento estrito via interfaces abstratas em `domain/repositories/`, o cache local **SQLite (Drift)** e o **Sync Engine (`POST /api/v1/sync`)** serão plugados exclusivamente na camada `data/` e em `core/database/`, sem reescrever nenhuma tela ou `Notifier` da camada `presentation/` (`RNF11`).

---

## 2. Stack Tecnológica e Versões Exatas Instaladas

| Responsabilidade | Pacote / SDK | Versão (`pubspec.yaml`) | Requisitos Atendidos |
| :--- | :--- | :--- | :--- |
| **SDK Flutter / Dart** | `flutter` / `dart` | Flutter `3.47.9` / Dart `^3.13.7` | `RNF09`, `RNF10` |
| **Plataformas Alvo** | Android, iOS, Web SPA | Android `minSdk = 26` (8.0+), iOS `14.0+`, Web | `RNF03`, `RNF09`, `RNF10` |
| **Gerenciamento de Estado & DI** | `flutter_riverpod` | `^3.5.0` | `RNF04`, `RNF11` |
| **Roteamento Declarativo** | `go_router` | `^18.1.3` | `RNF03` |
| **Cliente HTTP REST** | `dio` | `^5.11.1` | `RNF01`, `RNF08` |
| **Armazenamento Seguro de Tokens** | `flutter_secure_storage` | `^11.2.0` | `RNF05` (Épico 02) |
| **Tipografia Oficial** | `google_fonts` | `^9.0.0` | `RNF04` (`Fraunces` + `Inter`) |
| **Notificações Locais** | `flutter_local_notifications` + `timezone` | `^23.0.0` / `^0.11.2` | `RF21` (Épico 05) |
| **Internacionalização & Datas** | `intl` | `^0.20.3` | Datas civis `YYYY-MM-DD` |
| **Igualdade de Valor** | `equatable` | `^3.0.0` | Entidades, Estados e `AppFailure` |
| **Linter & Testes** | `flutter_lints` / `flutter_test` | `^6.0.0` / SDK | Qualidade estática (`0 issues`) |

---

## 3. Estrutura de Diretórios (`lib/` e `test/`)

```text
apps/ads-tg-mobile/
├── pubspec.yaml
├── analysis_options.yaml                 # strict-casts, strict-raw-types e regras flutter_lints
├── lib/
│   ├── main.dart                         # Entrypoint com ProviderScope
│   ├── app.dart                          # ProdutividadeTccApp (MaterialApp.router + AppTheme)
│   ├── core/
│   │   ├── config/
│   │   │   └── env_config.dart           # EnvConfig.apiBaseUrl, googleClientId, appleClientId, oauthDevMockEnabled
│   │   ├── error/
│   │   │   ├── app_failure.dart          # Hierarquia selada AppFailure (RN01, RN02, Auth, Rede)
│   │   │   └── result.dart               # Sealed class Result<T> (Success<T> | FailureResult<T>)
│   │   ├── network/
│   │   │   ├── dio_client.dart           # DioClient (timeouts 5s) + AuthInterceptor + providers Riverpod
│   │   │   ├── auth_interceptor.dart     # Bearer token + auto-refresh em 401 (POST /auth/refresh) + AuthSessionEventBus
│   │   │   └── api_exception_mapper.dart # Tradutor do envelope de erro JSON do NestJS
│   │   ├── router/
│   │   │   ├── app_router.dart           # GoRouter + Auth Guard + StatefulShellRoute.indexedStack (4 abas)
│   │   │   └── responsive_shell_scaffold.dart # NavigationBar (<768px) vs NavigationRail (>=768px)
│   │   ├── storage/
│   │   │   └── secure_token_storage.dart # SecureTokenStorage + FlutterSecureTokenStorage + InMemoryTokenStorage
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # Paleta "Calma Cognitiva" + 7 Pilares + WCAG AA
│   │   │   ├── app_spacing.dart          # Grid 4/8px, raios (20/999/14), sombras e breakpoints
│   │   │   ├── app_typography.dart       # Fraunces + Inter (tabularFigures) + fallback offline
│   │   │   └── app_theme.dart            # ThemeData Material 3 completo
│   │   └── widgets/
│   │       ├── app_card.dart             # Card padrão (radius 20px, borda #E2E8F0 1px, sombra suave)
│   │       ├── pilar_chip.dart           # Pílula de Pilar de Vida (ícone + corHex + corFundoHex)
│   │       ├── priority_badge.dart       # Tag Prioridade / Rápido / Postergável (WCAG AA)
│   │       ├── primary_gradient_button.dart # Botão gradiente (#6366F1 -> #7C3AED) com loading/disabled
│   │       └── empty_state_view.dart     # Estado vazio sereno reutilizável
│   ├── features/
│   │   └── auth/                         # Módulo de Identidade, OAuth 2.0, Perfil Sono (RF05) e LGPD (RNF07)
│   │       ├── domain/
│   │       │   ├── entities/usuario_entity.dart # UsuarioEntity (minutosUteisDiarios, limiteFadigaMinutos) + AuthSessionEntity
│   │       │   └── repositories/auth_repository.dart # Interface abstrata AuthRepository
│   │       ├── data/
│   │       │   ├── models/usuario_model.dart # UsuarioModel + AuthSessionModel
│   │       │   ├── datasources/auth_remote_datasource.dart # DioAuthRemoteDataSource (/auth/* e /usuarios/me)
│   │       │   └── repositories/auth_repository_impl.dart # AuthRepositoryImpl
│   │       └── presentation/
│   │           ├── providers/auth_notifier.dart # AuthNotifier, AuthState e RouterAuthRefreshNotifier
│   │           ├── screens/
│   │           │   ├── login_screen.dart        # LoginScreen (/login)
│   │           │   ├── register_screen.dart     # RegisterScreen (/register)
│   │           │   ├── forgot_password_screen.dart # ForgotPasswordScreen (/forgot-password)
│   │           │   ├── reset_password_screen.dart  # ResetPasswordScreen (/reset-password)
│   │           │   └── config_screen.dart       # ConfigScreen (/config — 4ª aba)
│   │           └── widgets/
│   │               ├── oauth_buttons_row.dart   # Botões Continuar com Google e Apple
│   │               ├── password_strength_checklist.dart # Checklist visual em tempo real RF02 (5 critérios)
│   │               ├── sleep_hours_selector_card.dart   # Seletor 4h..12h com fórmula RN02 em tempo real
│   │               └── delete_account_dialog.dart       # Modal de exclusão definitiva LGPD (RNF07)
│   └── shared/                           # Utilitários e componentes transversais entre features
└── test/
    ├── widget_test.dart
    ├── core/
    │   ├── network/
    │   │   ├── api_exception_mapper_test.dart
    │   │   └── auth_interceptor_test.dart
    │   ├── router/
    │   │   └── responsive_shell_scaffold_test.dart
    │   └── widgets/
    │       └── design_system_widgets_test.dart
    └── features/
        └── auth/
            ├── auth_repository_and_notifier_test.dart
            ├── auth_screens_test.dart
            └── config_screen_test.dart
```

---

## 4. Camadas Clean Architecture e Preparação para o Épico 09

Cada feature em `lib/features/<feature>/` respeita a regra de dependência `presentation -> domain <- data`:

- **`domain/`**: Contém entidades imutáveis (`Equatable`) e contratos abstratos de repositório (`abstract interface class <Feature>Repository`) cujos métodos retornam `Future<Result<T>>`. Não importa pacotes de infraestrutura (`dio`, `flutter_secure_storage` ou `drift`).
- **`data/`**: No MVP (Épicos 01–08), implementa os repositórios consumindo `RemoteDataSource` (`DioClient`) e capturando exceções via `ApiExceptionMapper.map(error)`. No **Épico 09**, receberá `LocalDataSource` (Drift SQLite) e enfileiramento de mutações para `POST /api/v1/sync` sem alterar nenhuma assinatura de `domain/`.
- **`presentation/`**: Telas, widgets e `Notifiers` do Riverpod que consomem apenas `domain/` e os átomos visuais de `core/widgets/`.

---

## 5. Design System "Calma Cognitiva" (`core/theme/` e `core/widgets/`)

### 5.1 Tokens Principais (`Tech Doc 05 — Seção 1`)
- **Superfícies e Textos (`AppColors`)**:
  - `backgroundCanvas`: `#F8FAFC` | `surfaceCard`: `#FFFFFF` | `surfaceSubtle`: `#F1F5F9` | `borderSubtle`: `#E2E8F0`
  - `textPrimary`: `#0F172A` | `textSecondary`: `#64748B`
  - `primaryBrand`: `#6366F1` | `primaryBrandDark`: `#4F46E5` | `accentViolet`: `#7C3AED`
- **Fadiga Mental (`RN02`) e Capacidade**:
  - `fatigueBg`: `#FEF2F2` | `fatigueBorder`: `#FECACA` | `fatigueCritical`: `#DC2626` (`> 80%`)
  - `capacityWarning`: `#D97706` (`61%–80%`) | `capacityHealthy`: `#10B981` (`<= 60%`)
- **Paleta dos 7 Pilares de Vida (`Tech Doc 02 — Seção 2`)**:
  - `1 SAUDE`: `#EF4444` / `#FEF2F2` (`heart_pulse`)
  - `2 MOVIMENTO`: `#F97316` / `#FFF7ED` (`activity`)
  - `3 SONO`: `#6366F1` / `#EEF2FF` (`moon`)
  - `4 MENTE`: `#8B5CF6` / `#F5F3FF` (`brain`)
  - `5 ESTUDOS`: `#10B981` / `#ECFDF5` (`book_open`)
  - `6 FINANCAS`: `#CA8A04` / `#FEFCE8` (`wallet`)
  - `7 CARREIRA`: `#0EA5E9` / `#F0F9FF` (`briefcase`)
- **Tipografia (`AppTypography`)**:
  - Títulos / Display: **Fraunces** (`Bold 700`, `24px`, `letterSpacing: -0.5`).
  - Corpo / Controles / Números: **Inter** (`400`, `500`, `600`, `700`) com `FontFeature.tabularFigures()` em `AppTypography.tabularNumber`.

### 5.2 Átomos Compartilhados (`core/widgets/`)
- **`AppCard`**: Container com `borderRadius: 20px`, borda `#E2E8F0` (`1px`), `AppSpacing.cardShadow`, `Material` transparente para splashes internos e suporte a `onTap`.
- **`PilarChip`**: Renderiza ícone mapeado + nome do pilar usando `corHex` e `corFundoHex`.
- **`PriorityBadge`**: Renderiza `Prioridade` (`#FEE2E2`/`#DC2626`), `Rápido` (`#FEF3C7`/`#B45309` — contraste WCAG AA) e `Postergável` (`#F1F5F9`/`#475569`).
- **`PrimaryGradientButton`**: Botão com gradiente `#6366F1 -> #7C3AED`, altura mínima acessível de `48dp` (`RNF04`) e suporte a `isLoading` e `isDisabled`.
- **`EmptyStateView`**: Ilustração em círculo suave, título editorial, descrição e botão de ação opcional.

---

## 6. Rede, Autenticação (`ADR-005`), Tratamento de Erros e Roteamento Responsivo

- **`EnvConfig` (`core/config/env_config.dart`)**: Lê `API_BASE_URL` via `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api/v1')`, `GOOGLE_CLIENT_ID`, `APPLE_CLIENT_ID`, `OAUTH_DEV_MOCK_ENABLED` (default `true`) e define timeouts de `5s`.
- **`SecureTokenStorage` (`core/storage/secure_token_storage.dart`)**: Persiste `accessToken`, `refreshToken` e snapshot JSON de `UsuarioModel` usando `FlutterSecureStorage` (`RNF05`), com implementação `InMemoryTokenStorage` para testes determinísticos.
- **`AuthInterceptor` & `AuthSessionEventBus` (`core/network/auth_interceptor.dart`)**:
  - Anexa `Authorization: Bearer <accessToken>` em todas as requisições autenticadas.
  - Ao receber `HTTP 401` em rota protegida, aciona `POST /auth/refresh`, salva o novo par de tokens rotacionado e reexecuta a requisição original de forma transparente.
  - Se o refresh falhar, limpa o `SecureTokenStorage` e notifica o `AuthSessionEventBus`, deslogando o `AuthNotifier` sem criar dependência circular entre providers.
- **`ApiExceptionMapper` (`core/network/api_exception_mapper.dart`)**: Traduz o envelope de erro do `GlobalHttpExceptionFilter` do NestJS para `AppFailure`:
  - `MAX_ACTIVE_PILLARS_EXCEEDED` (`HTTP 422`) $\rightarrow$ `MaxActivePillarsExceededFailure` (`RN01`: `"Selecione apenas 3 pilares por mês!"`).
  - `MENTAL_FATIGUE_LIMIT_EXCEEDED` (`HTTP 422`) $\rightarrow$ `MentalFatigueBlockedFailure` (`RN02`: `"Limite de horas atingido, reagende a atividade."`).
  - `VALIDATION_ERROR`, `INVALID_CREDENTIALS`, `TOKEN_EXPIRED_OR_INVALID`, `EMAIL_ALREADY_REGISTERED`, `RESET_TOKEN_INVALID`, `RESOURCE_NOT_FOUND` e falhas de rede/timeout (`NetworkFailure`).
- **`GoRouter` Auth Guard & `ResponsiveShellScaffold` (`core/router/`)**:
  - `evaluateAuthRedirect` redireciona usuários não autenticados para `/login` (permitindo `/register`, `/forgot-password`, `/reset-password`) e redireciona usuários autenticados em `/login` ou `/register` para `/painel`.
  - `StatefulShellRoute.indexedStack` preservando o estado das 4 abas: `Painel` (`/painel`), `Relatórios` (`/relatorios`), `Alertas` (`/alertas`) e `Config.` (`/config` $\rightarrow$ `ConfigScreen`).

---

## 7. Como Executar e Testar

```powershell
# A partir de apps/ads-tg-mobile:
C:\src\flutter\bin\flutter.bat pub get

# Análise estática rigorosa (deve retornar 0 issues)
C:\src\flutter\bin\flutter.bat analyze

# Executar toda a suíte de testes unitários e de widgets (offline-safe)
C:\src\flutter\bin\flutter.bat test

# Executar aplicação apontando para a API local
C:\src\flutter\bin\flutter.bat run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

---

## 8. Decisões Técnicas Locais e Changelog por Tarefa

### Decisões Locais
1. **Fallback Tipográfico Offline para Testes (`AppTypography`)**: Quando `GoogleFonts.config.allowRuntimeFetching = false` é definido no `setUpAll` dos testes, `AppTypography` retorna o `TextStyle` com `fontFamily` sem acionar o carregador de rede/AssetManifest do `google_fonts`, garantindo que `flutter test` execute 100% offline sem erros de fonte ausente.
2. **Desacoplamento entre `DioClient` e `AuthNotifier` via `AuthSessionEventBus`**: Evita dependência circular no Riverpod 3 (`DioClient -> AuthInterceptor -> AuthSessionEventBus <- AuthNotifier`).
3. **Suporte Transparente a OAuth Mock de Desenvolvimento (`ADR-005`)**: Quando `EnvConfig.oauthDevMockEnabled` está ativo ou `GOOGLE_CLIENT_ID`/`APPLE_CLIENT_ID` ainda não foram injetados via `--dart-define`, os botões sociais enviam `mock-google-token:<email>` / `mock-apple-token:<email>` para que o login social funcione imediatamente contra a API NestJS local.

### Changelog de Tarefas
- **`E01-T03` (`feature/epico-01-tarefa-03-flutter-design-tokens`)**: Criação do projeto Flutter multiplataforma (`android minSdk=26`, `ios 14.0`, `web`), instalação das dependências enxutas do MVP, implementação de `EnvConfig`, `AppFailure`, `Result<T>`, `AppColors`, `AppSpacing`, `AppTypography` e `AppTheme`.
- **`E01-T04` (`feature/epico-01-tarefa-04-atomos-design-system`)**: Implementação dos átomos compartilhados (`AppCard`, `PilarChip`, `PriorityBadge`, `PrimaryGradientButton`, `EmptyStateView`) e suíte de testes de widget em `test/core/widgets/design_system_widgets_test.dart`.
- **`E01-T05` (`feature/epico-01-tarefa-05-dio-shell-responsivo`)**: Implementação de `DioClient`, `ApiExceptionMapper`, `ResponsiveShellScaffold` (`NavigationBar` `< 768px` e `NavigationRail` `>= 768px`), `GoRouter` com `StatefulShellRoute.indexedStack` para as 4 abas e testes automatizados.
- **`E02-T03` (`feature/epico-02-tarefa-03-auth-storage-interceptor-notifier`)**: Implementação de `SecureTokenStorage` (`FlutterSecureStorage` + `InMemoryTokenStorage`), `AuthInterceptor` com renovação automática de token em `401`, `UsuarioEntity` com cálculos `RN02` (`minutosUteisDiarios`, `limiteFadigaMinutos`), `AuthRepository` / `AuthRepositoryImpl`, `AuthNotifier` e Auth Guard reativo no `GoRouter`.
- **`E02-T04` (`feature/epico-02-tarefa-04-telas-login-cadastro-recuperacao`)**: Implementação de `LoginScreen` (`/login`), `OAuthButtonsRow` (**Continuar com Google** e **Continuar com Apple**), `RegisterScreen` (`/register`) com `PasswordStrengthChecklist` em tempo real (`RF02`), seletor inicial de sono e consentimento LGPD (`RNF07`), `ForgotPasswordScreen` (`/forgot-password`) e `ResetPasswordScreen` (`/reset-password`).
- **`E02-T05` (`feature/epico-02-tarefa-05-tela-config-sono-lgpd`)**: Implementação da `ConfigScreen` na 4ª aba (`/config`) com edição de `nomeCompleto`, `SleepHoursSelectorCard` (`4h` a `12h` exibindo em tempo real `"Capacidade útil diária: {24 - sono}h ({minutos} min) • Limite saudável (80%): {limite} min"` — `RF05` / `RN02`), logout e exclusão definitiva da conta em cascata via `DeleteAccountDialog` (`DELETE /api/v1/usuarios/me` — `RNF07`).
