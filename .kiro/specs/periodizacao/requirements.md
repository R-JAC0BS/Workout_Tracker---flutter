# Periodização - Requirements

## 1. Visão Geral

Implementar sistema completo de periodização que permite criar ciclos de treino, blocos de treinamento e comparar resultados entre diferentes fases.

## 2. Problema Atual

O aplicativo é estático:
- Não existe conceito de ciclos (hipertrofia/força/deload)
- Não há blocos de treinamento
- Não há planejamento de longo prazo
- Impossível comparar Bloco 1 vs Bloco 2

## 3. User Stories

### US-1: Criação de Ciclos de Treino
**Como** usuário do app  
**Quero** criar ciclos de treino com objetivos diferentes  
**Para** periodizar meu treinamento de forma estruturada

**Critérios de Aceitação:**
- Criar ciclo com: nome, objetivo, data início, data fim, duração em semanas
- Objetivos disponíveis: Hipertrofia, Força, Potência, Resistência, Deload, Manutenção
- Cada ciclo tem configurações específicas:
  - Hipertrofia: 8-12 reps, RPE 7-9, descanso 60-90s
  - Força: 1-5 reps, RPE 8-10, descanso 3-5min
  - Deload: -40% volume, RPE 5-7
- Visualizar ciclo atual na tela principal
- Histórico de todos os ciclos completados

### US-2: Blocos de Treinamento
**Como** usuário do app  
**Quero** organizar meu treino em blocos  
**Para** ter estrutura clara de progressão

**Critérios de Aceitação:**
- Criar bloco com: nome, ciclo_id, semanas, objetivo específico
- Exemplo: "Bloco 1 - Acumulação" (4 semanas, foco em volume)
- Exemplo: "Bloco 2 - Intensificação" (3 semanas, foco em carga)
- Cada bloco pode ter múltiplas semanas
- Visualizar progresso dentro do bloco (semana X de Y)
- Marcar bloco como completo automaticamente

### US-3: Planejamento de Mesociclo
**Como** usuário do app  
**Quero** planejar um mesociclo completo  
**Para** ter visão de longo prazo do treinamento

**Critérios de Aceitação:**
- Criar mesociclo (8-16 semanas) com múltiplos blocos
- Exemplo de mesociclo:
  - Bloco 1: Acumulação (4 semanas) - volume alto
  - Bloco 2: Intensificação (3 semanas) - carga alta
  - Bloco 3: Realização (2 semanas) - pico
  - Bloco 4: Deload (1 semana)
- Visualizar linha do tempo do mesociclo
- Ajustar automaticamente parâmetros por bloco
- Notificar transição entre blocos

### US-4: Comparação Entre Blocos
**Como** usuário do app  
**Quero** comparar resultados entre blocos  
**Para** avaliar efetividade da periodização

**Critérios de Aceitação:**
- Selecionar 2+ blocos para comparar
- Métricas comparadas:
  - Volume total médio
  - 1RM médio por exercício
  - RPE médio
  - Densidade média
  - Progresso em kg/semana
- Gráficos lado a lado
- Tabela de comparação detalhada
- Exportar comparação em PDF/imagem

### US-5: Templates de Periodização
**Como** usuário do app  
**Quero** usar templates prontos de periodização  
**Para** não precisar criar do zero

**Critérios de Aceitação:**
- Templates disponíveis:
  - "Iniciante - Linear" (12 semanas)
  - "Intermediário - Ondulado" (16 semanas)
  - "Avançado - Bloco" (12 semanas)
  - "Powerlifting - Peaking" (10 semanas)
- Cada template tem descrição e objetivo
- Permite customizar template antes de aplicar
- Salvar templates personalizados

### US-6: Ajuste Automático de Parâmetros
**Como** usuário do app  
**Quero** que parâmetros se ajustem automaticamente por bloco  
**Para** não precisar configurar manualmente

**Critérios de Aceitação:**
- Sistema ajusta automaticamente baseado no bloco:
  - Bloco Acumulação: +10% volume, -5% intensidade
  - Bloco Intensificação: -20% volume, +10% intensidade
  - Bloco Realização: -30% volume, +15% intensidade
  - Bloco Deload: -50% volume, -30% intensidade
- Sugere rep ranges por bloco
- Sugere tempo de descanso por bloco
- Permite override manual

### US-7: Análise de Efetividade
**Como** usuário do app  
**Quero** ver análise de efetividade da periodização  
**Para** entender o que funciona melhor para mim

