# GymTracker - Roadmap de Evolução

## Visão Geral

Este roadmap transforma o GymTracker de um rastreador básico em uma plataforma profissional de periodização e análise de treino.

## Status Atual

✅ Funcionalidades Implementadas:
- Gestão de treinos semanais
- Organização por grupos musculares
- Registro de séries (peso, reps)
- Histórico de treinos
- Estatísticas básicas (volume, PRs)
- Gráficos de evolução

❌ Limitações Atuais:
- Apenas registra dados, não analisa
- Sem sugestões inteligentes
- Sem controle de intensidade
- Sem periodização
- Sem monitoramento de recuperação

---

## Plano de Implementação

### 🎯 FASE 1: Progressão Inteligente (4-6 semanas)
**Objetivo:** Transformar dados em insights acionáveis

#### Sprint 1.1: Cálculo de 1RM (1 semana)
- [ ] Implementar fórmulas Epley e Brzycki
- [ ] Adicionar campos no banco de dados
- [ ] Criar serviço de cálculo
- [ ] Exibir 1RM na tela de estatísticas
- [ ] Gráfico de evolução de 1RM

**Entregável:** Usuário vê 1RM estimado automaticamente

#### Sprint 1.2: Sugestão de Carga (1 semana)
- [ ] Analisar últimas 3 sessões
- [ ] Implementar lógica de sugestão
- [ ] UI de sugestão na tela de séries
- [ ] Permitir aceitar/rejeitar sugestão
- [ ] Registrar feedback do usuário

**Entregável:** App sugere carga para próxima série

#### Sprint 1.3: Detecção de Platô (1 semana)
- [ ] Implementar algoritmo de detecção
- [ ] Criar alertas visuais
- [ ] Sugerir estratégias de superação
- [ ] Dashboard de platôs ativos
- [ ] Histórico de platôs resolvidos

**Entregável:** Usuário é alertado sobre estagnação

#### Sprint 1.4: Progresso Relativo (1 semana)
- [ ] Calcular % de evolução
- [ ] Gráficos de progresso percentual
- [ ] Comparação com médias esperadas
- [ ] Ranking de exercícios
- [ ] Relatório de progresso mensal

**Entregável:** Usuário vê evolução em percentual

#### Sprint 1.5: Detecção de Deload (1 semana)
- [ ] Implementar critérios de detecção
- [ ] Alertas de necessidade de deload
- [ ] Sugestões de protocolo
- [ ] Agendamento de deload
- [ ] Tracking de deloads realizados

**Entregável:** App sugere quando fazer deload

**Métricas de Sucesso Fase 1:**
- 80% aceitação de sugestões de carga
- 30% redução em platôs prolongados
- 25% aumento em engajamento com estatísticas

---

### 🎯 FASE 2: Controle de Intensidade (4-6 semanas)
**Objetivo:** Medir intensidade real, não apenas volume

#### Sprint 2.1: RPE e RIR (1 semana)
- [ ] Adicionar campos RPE/RIR no banco
- [ ] UI rápida para registro
- [ ] Conversão automática RPE↔RIR
- [ ] Histórico de RPE por exercício
- [ ] Alertas de RPE excessivo

**Entregável:** Usuário registra intensidade percebida

#### Sprint 2.2: Cronômetro de Descanso (1 semana)
- [ ] Implementar cronômetro automático
- [ ] Notificações de tempo alvo
- [ ] Configuração por exercício
- [ ] Registro de tempo real
- [ ] Análise de consistência

**Entregável:** App cronometra descanso automaticamente

#### Sprint 2.3: Tempo Sob Tensão (1 semana)
- [ ] Campo de TUT por série
- [ ] Sugestões baseadas em reps
- [ ] Cálculo de TUT total
- [ ] Alertas de execução rápida
- [ ] Histórico de TUT

**Entregável:** Usuário registra qualidade de execução

#### Sprint 2.4: Densidade do Treino (1 semana)
- [ ] Calcular densidade (volume/tempo)
- [ ] Exibir em resumo de treino
- [ ] Gráficos de evolução
- [ ] Comparação entre sessões
- [ ] Sugestões de melhoria

**Entregável:** Usuário vê eficiência do treino

#### Sprint 2.5: Dashboard de Intensidade (1 semana)
- [ ] Score de intensidade combinado
- [ ] Análise multifatorial
- [ ] Recomendações baseadas em intensidade
- [ ] Comparações históricas
- [ ] Relatórios semanais

**Entregável:** Visão holística de intensidade

**Métricas de Sucesso Fase 2:**
- 60% dos usuários registram RPE
- 70% usam cronômetro de descanso
- 40% aumento em consistência de descanso

---

### 🎯 FASE 3: Periodização (6-8 semanas)
**Objetivo:** Planejamento estruturado de longo prazo

#### Sprint 3.1: Ciclos Básicos (2 semanas)
- [ ] Criar tabelas de ciclos/blocos
- [ ] UI de criação de ciclo
- [ ] Configurações por objetivo
- [ ] Visualização de ciclo atual
- [ ] Histórico de ciclos

**Entregável:** Usuário cria ciclos de treino

#### Sprint 3.2: Blocos e Mesociclos (2 semanas)
- [ ] Estrutura de blocos
- [ ] Timeline de mesociclo
- [ ] Transições automáticas
- [ ] Notificações de mudança
- [ ] Progresso dentro do bloco

**Entregável:** Planejamento de 12-16 semanas

#### Sprint 3.3: Templates (1 semana)
- [ ] Biblioteca de templates
- [ ] Templates por nível
- [ ] Customização de templates
- [ ] Salvar templates personalizados
- [ ] Compartilhamento (futuro)

