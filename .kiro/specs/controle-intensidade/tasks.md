# Plano de Implementação: Controle de Intensidade Real

## Visão Geral

Este plano implementa o sistema de controle de intensidade em 4 fases incrementais. Cada fase adiciona funcionalidades completas e testadas, permitindo validação progressiva. A implementação segue a arquitetura em camadas (Data → Service → UI) para garantir que cada componente seja testável independentemente.

## Tarefas

- [x] 1. Migração do banco de dados e modelos base
  - [x] 1.1 Atualizar DatabaseService para versão 6 do banco
    - Adicionar campos de intensidade à tabela series (rpe, rir, tempo_descanso_segundos, tut_segundos, tempo_inicio, tempo_fim)
    - Criar tabela configuracoes_exercicio
    - Criar tabela sessao_treino
    - Adicionar índices para otimização de queries
    - _Requisitos: RT-1_
  
  - [ ]* 1.2 Escrever testes de propriedade para migração do banco
    - **Propriedade 9: Persistência de Tempo de Descanso**
    - **Valida: Requisitos US-3.4, US-1.4, US-2.5, US-4.6**
  
  - [x] 1.3 Criar modelos Dart para novos dados
    - Estender classe Serie com campos de intensidade
    - Criar classe ConfiguracaoExercicio
    - Criar classe SessaoTreino
    - Adicionar métodos fromMap para deserialização
    - _Requisitos: RT-1_

- [x] 2. Implementar IntensityService (conversões e validações)
  - [x] 2.1 Implementar funções de conversão RPE↔RIR
    - Método converterRPEparaRIR(int rpe) → int
    - Método converterRIRparaRPE(int rir) → int
    - Seguir mapeamento: RPE 10=RIR 0, RPE 9=RIR 1, etc.
    - _Requisitos: US-2.2_
  
  - [ ]* 2.2 Escrever teste de propriedade para conversão round-trip
    - **Propriedade 5: Conversão RPE↔RIR Round-Trip**
    - **Valida: Requisitos US-2.2**
  
  - [x] 2.3 Implementar funções de validação
    - Método validarRPE(int rpe) → bool (aceita 1-10)
    - Método validarRIR(int rir) → bool (aceita 0-5+)
    - _Requisitos: US-1.1, US-2.1_
  
  - [ ]* 2.4 Escrever testes de propriedade para validações
    - **Propriedade 1: Validação de RPE**
    - **Valida: Requisitos US-1.1**
    - **Propriedade 4: Validação de RIR**
    - **Valida: Requisitos US-2.1**
  
  - [x] 2.5 Implementar cálculos básicos de intensidade
    - Método calcularTUTSugerido(int repeticoes) → int (reps × 4s)
    - Método calcularDensidade(double volume, int tempoSegundos) → double
    - Método detectarRiscoOvertraining(double rpeMedio7Dias) → bool
    - _Requisitos: US-4.2, US-5.1, US-1.6_
  
  - [ ]* 2.6 Escrever testes de propriedade para cálculos
    - **Propriedade 12: Cálculo de TUT Sugerido**
    - **Valida: Requisitos US-4.2**
    - **Propriedade 16: Cálculo de Densidade**
    - **Valida: Requisitos US-5.1**
    - **Propriedade 3: Detecção de Overtraining**
    - **Valida: Requisitos US-1.6**

- [x] 3. Checkpoint - Validar camada de serviço base
  - Garantir que todos os testes passam, perguntar ao usuário se há dúvidas.

- [x] 4. Implementar modal de RPE/RIR na SeriesScreen
  - [x] 4.1 Criar widget RPERIRModal
    - Botões grandes para seleção rápida (RPE 6-10 ou RIR 0-4)
    - Mostrar conversão automática em tempo real
    - Botões "Pular" e "Salvar"
    - Design consistente com tema do app
    - _Requisitos: US-1.1, US-1.2, US-2.1, US-2.2_
  
  - [x] 4.2 Integrar modal no fluxo de conclusão de série
    - Exibir modal após marcar série como completa
    - Salvar RPE/RIR selecionado no banco
    - Calcular e salvar valor convertido automaticamente
    - Permitir pular modal (tap fora ou botão)
    - _Requisitos: US-1.1, US-2.1_
  
  - [x] 4.3 Adicionar exibição de RPE/RIR na lista de séries
    - Mostrar RPE/RIR ao lado de cada série completada
    - Atualizar UI após salvar valores
    - _Requisitos: US-1.3, US-2.3_
  
  - [ ]* 4.4 Escrever testes unitários para modal
    - Testar que modal abre após completar série
    - Testar que valores são salvos corretamente
    - Testar que conversão é exibida corretamente
    - _Requisitos: US-1.1, US-2.1, US-2.2_

