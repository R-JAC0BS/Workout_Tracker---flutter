# Recuperação e Fadiga - Requirements

## 1. Visão Geral

Implementar sistema de monitoramento de recuperação e fadiga para prevenir overtraining e otimizar frequência de treino por grupo muscular.

## 2. Problema Atual

O aplicativo não mede:
- Frequência semanal por músculo
- Intervalo desde último estímulo
- Volume acumulado por músculo na semana
- Estado de recuperação
- Risco de overtraining

## 3. User Stories

### US-1: Frequência Semanal por Músculo
**Como** usuário do app  
**Quero** ver quantas vezes treinei cada músculo na semana  
**Para** garantir frequência adequada

**Critérios de Aceitação:**
- Dashboard mostrando frequência por grupo muscular
- Visualização semanal e mensal
- Código de cores:
  - Verde: 2-3x/semana (ideal)
  - Amarelo: 1x/semana (subótimo)
  - Vermelho: 0x ou 4+x/semana (problema)
- Alerta quando músculo não é treinado há >7 dias
- Alerta quando músculo é treinado >3x em 7 dias
- Histórico de frequência ao longo do tempo

### US-2: Intervalo de Recuperação
**Como** usuário do app  
**Quero** ver quanto tempo passou desde último treino de cada músculo  
**Para** planejar próxima sessão adequadamente

**Critérios de Aceitação:**
- Exibe dias desde último treino por grupo muscular
- Indicador visual de estado de recuperação:
  - 0-24h: Recuperando (vermelho)
  - 24-48h: Parcialmente recuperado (amarelo)
  - 48-72h: Recuperado (verde)
  - 72h+: Totalmente recuperado (azul)
- Sugere quando treinar cada músculo novamente
- Considera volume e intensidade do último treino
- Notificação quando músculo está pronto para treinar

### US-3: Volume Acumulado Semanal
**Como** usuário do app  
**Quero** ver volume acumulado por músculo na semana  
**Para** evitar excesso de volume

**Critérios de Aceitação:**
- Calcula volume total (séries × peso × reps) por músculo
- Exibe volume semanal vs volume médio histórico
- Alerta quando volume excede +30% da média
- Gráfico de volume acumulado ao longo da semana
- Comparação com semanas anteriores
- Sugere redução quando volume está muito alto

### US-4: Mapa de Fadiga Muscular
**Como** usuário do app  
**Quero** ver mapa visual de fadiga dos músculos  
**Para** identificar rapidamente áreas sobrecarregadas

**Critérios de Aceitação:**
- Diagrama corporal com músculos coloridos por nível de fadiga
- Níveis de fadiga:
  - Verde: Recuperado (0-30% fadiga)
  - Amarelo: Moderado (30-60% fadiga)
  - Laranja: Alto (60-80% fadiga)
  - Vermelho: Crítico (80-100% fadiga)
- Cálculo de fadiga baseado em:
  - Volume recente
  - Frequência
  - Tempo desde último treino
  - RPE médio
- Atualização em tempo real
- Histórico de fadiga ao longo do tempo

### US-5: Score de Recuperação Geral
**Como** usuário do app  
**Quero** ver score geral de recuperação  
**Para** saber se estou pronto para treinar pesado

**Critérios de Aceitação:**
- Score de 0-100 baseado em:
  - Fadiga muscular média
  - Volume semanal vs capacidade
  - Frequência de treino
  - Qualidade do sono (opcional)
  - Estresse percebido (opcional)
- Recomendação diária:
  - 80-100: Treino pesado OK
  - 60-79: Treino moderado
  - 40-59: Treino leve
  - 0-39: Descanso recomendado
- Histórico de score ao longo do tempo
- Correlação entre score e performance

### US-6: Detecção de Overtraining
**Como** usuário do app  
**Quero** ser alertado sobre sinais de overtraining  
**Para** prevenir lesões e burnout

**Critérios de Aceitação:**
- Sistema detecta overtraining quando:
  - Volume semanal >150% da média por 2+ semanas
  - Frequência >6 dias/semana por 3+ semanas
  - Queda de performance em 50%+ dos exercícios
  - RPE consistentemente >9 por 2+ semanas
  - Score de recuperação <40 por 5+ dias
- Alerta crítico na tela principal
- Recomendações específicas:
  - Reduzir volume em 40%
  - Adicionar dia de descanso
  - Fazer deload completo
  - Consultar profissional
- Permite registrar sintomas adicionais

### US-7: Planejamento Baseado em Recuperação
**Como** usuário do app  
**Quero** que o app sugira treinos baseado em recuperação  
**Para** otimizar resultados e prevenir overtraining

**Critérios de Aceitação:**
- Sugere quais músculos treinar hoje baseado em:
  - Tempo de recuperação
  - Volume acumulado
  - Frequência semanal
  - Score de recuperação geral
- Reordena dias de treino automaticamente se necessário
- Sugere intensidade apropriada (leve/moderado/pesado)
- Permite aceitar ou ignorar sugestões
- Aprende com padrões do usuário ao longo do tempo

