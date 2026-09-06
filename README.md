# 🐍 fasting-tracker-app

Aplicativo de controle de jejum intermitente e registro calórico diário, desenvolvido em Flutter com foco em arquitetura limpa, resiliência de estado e experiência offline-first.

---

## ✨ Funcionalidades (MVP Atendido)

- **Autenticação Local e Sessão Persistente**
  - Login simples que salva o estado localmente, garantindo que o usuário não precise inserir credenciais a cada abertura do app.

- **Gestão de Protocolos de Jejum**
  - **Pré-definidos:** Acesso rápido aos modelos mais utilizados (12:12, 16:8 e 18:6).
  - **Customizado:** Flexibilidade total para o usuário definir suas próprias janelas de restrição alimentar.

- **Timer Resiliente (Core Feature)**
  - Interface completa com ações para iniciar, pausar e encerrar o jejum, exibindo o tempo decorrido e o tempo restante.
  - **À prova de falhas:** Continua operando em background. Graças à lógica de Timestamps, se o app for "morto" pelo sistema operacional, nenhum dado de tempo é perdido.

- **Notificações Inteligentes (Offline)**
  - Alertas locais agendados nativamente informam o usuário exatamente no momento em que o jejum inicia e quando a meta de término é atingida. Também dispara uma notificação imediata quando o jejum é encerrado manualmente antes do horário planejado.

- **Controle de Refeições (Diário Alimentar)**
  - Cadastro prático de refeições informando nome e calorias, com captura automática do horário (que também pode ser ajustado).
  - Gestão completa permitindo a edição ou exclusão ágil de registros incorretos.

- **Cálculos Diários e Dashboard**
  - Resumo imediato mostrando o total de calorias ingeridas no dia, o tempo consolidado de jejum e o status visual (dentro ou fora da meta).

- **Histórico e Evolução Gráfica**
  - Lista detalhada para conferência de dias anteriores e um gráfico semanal em formato limpo, ilustrando o progresso e as tendências do usuário.

---

## 📱 Download e Teste

- **Download do APK:** [Baixar APK v1.0.0]

---

## 🚀 Como rodar o projeto

Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (versão 3.0 ou superior).

1. Clone o repositório:
```bash
git clone [https://github.com/Naita1/fasting-tracker-app.git](https://github.com/Naita1/fasting-tracker-app.git)
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

### 4. Pausar o Jejum: Implementado por Fidelidade ao Requisito
- O requisito do desafio cita explicitamente "Pausar/encerrar" como controle do timer.
- Do ponto de vista fisiológico, um jejum intermitente continua ocorrendo independente do app estar pausado — diferente de um cronômetro de treino. Apps de referência do mercado (Zero, LIFE Fasting Tracker) não oferecem essa função por esse motivo.
- Optei por implementar mesmo assim, tratando-a como controle de UX (o app "congela" a exibição do progresso), não como uma pausa biológica real. O tempo pausado é rastreado via `accumulatedPausedDuration` e descontado do cálculo de progresso ao retomar, preservando a precisão do tempo restante. A notificação de conclusão agendada é cancelada ao pausar e reagendada ao retomar, considerando o novo horário efetivo de término.

---

## 📦 Stack e Bibliotecas Utilizadas

- **Linguagem/Framework:** Dart & Flutter (Material 3)
- **Gerenciamento de Estado e Injeção de Dependências:** `flutter_riverpod`
- **Navegação (Deep Linking e Bottom Navigation):** `go_router`
- **Persistência de Dados Local (NoSQL offline-first):** `hive` e `hive_flutter`
- **Gráficos e Métricas:** `fl_chart`
- **Notificações Locais e Agendamento:** `flutter_local_notifications` e `timezone`
- **Utilitários de Data/Hora:** `intl`
- **UI e Animações:** `google_fonts`, `flutter_animate`

---

## ⚖️ Trade-offs e Limitações de Escopo

- **Notificações Locais vs Firebase FCM:** Optou-se por notificações nativas locais para garantir o funcionamento 100% offline do MVP e evitar dependências de infraestrutura em nuvem.
- **Autenticação Local:** O fluxo de autenticação foi mantido localmente para priorizar a qualidade da entrega do Timer e do Registro de Refeições no prazo estipulado. O login valida apenas formato de e-mail e senha com mínimo de 6 caracteres — não há verificação contra um backend real.
- **Meta de jejum diária:** não há tela dedicada de configuração de meta. A meta do dia é derivada automaticamente das horas do protocolo em uso (sessão ativa/pausada, ou último protocolo concluído no dia), com fallback de 16h caso nenhuma sessão exista.
- **Métrica "Jejum Hoje" não divide sessões que atravessam a meia-noite:** o tempo de jejum do dia é calculado com base no dia em que a sessão foi *iniciada*. Um jejum que começa às 22h e termina às 14h do dia seguinte é contabilizado inteiramente no dia de início, não distribuído proporcionalmente entre os dois dias. Uma implementação mais precisa dividiria o tempo pelo dia civil correspondente.
- **Sem redirect global de rotas protegidas:** a sessão é verificada na tela de login, mas não há um `redirect` global no `GoRouter` impedindo o acesso direto a rotas internas (ex: `/fasting`) sem autenticação prévia via deep link.

---

## 🧪 Testes Automatizados

O projeto conta com uma suíte abrangente de **148 testes unitários** organizados em `test/`, cobrindo as regras de negócio do Timer, Mapeamentos de Modelos (Hive), Repositórios e Notifiers:

- `test/models/`: Validação de contratos, limites de progresso (0-100%) e calculadoras de tempo.
- `test/providers/`: Regras do estado de jejum, histórico e gerenciamento de sessões.
- `test/repositories/`: Isolamento e integridade dos dados locais.
- `test/utils/`: Formatação e utilitários de data/hora.

Para executar toda a suíte de testes:

```bash
flutter test

---

## 🚀 O que seria melhorado com mais tempo

1. **Testes de UI (Widget Tests):** Ampliar a cobertura além dos testes unitários para validar fluxos visuais completos.
2. **CI/CD Pipeline:** Configuração de GitHub Actions para automação de testes, lint e geração de compilação (APK/AAB) a cada *push*.
3. **Observabilidade:** Integração com Firebase Crashlytics e Analytics para rastreamento de erros e métricas de uso em produção.
4. **Redirect global de autenticação:** Proteger todas as rotas internas no `GoRouter` contra acesso sem sessão válida, não apenas a tela de login.
5. **Distribuição proporcional de jejum entre dias:** Ajustar o cálculo de "Jejum Hoje" para dividir corretamente sessões que atravessam a meia-noite entre os dois dias civis correspondentes.
6. **Autenticação real:** Substituir a validação local simplificada por um backend de autenticação real (ex: Firebase Auth), incluindo recuperação de senha.

---

## ⏱️ Tempo Gasto no Desafio

O desenvolvimento levou 4 dias