- [x] 5. Implementar AnalysisService (cálculos agregados)
  - [x] 5.1 Implementar cálculos de médias
    - Método calcularRPEMedioExercicio(int exercicioId) → Future<double>
    - Método calcularRIRMedioExercicio(int exercicioId) → Future<double>
    - Método calcularDescansoMedioExercicio(int exercicioId) → Future<double>
    - Método calcularTUTMedioExercicio(int exercicioId) → Future<double>
    - Usar queries SQL com AVG() para performance
    - _Requisitos: US-1.3, US-2.3, US-3.5, US-4.3_
  
  - [ ]* 5.2 Escrever testes de propriedade para cálculos de média
    - **Propriedade 2: Cálculo de RPE Médio**
    - **Valida: Requisitos US-1.3**
    - **Propriedade 6: Cálculo de RIR Médio**
    - **Valida: Requisitos US-2.3**
    - **Propriedade 10: Cálculo de Descanso Médio**
    - **Valida: Requisitos US-3.5**
    - **Propriedade 13: Cálculo de TUT Médio**
    - **Valida: Requisitos US-4.3**
  
  - [x] 5.3 Implementar cálculos de totais
    - Método calcularTUTTotalExercicio(int exercicioId) → Future<int>
    - Usar query SQL com SUM() para performance
    - _Requisitos: US-4.4_
  
  - [ ]* 5.4 Escrever teste de propriedade para TUT total
    - **Propriedade 14: Cálculo de TUT Total**
    - **Valida: Requisitos US-4.4**

- [x] 6. Adicionar exibição de métricas na SeriesScreen
  - [x] 6.1 Adicionar card de RPE médio no topo da tela
    - Buscar RPE médio do exercício usando AnalysisService
    - Exibir ao lado do PR e Volume Total
    - Atualizar em tempo real após registrar RPE
    - _Requisitos: US-1.3_
  
  - [x] 6.2 Atualizar UI para mostrar RPE/RIR em cada série
    - Exibir badge com RPE/RIR ao lado do botão de check
    - Usar cores para indicar intensidade (verde=baixo, amarelo=médio, vermelho=alto)
    - _Requisitos: US-1.3, US-2.3_

- [x] 7. Checkpoint - Validar funcionalidade básica de RPE/RIR
  - Garantir que todos os testes passam, perguntar ao usuário se há dúvidas.


- [x] 8. Implementar RestTimerService (cronômetro de descanso)
  - [x] 8.1 Criar RestTimerService com gerenciamento de Timer
    - Método iniciarCronometro(tempoAlvo, onTick, onComplete)
    - Método pararCronometro()
    - Método pausarCronometro() e retomarCronometro()
    - Método getTempoDecorrido() → int
    - Método isAtivo() → bool
    - Gerenciar estado global do timer
    - _Requisitos: US-3.1, US-3.4_
  
  - [ ]* 8.2 Escrever testes unitários para RestTimerService
    - Testar que cronômetro conta corretamente
    - Testar pausa e retomada
    - Testar que callback onComplete é chamado no tempo certo
    - _Requisitos: US-3.1_
  
  - [x] 8.3 Implementar sistema de notificações
    - Adicionar pacote flutter_local_notifications
    - Configurar notificações locais (Android/iOS)
    - Método notificarTempoAlvo() com som e vibração
    - Verificar permissões antes de notificar
    - _Requisitos: US-3.2_
  
  - [x] 8.4 Criar widget RestTimerWidget (flutuante)
    - Widget posicionado no bottom da tela
    - Exibir tempo decorrido / tempo alvo (ex: "1:30 / 2:00")
    - Botões de pausa/retomar e fechar
    - Indicador visual quando tempo alvo é atingido
    - Animação suave de entrada/saída
    - _Requisitos: US-3.1, US-3.2_
  
  - [x] 8.5 Integrar cronômetro no fluxo de conclusão de série
    - Iniciar cronômetro automaticamente após completar série (se habilitado)
    - Buscar tempo_descanso_alvo do exercício ou usar padrão (90s)
    - Calcular e salvar tempo_descanso_segundos real quando próxima série inicia
    - _Requisitos: US-3.1, US-3.4_
  
  - [ ]* 8.6 Escrever teste de propriedade para cronômetro automático
    - **Propriedade 7: Cronômetro Automático**
    - **Valida: Requisitos US-3.1**

