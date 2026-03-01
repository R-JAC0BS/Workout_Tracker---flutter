# Progressão Inteligente - Requirements

## 1. Visão Geral

Transformar o GymTracker de um simples rastreador de treinos em uma ferramenta inteligente que sugere progressões, detecta estagnação e calcula métricas avançadas automaticamente.

## 2. Problema Atual

O aplicativo atualmente apenas registra dados (peso, reps, séries) mas não oferece:
- Sugestões de carga para próxima sessão
- Detecção de estagnação/platô
- Identificação de necessidade de deload
- Cálculo automático de 1RM
- Medição de progresso relativo

## 3. User Stories

### US-1: Cálculo Automático de 1RM
**Como** usuário do app  
**Quero** ver meu 1RM estimado calculado automaticamente  
**Para** entender minha força máxima sem precisar testar

**Critérios de Aceitação:**
- Sistema calcula 1RM usando fórmula de Epley: 1RM = peso × (1 + reps/30)
- Sistema calcula 1RM usando fórmula de Brzycki: 1RM = peso × (36 / (37 - reps))
- Exibe ambas as estimativas na tela de estatísticas do exercício
- Atualiza automaticamente quando novos PRs são registrados
- Mostra histórico de evolução do 1RM ao longo do tempo

### US-2: Sugestão Automática de Carga
**Como** usuário do app  
**Quero** receber sugestões de carga para minha próxima série  
**Para** progredir de forma consistente sem adivinhar

**Critérios de Aceitação:**
- Sistema analisa últimas 3 sessões do exercício
- Sugere aumento de 2.5kg se completou todas as reps nas últimas 2 sessões
- Sugere manter carga se houve falha em alguma série
- Sugere redução de 10% se houve falha em 2 sessões consecutivas
- Exibe sugestão ao abrir tela de séries
- Permite aceitar ou ignorar sugestão

### US-3: Detecção de Platô
**Como** usuário do app  
**Quero** ser alertado quando estiver estagnado  
**Para** ajustar minha estratégia de treino

**Critérios de Aceitação:**
- Sistema detecta platô quando não há progresso em 3 sessões consecutivas
- Progresso = aumento de peso OU aumento de reps OU aumento de volume total
- Exibe alerta visual na tela do exercício
- Sugere estratégias: deload, mudança de rep range, ou mudança de exercício
- Permite marcar platô como "resolvido" manualmente

### US-4: Detecção de Necessidade de Deload
**Como** usuário do app  
**Quero** ser alertado quando precisar de deload  
**Para** evitar overtraining e lesões

**Critérios de Aceitação:**
- Sistema detecta necessidade de deload quando:
  - Volume semanal aumentou >20% em 2 semanas consecutivas
  - Houve queda de performance em 3+ exercícios na mesma semana
  - Usuário não teve semana de deload nos últimos 45 dias
- Exibe alerta na tela principal
- Sugere redução de 40-50% do volume por 1 semana
- Permite agendar deload para semana específica

### US-5: Progresso Relativo
**Como** usuário do app  
**Quero** ver meu progresso em percentual  
**Para** entender minha evolução de forma clara

**Critérios de Aceitação:**
- Calcula % de evolução de 1RM em períodos: 4, 8, 12 semanas
- Calcula % de evolução de volume total por período
- Exibe gráfico de evolução percentual
- Compara com média esperada (iniciante: 5-10%/mês, intermediário: 2-5%/mês)
- Mostra ranking de exercícios com maior/menor progresso

## 4. Requisitos Técnicos

### RT-1: Banco de Dados
- Adicionar tabela `progressao_historico` com campos:
  - id, exercicio_nome, data, one_rm_epley, one_rm_brzycki, volume_total
- Adicionar tabela `alertas` com campos:
  - id, tipo (platô/deload), exercicio_nome, data_deteccao, status, sugestao
- Adicionar tabela `sugestoes_carga` com campos:
  - id, exercicio_nome, serie_id, carga_sugerida, motivo, aceita

### RT-2: Serviços
- Criar `ProgressaoService` com métodos:
  - `calcular1RM(peso, reps)` → retorna {epley, brzycki}
  - `sugerirCarga(exercicioNome)` → retorna carga sugerida
  - `detectarPlato(exercicioNome)` → retorna boolean + detalhes
  - `detectarNecessidadeDeload()` → retorna boolean + motivo
  - `calcularProgressoRelativo(exercicioNome, periodo)` → retorna %

### RT-3: UI/UX
- Badge de alerta na tela de exercícios quando há platô
- Card de sugestão de carga na tela de séries
- Banner de deload na tela principal quando necessário
- Gráfico de evolução de 1RM na tela de estatísticas
- Seção de progresso relativo na tela de estatísticas

## 5. Métricas de Sucesso

- 80% dos usuários aceitam sugestões de carga
- Redução de 30% em platôs prolongados (>6 semanas)
- Aumento de 25% no engajamento com tela de estatísticas
- 90% de precisão na detecção de necessidade de deload

## 6. Dependências

- Nenhuma dependência externa
- Requer dados históricos de pelo menos 3 sessões para funcionar

## 7. Riscos e Mitigações

**Risco:** Sugestões incorretas podem desmotivar usuários  
**Mitigação:** Permitir feedback e ajuste manual, começar conservador

**Risco:** Detecção de platô pode ser falso positivo  
**Mitigação:** Considerar múltiplos fatores, não apenas peso absoluto

## 8. Fases de Implementação

### Fase 1 (MVP)
- Cálculo de 1RM
- Sugestão básica de carga

### Fase 2
- Detecção de platô
- Progresso relativo

### Fase 3
- Detecção de deload
- Alertas e notificações
