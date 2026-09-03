# 🐍 fasting-tracker-app

Aplicativo de controle de jejum intermitente e registro calórico diário, desenvolvido em Flutter com foco em arquitetura limpa, resiliência de estado e experiência offline-first.

---

## 📐 Arquitetura e Estrutura de Pastas

O projeto adota a abordagem **Feature-First (Clean Architecture adaptada)**, separando responsabilidades por contexto de negócio para facilitar manutenção e escalabilidade.

- **`lib/core/`**: Temas visuais (Design System), constantes globais, rotas e utilitários puros.
- **`lib/models/`**: Entidades de domínio com métodos de serialização nativos (`toMap` e `fromMap`).
- **`lib/services/`**: Abstração de serviços de infraestrutura (Hive, notificações locais e pulsos do timer).
- **`lib/repositories/`**: Camada de dados que unifica o acesso aos serviços e oculta a origem da persistência.
- **`lib/features/`**: Módulos divididos por funcionalidade, contendo os **Providers (Riverpod)** e a **UI (Screens & Widgets)**.

---

## 🛠 Decisões Técnicas

### 1. Gerenciamento de Estado: Flutter Riverpod
- **Motivação:** Proporciona um controle de estado reativo, previsível e sem dependência do contexto da árvore de widgets.
- **Testabilidade:** Permite injetar e substituir dependências (Mocks) em testes unitários com facilidade.

### 2. Lógica do Timer e Resiliência em Background (Core Feature)
- **Cálculo Baseado em Timestamps:** A contagem do tempo **não depende** de um timer rodando continuamente em memória (`Timer.periodic`). O aplicativo armazena a hora exata do início (`startedAt`) e a previsão de término (`plannedEndAt`).
- **Recuperação de Estado:** Caso o app seja encerrado pelo sistema operacional ou o dispositivo seja reiniciado, o tempo decorrido e restante é recalculado dinamicamente comparando `DateTime.now()` com o `startedAt` do banco local.
- **Notificações Agendadas:** No momento em que o jejum inicia, a notificação de término é agendada no SO via `flutter_local_notifications`. O alerta dispara no horário previsto mesmo com o aplicativo totalmente fechado.

### 3. Persistência Local: Hive sem Build Runner
- **Desempenho:** Armazenamento em chave-valor de altíssima velocidade.
- **Trade-off Consciente:** Mapeamento feito manualmente via `Map<String, dynamic>` para evitar o uso de geradores de código (`build_runner` e `hive_generator`). Essa escolha reduziu o tempo de compilação, eliminou conflitos de versão no SDK do Dart e simplificou o setup inicial.

---

## ⚖️ Trade-offs e Limitações de Escopo

- **Notificações Locais vs Firebase FCM:** Optou-se por notificações nativas locais para garantir o funcionamento 100% offline do MVP e evitar dependências de infraestrutura em nuvem.
- **Autenticação Local:** O fluxo de autenticação foi mantido localmente para priorizar a qualidade da entrega do Timer e do Registro de Refeições no prazo estipulado.

---

## 🚀 O que seria melhorado com mais tempo

1. **Testes de UI (Widget Tests):** Ampliar a cobertura além dos testes unitários para validar fluxos visuais completos.
2. **CI/CD Pipeline:** Configuração de GitHub Actions para automação de testes, lint e geração de compilação (APK/AAB) a cada *push*.
3. **Observabilidade:** Integração com Firebase Crashlytics e Analytics para rastreamento de erros e métricas de uso em produção.