- [x] 9. Implementar ConfigService (configurações de intensidade)
  - [x] 9.1 Criar ConfigService com métodos de configuração
    - Métodos para salvar/buscar tempo_descanso_alvo por exercício
    - Métodos para salvar/buscar tut_alvo por exercício
    - Métodos para salvar/buscar rpe_alvo por exercício
    - Usar SharedPreferences para configurações globais
    - _Requisitos: US-3.3, RT-4_
  
  - [x] 9.2 Implementar configurações globais
    - setUsarRPE/getUsarRPE (padrão: true)
    - setUsarRIR/getUsarRIR (padrão: false)
    - setCronometroAutomatico/getCronometroAutomatico (padrão: true)
    - setNotificacaoDescanso/getNotificacaoDescanso (padrão: true)
    - setTempoDescansoDefault/getTempoDescansoDefault (padrão: 90s)
    - _Requisitos: RT-4_
  
  - [ ]* 9.3 Escrever testes de propriedade para validação de configurações
    - **Propriedade 8: Validação de Tempo de Descanso Alvo**
    - **Valida: Requisitos US-3.3**
  
  - [ ]* 9.4 Escrever testes unitários para ConfigService
    - Testar que salvar e recuperar configurações retorna valores corretos
    - Testar que valores padrão são aplicados quando não há configuração
    - _Requisitos: RT-4_

- [x] 10. Implementar TUTService (rastreamento de tempo sob tensão)
  - [x] 10.1 Criar TUTService com gerenciamento de Stopwatch
    - Método iniciarTUT()
    - Método pararTUT() → int (retorna segundos)
    - Método getTUTAtual() → int
    - Método isRastreando() → bool
    - _Requisitos: US-4.1_
  
  - [x] 10.2 Adicionar botões de TUT na SeriesScreen
    - Botão "Iniciar TUT" antes de executar série
    - Botão "Parar TUT" após executar série
    - Exibir cronômetro crescente durante rastreamento
    - Salvar tut_segundos no banco ao parar
    - _Requisitos: US-4.1_
  
  - [x] 10.3 Implementar alerta de TUT baixo
    - Comparar TUT real com TUT sugerido (reps × 4s)
    - Se TUT < 70% do sugerido, mostrar alerta
    - Mensagem: "TUT baixo - considere execução mais controlada"
    - _Requisitos: US-4.5_
  
  - [ ]* 10.4 Escrever testes de propriedade para TUT
    - **Propriedade 11: Validação de TUT**
    - **Valida: Requisitos US-4.1**
    - **Propriedade 12: Cálculo de TUT Sugerido**
    - **Valida: Requisitos US-4.2**
    - **Propriedade 15: Alerta de TUT Baixo**
    - **Valida: Requisitos US-4.5**

- [x] 11. Checkpoint - Validar Fase 1 e Fase 2 completas
  - Garantir que todos os testes passam, perguntar ao usuário se há dúvidas.

- [x] 12. Implementar gerenciamento de sessões de treino
  - [x] 12.1 Adicionar métodos de sessão ao DatabaseService
    - Método createSessaoTreino(int diaId) → Future<int> (retorna sessaoId)
    - Método finalizarSessaoTreino(int sessaoId, métricas) → Future<void>
    - Método getSessaoAtiva(int diaId) → Future<SessaoTreino?>
    - Método getSessoesHistoricas(int limit) → Future<List<SessaoTreino>>
    - _Requisitos: RT-1_
  
  - [x] 12.2 Integrar criação de sessão na TrainingScreen
    - Criar sessão ao entrar na tela de treino do dia
    - Armazenar sessaoId em estado (Provider ou StatefulWidget)
    - Verificar se já existe sessão ativa antes de criar nova
    - _Requisitos: RT-1_
  
  - [x] 12.3 Implementar finalização de sessão
    - Detectar quando usuário finaliza treino (botão ou navegação)
    - Calcular todas as métricas agregadas (volume, RPE médio, densidade, etc)
    - Atualizar registro de sessao_treino com data_fim e métricas
    - _Requisitos: US-5.1, US-6.2_
  
  - [ ]* 12.4 Escrever testes unitários para gerenciamento de sessão
    - Testar criação de sessão
    - Testar cálculo de métricas agregadas
    - Testar finalização de sessão
    - _Requisitos: RT-1_