### US-8: Métricas de Recuperação Avançadas
**Como** usuário avançado  
**Quero** registrar métricas adicionais de recuperação  
**Para** ter análise mais precisa

**Critérios de Aceitação:**
- Campos opcionais diários:
  - Qualidade do sono (1-10)
  - Horas de sono
  - Nível de estresse (1-10)
  - Dor muscular (0-10 por grupo)
  - Energia geral (1-10)
- Correlação entre métricas e performance
- Gráficos de tendências
- Insights automáticos (ex: "Performance 20% melhor com 8h+ sono")

## 4. Requisitos Técnicos

### RT-1: Banco de Dados
- Criar tabela `recuperacao_diaria`:
  - id, data, score_recuperacao, qualidade_sono, horas_sono, nivel_estresse, energia

- Criar tabela `fadiga_muscular`:
  - id, grupo_muscular, data, nivel_fadiga, volume_acumulado_semana, dias_desde_ultimo_treino

- Criar tabela `alertas_overtraining`:
  - id, data_deteccao, tipo, severidade, recomendacao, status

- Criar tabela `metricas_recuperacao`:
  - id, data, grupo_muscular, dor_muscular, tempo_recuperacao_estimado

- Adicionar campos à tabela `grupos`:
  - tempo_recuperacao_padrao (48-72h dependendo do músculo)
  - volume_maximo_semanal

### RT-2: Serviços
- Criar `RecuperacaoService` com métodos:
  - `calcularFrequenciaSemanal(grupoMuscular)` → retorna frequência
  - `calcularIntervaloRecuperacao(grupoMuscular)` → retorna horas
  - `calcularVolumeAcumulado(grupoMuscular, periodo)` → retorna volume
  - `calcularNivelFadiga(grupoMuscular)` → retorna 0-100
  - `calcularScoreRecuperacao()` → retorna 0-100
  - `detectarOvertraining()` → retorna boolean + detalhes
  - `sugerirProximoTreino()` → retorna recomendações
  - `analisarCorrelacoes()` → retorna insights

### RT-3: UI/UX
- Dashboard de recuperação na tela principal
- Mapa corporal de fadiga
- Card de score de recuperação
- Tela de métricas diárias (opcional)
- Alertas de overtraining
- Gráficos de frequência e volume
- Sugestões de treino baseadas em recuperação

### RT-4: Cálculos
- Fadiga muscular = f(volume, frequência, tempo, RPE)
- Score recuperação = média ponderada de todos fatores
- Tempo recuperação = baseado em volume e intensidade
- Detecção overtraining = múltiplos critérios combinados

## 5. Métricas de Sucesso

- 80% dos usuários consultam dashboard de recuperação semanalmente
- Redução de 40% em casos de overtraining detectados
- 60% dos usuários seguem sugestões de treino baseadas em recuperação
- Aumento de 25% na consistência de treino
- 70% dos usuários reportam menos fadiga excessiva

## 6. Dependências

- Requer dados históricos de pelo menos 2 semanas
- Requer funcionalidades de intensidade (RPE) para cálculos precisos
- Opcional: integração com apps de sono/fitness

## 7. Riscos e Mitigações

**Risco:** Cálculos imprecisos podem gerar recomendações erradas  
**Mitigação:** Usar múltiplos fatores, permitir ajuste manual, aprender com usuário

**Risco:** Usuários podem ignorar alertas de overtraining  
**Mitigação:** Educação, mostrar consequências, gamificação de recuperação

**Risco:** Registro de métricas diárias pode ser tedioso  
**Mitigação:** Tornar opcional, interface rápida, valores padrão inteligentes

## 8. Fases de Implementação

### Fase 1 (MVP)
- Frequência semanal por músculo
- Intervalo de recuperação
- Volume acumulado semanal

### Fase 2
- Mapa de fadiga muscular
- Score de recuperação geral
- Detecção básica de overtraining

### Fase 3
- Planejamento baseado em recuperação
- Métricas avançadas
- Análise de correlações e insights

## 9. Fórmulas e Algoritmos

### Cálculo de Fadiga Muscular
```
Fadiga = (Volume_Atual / Volume_Médio) × 0.4 +
         (Frequência_Semanal / 3) × 0.3 +
         (1 - Tempo_Recuperação / Tempo_Ideal) × 0.3
```

### Score de Recuperação
```
Score = 100 - (Fadiga_Média × 0.5 +
               Overreaching × 0.3 +
               Falta_Sono × 0.2)
```

### Tempo de Recuperação Estimado
```
Tempo = Base_Músculo × (1 + Volume_Relativo × 0.3 + RPE_Médio × 0.2)

Base por músculo:
- Pernas: 72h
- Costas: 60h
- Peito: 48h
- Ombros: 48h
- Braços: 36h
```

## 10. Referências

- Supercompensation Theory
- Fitness-Fatigue Model
- ACWR (Acute:Chronic Workload Ratio)
- Recovery-Stress Questionnaire (RESTQ)
