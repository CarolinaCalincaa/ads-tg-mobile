# ads-tg-mobile — Aplicativo Multiplataforma Flutter (`apps/ads-tg-mobile`)

Cliente multiplataforma (**Android 8.0+**, **iOS 14.0+** e **Web SPA**) do **Sistema Integrado de Gestão de Produtividade Pessoal** (TCC — FATEC Campinas, 2026), construído com **Flutter 3**, **Riverpod**, **GoRouter**, **Dio** e o Design System **"Calma Cognitiva"**.

## Documentação de Arquitetura

Consulte [**`ARCHITECTURE.md`**](./ARCHITECTURE.md) para detalhes completos sobre:
- Estratégia evolutiva **MVP Online-First $\rightarrow$ Pós-MVP Offline-First (Épico 09)**;
- Stack e versões instaladas;
- Estrutura de pastas Clean Architecture (`core/`, `features/`, `shared/`);
- Tokens e átomos visuais do Design System **"Calma Cognitiva"**;
- Camada de rede (`DioClient`, `ApiExceptionMapper`, `Result<T>` / `AppFailure`);
- Roteamento declarativo e `ResponsiveShellScaffold` de 4 abas (`Painel`, `Relatórios`, `Alertas`, `Config.`).

## Comandos Rápidos

```powershell
# Instalar dependências
C:\src\flutter\bin\flutter.bat pub get

# Validar linter e tipos (0 issues)
C:\src\flutter\bin\flutter.bat analyze

# Executar suíte de testes unitários e de widgets
C:\src\flutter\bin\flutter.bat test

# Rodar no Chrome apontando para a API local
C:\src\flutter\bin\flutter.bat run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```