- [x] 13. Implementar AnalysisService completo
  - [x] 13.1 Implementar método calcularScoreIntensidade
    - Normalizar volume (ref: 5000kg), RPE (1-10), densidade (ref: 50 kg/min), TUT (ref: 1800s)
    - Aplicar pesos: volume 30%, RPE 40%, densidade 20%, TUT 10%
    - Retornar score 0-100
    - _Requisitos: US-6.2_
  
  - [ ]* 13.2 Escrever testes de propriedade para score de intensidade
    - **Propriedade 18: Score de Intensidade Limitado**
    - **Valida: Requisitos US-6.2**
    - **Propriedade 19: Score de Intensidade Monotônico**
    - **Valida: Requisitos US-6.2**
  
  - [x] 13.3 Implementar método analisarIntensidadeSessao
    - Buscar todas as séries da sessão
    - Calcular todas as métricas (volume, RPE médio, densidade, TUT total, etc)
    - Retornar mapa com todas as métricas
    - _Requisitos: US-6.1_
  
  - [x] 13.4 Implementar métodos de comparação histórica
    - Método compararDensidadeSessoes(int numSessoes) → Future<List<double>>
    - Buscar últimas N sessões e retornar densidades
    - Ordenar por data
    - _Requisitos: US-5.3, US-6.3_
  
  - [ ]* 13.5 Escrever teste de propriedade para recuperação histórica
    - **Propriedade 17: Recuperação de Sessões Históricas**
    - **Valida: Requisitos US-5.3, US-6.3**
  
  - [x] 13.6 Implementar sistema de recomendações
    - Método gerarRecomendacoes(int sessaoId) → Future<List<String>>
    - Analisar métricas e gerar sugestões contextuais
    - Exemplos: "Reduza descanso para aumentar densidade", "RPE alto - considere deload"
    - _Requisitos: US-5.5, US-6.4_

- [x] 14. Checkpoint - Validar camada de análise
  - Garantir que todos os testes passam, perguntar ao usuário se há dúvidas.


- [x] 15. Criar Dashboard de Intensidade
  - [x] 15.1 Criar IntensityDashboardScreen
    - Layout com cards para métricas principais
    - Gauge visual para score de intensidade (0-100)
    - Cards para: Volume Total, RPE Médio, Densidade, TUT Total, Descanso Médio
    - Usar fl_chart para gauge e cards
    - _Requisitos: US-6.1_
  
  - [x] 15.2 Implementar gráficos de evolução temporal
    - Gráfico de linha: RPE ao longo do tempo
    - Gráfico de linha: Densidade ao longo do tempo
    - Gráfico de barras: Volume vs RPE por sessão
    - Gráfico de linha: Descanso Real vs Alvo
    - Usar fl_chart para renderização
    - _Requisitos: US-1.5, US-3.6, US-5.4_
  
  - [x] 15.3 Adicionar seção de comparação com sessões anteriores
    - Mostrar variação percentual de cada métrica
    - Indicadores visuais (↑↓) para tendências
    - Comparar com média das últimas 5 sessões
    - _Requisitos: US-6.3_
  
  - [x] 15.4 Adicionar seção de recomendações
    - Exibir lista de recomendações do AnalysisService
    - Cards com ícones e texto explicativo
    - Priorizar recomendações por importância
    - _Requisitos: US-6.4_
  
  - [x] 15.5 Integrar dashboard na navegação
    - Adicionar aba ou botão na StatsScreen
    - Permitir navegação fácil entre estatísticas e intensidade
    - _Requisitos: US-6.1_

