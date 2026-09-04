# 🐍 fasting-tracker-app

Aplicativo de controle de jejum intermitente e registro calórico diário, desenvolvido em Flutter com foco em arquitetura limpa, resiliência de estado e experiência offline-first.

---

## ✨ Funcionalidades (MVP Atendido)

- **Autenticação:** Sessão com persistência local.
- **Protocolos de Jejum:** Seleção de modelos pré-definidos (12:12, 16:8, 18:6) e criação de protocolos customizados.
- **Timer Resiliente (Core):** Cálculo preciso com suporte a background/offline, permitindo pausar e encerrar o jejum sem perda de dados.
- **Notificações:** Alertas agendados nativamente para o início e o término previsto do jejum.
- **Registro de Refeições:** Inserção, edição e exclusão de refeições com cálculo automático.
- **Dashboard Diário:** Acompanhamento do tempo total de jejum, calorias consumidas e status da meta diária.
- **Histórico e Gráficos:** Visualização de dias anteriores e acompanhamento de evolução semanal.

---

## 📱 Download e Teste

- **Download do APK:** [Baixar APK v1.0.0]

---

## 🚀 Como rodar o projeto

Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (versão 3.0 ou superior).

1. Clone o repositório:
   ```bash
   git clone [COLOQUE_SEU_LINK_DO_GITHUB_AQUI]
   ```
2. Acesse a pasta do projeto:
   ```bash
   cd fasting-tracker-app
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Execute o aplicativo:
   ```bash
   flutter run
   ```

---

## 📐 Arquitetura e Estrutura de Pastas

O projeto adota a abordagem **Feature-First (Clean Architecture adaptada)**, separando responsabilidades por contexto de negócio para facilitar manutenção e escalabilidade.

- **`lib/core/`**: Temas visuais (Design System), constantes globais, rotas e utilitários puros.
- **`lib/models/`**: Entidades de domínio com métodos de serialização nativos (`toMap` e `fromMap`).
- **`lib/services/`**: Abstração de serviços de infraestrutura (Hive, notificações locais e pulsos do timer).
- **`lib/features/`**: Módulos divididos por funcionalidade, contendo a camada de dados (**Repositories**), lógica de estado (**Providers**) e a **UI (Screens & Widgets)**.

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

## 📦 Stack e Bibliotecas Utilizadas

- **Linguagem/Framework:** Dart & Flutter (Material 3)
- **Gerenciamento de Estado e Injeção de Dependências:** `flutter_riverpod`
- **Navegação (Deep Linking e Bottom Navigation):** `go_router`
- **Persistência de Dados Local (NoSQL offline-first):** `hive` e `hive_flutter`
- **Gráficos e Métricas:** `fl_chart`
- **Notificações Locais e Agendamento:** `flutter_local_notifications` e `timezone`
- **Utilitários de Data/Hora:** `intl`

---

## ⚖️ Trade-offs e Limitações de Escopo

- **Notificações Locais vs Firebase FCM:** Optou-se por notificações nativas locais para garantir o funcionamento 100% offline do MVP e evitar dependências de infraestrutura em nuvem.
- **Autenticação Local:** O fluxo de autenticação foi mantido localmente para priorizar a qualidade da entrega do Timer e do Registro de Refeições no prazo estipulado.

---

## 🚀 O que seria melhorado com mais tempo

1. **Testes de UI (Widget Tests):** Ampliar a cobertura além dos testes unitários para validar fluxos visuais completos.
2. **CI/CD Pipeline:** Configuração de GitHub Actions para automação de testes, lint e geração de compilação (APK/AAB) a cada *push*.
3. **Observabilidade:** Integração com Firebase Crashlytics e Analytics para rastreamento de erros e métricas de uso em produção.

---

## ⏱️ Tempo Gasto no Desafio

[Preencha aqui quanto tempo você levou, ex: 15 horas divididas em 4 dias]
