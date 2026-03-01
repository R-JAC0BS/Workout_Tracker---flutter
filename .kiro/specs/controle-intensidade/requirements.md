# Controle de Intensidade Real - Requirements

## 1. Visão Geral

Adicionar métricas de intensidade percebida e tempo para transformar o rastreamento de volume em análise completa de intensidade de treino.

## 2. Problema Atual

O aplicativo mede apenas:
- Peso
- Repetições
- Séries

Mas não mede:
- RPE (Rate of Perceived Exertion)
- RIR (Reps in Reserve)
- Tempo de descanso real
- Tempo sob tensão
- Densidade do treino

## 3. User Stories

### US-1: Registro de RPE por Série
**Como** usuário do app  
**Quero** registrar o RPE de cada série  
**Para** controlar a intensidade real do meu treino

**Critérios de Aceitação:**
- Campo opcional de RPE (escala 1-10) ao completar série
- Interface rápida: slider ou botões numéricos
- Exibe RPE médio do exercício na sessão
- Histórico de RPE ao longo do tempo
- Gráfico de evolução de RPE vs Volume
- Alerta quando RPE está consistentemente >9 (risco de overtraining)

### US-2: Registro de RIR por Série
**Como** usuário do app  
**Quero** registrar quantas reps deixei na reserva  
**Para** controlar proximidade da falha

**Critérios de Aceitação:**
- Campo opcional de RIR (0-5+) ao completar série
- Conversão automática RPE ↔ RIR (RPE 10 = RIR 0, RPE 9 = RIR 1, etc)
- Exibe RIR médio por exercício
- Sugere RIR ideal baseado em objetivo (hipertrofia: 1-3, força: 0-1)
- Histórico de RIR ao longo do tempo

### US-3: Cronômetro de Descanso
**Como** usuário do app  
**Quero** cronometrar meu descanso entre séries  
**Para** manter consistência e controlar densidade

**Critérios de Aceitação:**
- Cronômetro inicia automaticamente ao completar série
- Notificação sonora/vibração quando tempo alvo é atingido
- Permite configurar tempo alvo por exercício (30s-5min)
- Registra tempo real de descanso no banco
- Exibe média de descanso por exercício
- Gráfico de descanso real vs descanso alvo

### US-4: Tempo Sob Tensão (TUT)
**Como** usuário do app  
**Quero** registrar o tempo sob tensão de cada série  
**Para** controlar a qualidade da execução

**Critérios de Aceitação:**
- Campo opcional para registrar TUT em segundos
- Sugestão de TUT baseado em reps (ex: 10 reps × 4s = 40s)
- Calcula TUT médio por série
- Exibe TUT total por exercício e por treino
- Alerta quando TUT está muito baixo (execução rápida demais)
- Histórico de TUT ao longo do tempo

### US-5: Densidade do Treino
**Como** usuário do app  
**Quero** ver a densidade do meu treino  
**Para** entender a eficiência da sessão

**Critérios de Aceitação:**
- Calcula densidade: Volume Total (kg) / Tempo Total (min)
- Exibe densidade na tela de resumo do treino
- Compara densidade entre sessões
- Gráfico de evolução de densidade ao longo do tempo
- Sugere ajustes para melhorar densidade (reduzir descanso, aumentar volume)

### US-6: Análise de Intensidade Combinada
**Como** usuário do app  
**Quero** ver análise combinada de todas métricas de intensidade  
**Para** ter visão holística do treino

**Critérios de Aceitação:**
- Dashboard de intensidade com:
  - Volume total
  - RPE médio
  - Densidade
  - TUT total
  - Tempo de descanso médio
- Score de intensidade (0-100) baseado em todas métricas
- Comparação com sessões anteriores
- Recomendações baseadas em intensidade (aumentar/manter/reduzir)

## 4. Requisitos Técnicos

### RT-1: Banco de Dados
- Adicionar campos à tabela `series`:
  - rpe (INTEGER, 1-10, nullable)
  - rir (INTEGER, 0-5, nullable)
  - tempo_descanso_segundos (INTEGER, nullable)
  - tut_segundos (INTEGER, nullable)
  - tempo_inicio (TIMESTAMP, nullable)
  - tempo_fim (TIMESTAMP, nullable)

- Adicionar tabela `configuracoes_exercicio`:
  - id, exercicio_nome, tempo_descanso_alvo, tut_alvo, rpe_alvo

- Adicionar tabela `sessao_treino`:
  - id, dia_id, data_inicio, data_fim, densidade, score_intensidade

### RT-2: Serviços
- Criar `IntensidadeService` com métodos:
  - `converterRPEparaRIR(rpe)` → retorna RIR
  - `converterRIRparaRPE(rir)` → retorna RPE
  - `calcularDensidade(volumeTotal, tempoTotal)` → retorna densidade
  - `calcularScoreIntensidade(volume, rpe, densidade, tut)` → retorna 0-100
  - `sugerirRPEIdeal(objetivo)` → retorna RPE recomendado
  - `analisarIntensidadeSessao(sessaoId)` → retorna análise completa

### RT-3: UI/UX
- Modal rápido de RPE/RIR ao completar série (opcional, pode pular)
- Cronômetro flutuante durante treino
- Botão para iniciar/pausar TUT
- Card de densidade na tela de resumo
- Dashboard de intensidade na tela de estatísticas
- Gráficos de evolução de todas métricas

### RT-4: Configurações
- Permitir usuário configurar:
  - Se quer usar RPE ou RIR (ou ambos)
  - Tempo de descanso padrão
  - Se quer cronômetro automático
  - Se quer notificação de descanso
  - TUT alvo por exercício

## 5. Métricas de Sucesso

- 60% dos usuários registram RPE regularmente
- 70% dos usuários usam cronômetro de descanso
- Aumento de 40% na consistência de descanso entre séries
- 50% dos usuários consultam dashboard de intensidade semanalmente

## 6. Dependências

- Requer permissão de notificações para alertas de descanso
- Requer dados históricos para análises comparativas

## 7. Riscos e Mitigações

**Risco:** Adicionar muitos campos pode tornar registro lento  
**Mitigação:** Todos campos são opcionais, interface rápida com valores padrão

**Risco:** Usuários podem não entender RPE/RIR  
**Mitigação:** Tutorial inicial, tooltips explicativos, conversão automática

**Risco:** Cronômetro pode drenar bateria  
**Mitigação:** Otimizar uso de recursos, permitir desabilitar

## 8. Fases de Implementação

### Fase 1 (MVP)
- RPE por série
- Cronômetro de descanso básico

### Fase 2
- RIR e conversão RPE↔RIR
- Tempo sob tensão
- Registro de tempo real de descanso

### Fase 3
- Densidade do treino
- Score de intensidade
- Dashboard completo de intensidade
- Análises e recomendações

## 9. Referências

- Escala RPE: https://www.strongerbyscience.com/rpe/
- RIR: https://www.strongerbyscience.com/autoregulation/
- Densidade de treino: Volume / Tempo