- [x] 16. Implementar tela de configurações de intensidade
  - [x] 16.1 Criar IntensitySettingsScreen
    - Toggle para usar RPE
    - Toggle para usar RIR
    - Toggle para cronômetro automático
    - Toggle para notificações de descanso
    - Slider para tempo de descanso padrão (30s-5min)
    - Salvar configurações usando ConfigService
    - _Requisitos: RT-4_
  
  - [x] 16.2 Adicionar configurações por exercício
    - Permitir configurar tempo_descanso_alvo específico
    - Permitir configurar tut_alvo específico
    - Permitir configurar rpe_alvo específico
    - Interface acessível a partir da SeriesScreen (botão de configurações)
    - _Requisitos: US-3.3, US-4.2, US-2.4_
  
  - [ ]* 16.3 Escrever testes unitários para tela de configurações
    - Testar que toggles salvam valores corretamente
    - Testar que configurações são carregadas ao abrir tela
    - _Requisitos: RT-4_

- [ ] 17. Implementar alertas e notificações inteligentes
  - [ ] 17.1 Adicionar alerta de overtraining
    - Calcular RPE médio dos últimos 7 dias após cada sessão
    - Se RPE médio > 9, exibir alerta na tela principal
    - Mensagem: "Atenção: RPE alto nos últimos 7 dias - considere semana de deload"
    - Permitir dispensar alerta
    - _Requisitos: US-1.6_
  
  - [ ]* 17.2 Escrever teste de propriedade para alerta de overtraining
    - **Propriedade 3: Detecção de Overtraining**
    - **Valida: Requisitos US-1.6**
  
  - [ ] 17.3 Adicionar indicador visual de intensidade na HomeScreen
    - Badge ou cor no card do dia indicando intensidade da última sessão
    - Verde (score < 50), Amarelo (50-75), Vermelho (> 75)
    - _Requisitos: US-6.1_

- [ ] 18. Adicionar históricos e gráficos de evolução
  - [ ] 18.1 Estender LogService para incluir métricas de intensidade
    - Modificar queries para incluir RPE, RIR, TUT nos logs
    - Adicionar métodos para buscar histórico de RPE/RIR/TUT
    - _Requisitos: US-1.4, US-2.5, US-4.6_
  
  - [ ] 18.2 Criar gráficos de evolução na ExerciseStatsScreen
    - Adicionar gráfico de RPE ao longo do tempo
    - Adicionar gráfico de TUT ao longo do tempo
    - Adicionar gráfico de Descanso Real vs Alvo
    - Usar fl_chart para renderização
    - _Requisitos: US-1.4, US-2.5, US-4.6, US-3.6_
  
  - [ ]* 18.3 Escrever testes unitários para queries de histórico
    - Testar que dados históricos são recuperados corretamente
    - Testar ordenação por data
    - Testar filtros por período
    - _Requisitos: US-1.4, US-2.5, US-4.6_

- [ ] 19. Refinamentos de UI/UX
  - [ ] 19.1 Adicionar sugestões inteligentes no modal de RPE
    - Mostrar RPE alvo configurado (se existir)
    - Mostrar RPE da última série do mesmo exercício
    - Destacar visualmente o valor sugerido
    - _Requisitos: US-2.4_
  
  - [ ] 19.2 Adicionar feedback visual para métricas
    - Animações ao salvar RPE/RIR
    - Cores indicativas de intensidade (verde/amarelo/vermelho)
    - Badges de conquistas (ex: "Novo PR de RPE!")
    - _Requisitos: RT-3_
  
  - [ ] 19.3 Otimizar performance de queries
    - Adicionar índices conforme especificado no design
    - Usar queries agregadas SQL em vez de cálculos no Dart
    - Cache de configurações em memória
    - _Requisitos: RT-1_

- [ ] 20. Checkpoint final - Validar sistema completo
  - Garantir que todos os testes passam, perguntar ao usuário se há dúvidas.
  - Testar fluxo completo end-to-end manualmente
  - Verificar que todas as métricas são calculadas corretamente
  - Confirmar que notificações funcionam
  - Validar que configurações são persistidas

## Notas

- Tarefas marcadas com `*` são opcionais e podem ser puladas para MVP mais rápido
- Cada tarefa referencia requisitos específicos para rastreabilidade
- Checkpoints garantem validação incremental
- Testes de propriedade validam propriedades universais de correção
- Testes unitários validam exemplos específicos e casos extremos
- A implementação segue 4 fases: MVP (RPE/RIR) → Cronômetro/TUT → Dashboard → Configurações