**Critérios de Aceitação:**
- Calcula taxa de progresso por bloco
- Identifica qual tipo de bloco gera mais ganhos
- Compara diferentes estratégias de periodização
- Sugere ajustes baseado em histórico
- Gráfico de progresso ao longo de múltiplos ciclos

## 4. Requisitos Técnicos

### RT-1: Banco de Dados
- Criar tabela `ciclos`:
  - id, nome, objetivo, data_inicio, data_fim, duracao_semanas, status

- Criar tabela `blocos`:
  - id, ciclo_id, nome, ordem, semanas, objetivo_especifico, config_json

- Criar tabela `mesociclos`:
  - id, nome, data_inicio, data_fim, descricao, template_id

- Criar tabela `templates_periodizacao`:
  - id, nome, descricao, nivel, duracao_semanas, estrutura_json

- Criar tabela `parametros_bloco`:
  - id, bloco_id, rep_range_min, rep_range_max, rpe_alvo, descanso_segundos, volume_multiplicador

- Adicionar campo `bloco_id` à tabela `dias`
- Adicionar campo `ciclo_id` à tabela `dias`

### RT-2: Serviços
- Criar `PeriodizacaoService` com métodos:
  - `criarCiclo(dados)` → retorna ciclo
  - `criarBloco(cicloId, dados)` → retorna bloco
  - `criarMesociclo(dados)` → retorna mesociclo
  - `aplicarTemplate(templateId)` → cria estrutura completa
  - `compararBlocos(blocoIds[])` → retorna análise comparativa
  - `calcularEfetividade(blocoId)` → retorna métricas
  - `ajustarParametrosAutomatico(blocoId)` → atualiza configurações
  - `proximoBloco()` → retorna próximo bloco na sequência

### RT-3: UI/UX
- Tela de criação de ciclo/bloco
- Timeline visual do mesociclo
- Card de ciclo atual na tela principal
- Tela de comparação de blocos com gráficos
- Biblioteca de templates
- Dashboard de análise de periodização
- Indicador de progresso dentro do bloco

### RT-4: Lógica de Transição
- Detectar automaticamente fim de bloco
- Notificar usuário 3 dias antes do fim
- Sugerir próximo bloco baseado em template
- Permitir estender ou encurtar bloco
- Registrar motivo de mudança antecipada

## 5. Métricas de Sucesso

- 70% dos usuários criam pelo menos 1 ciclo
- 50% dos usuários completam mesociclo completo
- 40% dos usuários usam comparação entre blocos
- Aumento de 35% na consistência de treino
- 60% dos usuários reportam melhores resultados com periodização

## 6. Dependências

- Requer dados históricos de pelo menos 4 semanas
- Requer funcionalidades de progressão inteligente (1RM, etc)

## 7. Riscos e Mitigações

**Risco:** Complexidade pode afastar usuários iniciantes  
**Mitigação:** Templates simples, modo "automático", tutoriais

**Risco:** Usuários podem não seguir o planejamento  
**Mitigação:** Lembretes, flexibilidade para ajustar, mostrar benefícios

**Risco:** Comparações podem ser desmotivadoras se houver regressão  
**Mitigação:** Contextualizar resultados, explicar variações normais

## 8. Fases de Implementação

### Fase 1 (MVP)
- Criação de ciclos básicos
- Blocos simples
- Visualização de ciclo atual

### Fase 2
- Mesociclos completos
- Templates de periodização
- Ajuste automático de parâmetros

### Fase 3
- Comparação entre blocos
- Análise de efetividade
- Recomendações inteligentes

## 9. Exemplos de Estruturas

### Mesociclo Linear (Iniciante)
```
Semana 1-4: Adaptação (3x12, RPE 7)
Semana 5-8: Progressão (4x10, RPE 8)
Semana 9-11: Intensificação (5x8, RPE 9)
Semana 12: Deload (3x10, RPE 6)
```

### Mesociclo Ondulado (Intermediário)
```
Bloco 1 (4 sem): Acumulação - Volume alto
Bloco 2 (3 sem): Intensificação - Carga alta
Bloco 3 (1 sem): Deload
Repetir 2x
```

### Mesociclo Bloco (Avançado)
```
Bloco 1 (3 sem): Hipertrofia (3x12-15)
Bloco 2 (3 sem): Força (5x3-5)
Bloco 3 (2 sem): Potência (6x2-3)
Bloco 4 (1 sem): Deload
```
