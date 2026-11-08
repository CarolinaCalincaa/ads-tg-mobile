# Arquitetura do Front-end Flutter (`apps/mobile`)

> **Arquivo vivo de arquitetura (`DEC-004`)**. Documenta a stack, estrutura de diretórios, camadas Clean Architecture, Design System "Calma Cognitiva", camada de rede, navegação declarativa e decisões locais do cliente multiplataforma (**Android, iOS e Web SPA**) do **Sistema Integrado de Gestão de Produtividade Pessoal** (TCC — FATEC Campinas, 2026).

---

## 1. Visão Geral e Estratégia Arquitetural

O aplicativo `apps/mobile` (`produtividade_tcc`) adota **Clean Architecture Feature-First** combinada com a evolução planejada em 2 fases (`ADR-001` e `ADR-002`):

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
apps/mobile/
├── pubspec.yaml
├── analysis_options.yaml                 # strict-casts, strict-raw-types e regras flutter_lints
├── lib/
│   ├── main.dart                         # Entrypoint com ProviderScope
│   ├── app.dart                          # ProdutividadeTccApp (MaterialApp.router + AppTheme)
│   ├── core/
│   │   ├── config/
│   │   │   └── env_config.dart           # EnvConfig.apiBaseUrl (--dart-define=API_BASE_URL)
│   │   ├── error/
│   │   │   ├── app_failure.dart          # Hierarquia selada AppFailure (RN01, RN02, Auth, Rede)
│   │   │   └── result.dart               # Sealed class Result<T> (Success<T> | FailureResult<T>)
│   │   ├── network/
│   │   │   ├── dio_client.dart           # DioClient (timeouts 5s) + providers Riverpod
│   │   │   └── api_exception_mapper.dart # Tradutor do envelope de erro JSON do NestJS
│   │   ├── router/
│   │   │   ├── app_router.dart           # GoRouter + StatefulShellRoute.indexedStack (4 abas)
│   │   │   └── responsive_shell_scaffold.dart # NavigationBar (<768px) vs NavigationRail (>=768px)
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
│   ├── features/                         # Módulos de negócio (auth, pilares, painel_dia, habitos, alertas, etc.)
│   │   └── <feature>/
│   │       ├── domain/                   # entities/, repositories/ (interfaces abstratas), usecases/
│   │       ├── data/                     # datasources/ (Dio), models/ (fromJson/toJson), repositories/
│   │       └── presentation/             # providers/ (Riverpod Notifiers), screens/, widgets/
│   └── shared/                           # Utilitários e componentes transversais entre features
└── test/
    ├── widget_test.dart
    └── core/
        ├── network/
        │   └── api_exception_mapper_test.dart
        ├── router/
        │   └── responsive_shell_scaffold_test.dart
        └── widgets/
            └── design_system_widgets_test.dart
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
- **`AppCard`**: Container com `borderRadius: 20px`, borda `#E2E8F0` (`1px`), `AppSpacing.cardShadow` e suporte a `onTap`.
- **`PilarChip`**: Renderiza ícone mapeado + nome do pilar usando `corHex` e `corFundoHex`.
- **`PriorityBadge`**: Renderiza `Prioridade` (`#FEE2E2`/`#DC2626`), `Rápido` (`#FEF3C7`/`#B45309` — contraste WCAG AA) e `Postergável` (`#F1F5F9`/`#475569`).
- **`PrimaryGradientButton`**: Botão com gradiente `#6366F1 -> #7C3AED`, altura mínima acessível de `48dp` (`RNF04`) e suporte a `isLoading` e `isDisabled`.
- **`EmptyStateView`**: Ilustração em círculo suave, título editorial, descrição e botão de ação opcional.

---

## 6. Rede, Tratamento de Erros e Roteamento Responsivo

- **`EnvConfig` (`core/config/env_config.dart`)**: Lê `API_BASE_URL` via `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api/v1')` e define timeouts de `5s`.
- **`DioClient` (`core/network/dio_client.dart`)**: Configura `Dio` com `baseUrl`, `connectTimeout: 5s`, `receiveTimeout: 5s` e headers JSON UTF-8, exposto via `dioClientProvider` e `dioProvider`.
- **`ApiExceptionMapper` (`core/network/api_exception_mapper.dart`)**: Traduz o envelope de erro do `GlobalHttpExceptionFilter` do NestJS para `AppFailure`:
  - `MAX_ACTIVE_PILLARS_EXCEEDED` (`HTTP 422`) $\rightarrow$ `MaxActivePillarsExceededFailure` (`RN01`: `"Selecione apenas 3 pilares por mês!"`).
  - `MENTAL_FATIGUE_LIMIT_EXCEEDED` (`HTTP 422`) $\rightarrow$ `MentalFatigueBlockedFailure` (`RN02`: `"Limite de horas atingido, reagende a atividade."`, expondo `dataAgendamento`, `minutosUteis`, `minutosComprometidos` e `percentualOcupacao`).
  - `VALIDATION_ERROR`, `INVALID_CREDENTIALS`, `TOKEN_EXPIRED_OR_INVALID`, `EMAIL_ALREADY_REGISTERED`, `RESET_TOKEN_INVALID`, `RESOURCE_NOT_FOUND` e falhas de rede/timeout (`NetworkFailure`).
- **`ResponsiveShellScaffold` & `GoRouter` (`core/router/`)**:
  - `StatefulShellRoute.indexedStack` preservando o estado das 4 abas: `Painel` (`/painel`), `Relatórios` (`/relatorios`), `Alertas` (`/alertas`) e `Config.` (`/config`).
  - Adaptação automática por `LayoutBuilder`: `< 768px` exibe `NavigationBar` inferior; `>= 768px` exibe `NavigationRail` lateral (`extended: true` em `>= 1100px`) (`RNF03`).

---

## 7. Como Executar e Testar

```powershell
# A partir de apps/mobile:
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
2. **Compatibilidade com Riverpod 3.x e GoRouter 18.x**: O SDK Dart `3.13.7` / Flutter `3.47.9` instalado resolveu `flutter_riverpod: ^3.5.0` e `go_router: ^18.1.3`, mantendo todas as APIs (`Provider`, `ConsumerWidget`, `ProviderScope`, `StatefulShellRoute.indexedStack`) enxutas e atualizadas.

### Changelog de Tarefas
- **`E01-T03` (`feature/epico-01-tarefa-03-flutter-design-tokens`)**: Criação do projeto Flutter multiplataforma (`android minSdk=26`, `ios 14.0`, `web`), instalação das dependências enxutas do MVP, implementação de `EnvConfig`, `AppFailure`, `Result<T>`, `AppColors`, `AppSpacing`, `AppTypography` e `AppTheme`.
- **`E01-T04` (`feature/epico-01-tarefa-04-atomos-design-system`)**: Implementação dos átomos compartilhados (`AppCard`, `PilarChip`, `PriorityBadge`, `PrimaryGradientButton`, `EmptyStateView`) e suíte de testes de widget em `test/core/widgets/design_system_widgets_test.dart`.
- **`E01-T05` (`feature/epico-01-tarefa-05-dio-shell-responsivo`)**: Implementação de `DioClient`, `ApiExceptionMapper`, `ResponsiveShellScaffold` (`NavigationBar` `< 768px` e `NavigationRail` `>= 768px`), `GoRouter` com `StatefulShellRoute.indexedStack` para as 4 abas e testes automatizados em `test/core/network/api_exception_mapper_test.dart` e `test/core/router/responsive_shell_scaffold_test.dart`.