**Entregável:** Templates prontos para usar

#### Sprint 3.4: Ajuste Automático (1 semana)
- [ ] Lógica de ajuste por bloco
- [ ] Modificação de parâmetros
- [ ] Sugestões de rep range
- [ ] Override manual
- [ ] Histórico de ajustes

**Entregável:** Parâmetros se ajustam automaticamente

#### Sprint 3.5: Comparação e Análise (2 semanas)
- [ ] Comparação entre blocos
- [ ] Gráficos comparativos
- [ ] Análise de efetividade
- [ ] Recomendações baseadas em histórico
- [ ] Exportação de relatórios

**Entregável:** Análise de efetividade da periodização

**Métricas de Sucesso Fase 3:**
- 70% criam pelo menos 1 ciclo
- 50% completam mesociclo
- 40% usam comparação de blocos

---

### 🎯 FASE 4: Recuperação e Fadiga (4-6 semanas)
**Objetivo:** Prevenir overtraining e otimizar recuperação

#### Sprint 4.1: Frequência e Intervalo (1 semana)
- [ ] Calcular frequência por músculo
- [ ] Intervalo desde último treino
- [ ] Dashboard de frequência
- [ ] Alertas de frequência inadequada
- [ ] Código de cores visual

**Entregável:** Monitoramento de frequência

#### Sprint 4.2: Volume Acumulado (1 semana)
- [ ] Calcular volume semanal por músculo
- [ ] Comparação com histórico
- [ ] Alertas de volume excessivo
- [ ] Gráficos de acumulação
- [ ] Sugestões de redução

**Entregável:** Controle de volume semanal

#### Sprint 4.3: Mapa de Fadiga (2 semanas)
- [ ] Algoritmo de cálculo de fadiga
- [ ] Diagrama corporal visual
- [ ] Níveis de fadiga por cor
- [ ] Atualização em tempo real
- [ ] Histórico de fadiga

**Entregável:** Visualização de fadiga muscular

#### Sprint 4.4: Score de Recuperação (1 semana)
- [ ] Cálculo de score 0-100
- [ ] Recomendações diárias
- [ ] Métricas opcionais (sono, estresse)
- [ ] Correlações com performance
- [ ] Histórico de score

**Entregável:** Score geral de recuperação

#### Sprint 4.5: Detecção de Overtraining (1 semana)
- [ ] Critérios de detecção
- [ ] Alertas críticos
- [ ] Recomendações específicas
- [ ] Registro de sintomas
- [ ] Prevenção proativa

**Entregável:** Sistema de alerta de overtraining

**Métricas de Sucesso Fase 4:**
- 80% consultam dashboard semanalmente
- 40% redução em overtraining
- 60% seguem sugestões de recuperação

---

## Cronograma Geral

```
Mês 1-2:  Fase 1 - Progressão Inteligente
Mês 3-4:  Fase 2 - Controle de Intensidade
Mês 5-6:  Fase 3 - Periodização
Mês 7-8:  Fase 4 - Recuperação e Fadiga
Mês 9:    Refinamentos e otimizações
Mês 10:   Testes beta e ajustes
```

**Total: 8-10 meses para implementação completa**

---

## Priorização

### Must Have (Essencial)
1. Cálculo de 1RM
2. Sugestão de carga
3. RPE/RIR
4. Cronômetro de descanso
5. Ciclos básicos
6. Frequência por músculo

### Should Have (Importante)
1. Detecção de platô
2. Densidade do treino
3. Blocos e mesociclos
4. Mapa de fadiga
5. Score de recuperação

### Could Have (Desejável)
1. Templates de periodização
2. TUT detalhado
3. Métricas avançadas de recuperação
4. Análise de correlações
5. Exportação de relatórios

### Won't Have (Futuro)
1. Integração com wearables
2. IA para recomendações
3. Comunidade e compartilhamento
4. Coaching virtual
5. Análise de vídeo de execução

---

## Dependências Entre Fases

```
Fase 1 (Progressão) → Base para todas outras fases
    ↓
Fase 2 (Intensidade) → Necessária para Fase 4
    ↓
Fase 3 (Periodização) → Usa dados de Fase 1 e 2
    ↓
Fase 4 (Recuperação) → Integra todas fases anteriores
```

---

## Recursos Necessários

### Desenvolvimento
- 1 desenvolvedor Flutter full-time
- Estimativa: 800-1000 horas totais

### Design
- UI/UX para novas telas
- Diagramas corporais
- Gráficos e visualizações

### Testes
- Testes unitários para cada serviço
- Testes de integração
- Beta testing com usuários reais

---

## Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Complexidade afasta usuários | Alta | Alto | Tutoriais, modo simples, onboarding |
| Cálculos imprecisos | Média | Alto | Validação com especialistas, ajustes |
| Performance com muitos dados | Média | Médio | Otimização de queries, cache |
| Usuários não seguem sugestões | Alta | Médio | Gamificação, educação, feedback |

---

## Próximos Passos Imediatos

1. ✅ Criar specs detalhadas (COMPLETO)
2. ⏭️ Revisar e aprovar roadmap
3. ⏭️ Começar Fase 1, Sprint 1.1
4. ⏭️ Configurar tracking de métricas
5. ⏭️ Preparar ambiente de testes

---

## Contato e Feedback

Para sugestões, dúvidas ou feedback sobre o roadmap:
- Criar issue no repositório
- Discussões na comunidade
- Email: [seu-email]

---

**Última atualização:** 2026-03-01  
**Versão:** 1.0  
**Status:** Aguardando aprovação
