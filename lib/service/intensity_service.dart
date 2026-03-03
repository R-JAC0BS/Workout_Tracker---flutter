/// Serviço central para cálculos e conversões de intensidade.
/// 
/// Este serviço fornece métodos para:
/// - Conversão entre RPE (Rate of Perceived Exertion) e RIR (Reps in Reserve)
/// - Validação de valores de intensidade
/// - Cálculos de métricas de treino
class IntensityService {
  /// Converte RPE (1-10) para RIR (0-5+)
  /// 
  /// Mapeamento:
  /// - RPE 10 = RIR 0 (falha)
  /// - RPE 9 = RIR 1
  /// - RPE 8 = RIR 2
  /// - RPE 7 = RIR 3
  /// - RPE 6 = RIR 4
  /// - RPE ≤5 = RIR 5+
  /// 
  /// @param rpe Valor de RPE (1-10)
  /// @return Valor de RIR correspondente (0-5+)
  static int converterRPEparaRIR(int rpe) {
    if (rpe >= 10) return 0;
    if (rpe == 9) return 1;
    if (rpe == 8) return 2;
    if (rpe == 7) return 3;
    if (rpe == 6) return 4;
    return 5; // RPE ≤5 = RIR 5+
  }

  /// Converte RIR (0-5+) para RPE (1-10)
  /// 
  /// Mapeamento inverso:
  /// - RIR 0 = RPE 10 (falha)
  /// - RIR 1 = RPE 9
  /// - RIR 2 = RPE 8
  /// - RIR 3 = RPE 7
  /// - RIR 4 = RPE 6
  /// - RIR 5+ = RPE 5
  /// 
  /// @param rir Valor de RIR (0-5+)
  /// @return Valor de RPE correspondente (1-10)
  static int converterRIRparaRPE(int rir) {
    if (rir == 0) return 10;
    if (rir == 1) return 9;
    if (rir == 2) return 8;
    if (rir == 3) return 7;
    if (rir == 4) return 6;
    return 5; // RIR 5+ = RPE 5
  }

  /// Valida se RPE está na faixa válida (1-10)
  /// 
  /// @param rpe Valor de RPE a ser validado
  /// @return true se RPE está entre 1 e 10 (inclusive), false caso contrário
  static bool validarRPE(int rpe) {
    return rpe >= 1 && rpe <= 10;
  }

  /// Valida se RIR está na faixa válida (0-5+)
  /// 
  /// RIR aceita valores de 0 ou maiores, onde:
  /// - 0 = falha muscular
  /// - 1-5 = repetições específicas na reserva
  /// - 5+ = 5 ou mais repetições na reserva
  /// 
  /// @param rir Valor de RIR a ser validado
  /// @return true se RIR é 0 ou maior, false caso contrário
  static bool validarRIR(int rir) {
    return rir >= 0;
  }

  /// Calcula TUT (Time Under Tension) sugerido baseado em repetições
  /// 
  /// Usa tempo padrão de 4 segundos por repetição:
  /// - 2 segundos fase concêntrica
  /// - 2 segundos fase excêntrica
  /// 
  /// @param repeticoes Número de repetições da série
  /// @return TUT sugerido em segundos
  static int calcularTUTSugerido(int repeticoes) {
    return repeticoes * 4;
  }

  /// Calcula densidade do treino: Volume Total (kg) / Tempo Total (min)
  /// 
  /// A densidade mede a eficiência do treino, indicando quanto trabalho
  /// foi realizado por unidade de tempo.
  /// 
  /// @param volume Volume total em kg (soma de peso × reps de todas as séries)
  /// @param tempoSegundos Tempo total da sessão em segundos
  /// @return Densidade em kg/min
  static double calcularDensidade(double volume, int tempoSegundos) {
    if (tempoSegundos == 0) return 0.0;
    return (volume / tempoSegundos) * 60;
  }

  /// Detecta risco de overtraining baseado em RPE consistentemente alto
  /// 
  /// Quando o RPE médio dos últimos 7 dias está acima de 9, indica que
  /// o atleta está treinando com intensidade muito alta de forma consistente,
  /// o que pode levar ao overtraining.
  /// 
  /// @param rpeMedio7Dias RPE médio dos últimos 7 dias
  /// @return true se RPE médio > 9 (risco de overtraining), false caso contrário
  static bool detectarRiscoOvertraining(double rpeMedio7Dias) {
    return rpeMedio7Dias > 9.0;
  }

  /// Calcula score de intensidade (0-100) baseado em múltiplas métricas
  /// 
  /// Combina volume, RPE médio, densidade e TUT total em um score único
  /// que representa a intensidade geral da sessão de treino.
  /// 
  /// Normalização:
  /// - Volume: referência de 5000kg como "alto"
  /// - RPE: escala 1-10 normalizada para 0-1
  /// - Densidade: referência de 50 kg/min como "alto"
  /// - TUT: referência de 1800s (30min) como "alto"
  /// 
  /// Pesos aplicados:
  /// - Volume: 30%
  /// - RPE: 40% (mais importante)
  /// - Densidade: 20%
  /// - TUT: 10%
  /// 
  /// @param volumeTotal Volume total em kg (soma de peso × reps)
  /// @param rpeMedio RPE médio da sessão (1-10)
  /// @param densidade Densidade em kg/min
  /// @param tutTotal TUT total em segundos
  /// @return Score de intensidade entre 0 e 100
  static int calcularScoreIntensidade({
    required double volumeTotal,
    required double rpeMedio,
    required double densidade,
    required int tutTotal,
  }) {
    // Normalizar cada métrica para 0-1
    
    // Volume: normalizar baseado em referência de 5000kg como "alto"
    final volumeNorm = (volumeTotal / 5000).clamp(0.0, 1.0);
    
    // RPE: já está em escala 1-10, normalizar para 0-1
    final rpeNorm = ((rpeMedio - 1) / 9).clamp(0.0, 1.0);
    
    // Densidade: normalizar baseado em 50 kg/min como "alto"
    final densidadeNorm = (densidade / 50).clamp(0.0, 1.0);
    
    // TUT: normalizar baseado em 1800s (30min) como "alto"
    final tutNorm = (tutTotal / 1800).clamp(0.0, 1.0);
    
    // Pesos para cada métrica (total = 1.0)
    const pesoVolume = 0.3;
    const pesoRPE = 0.4;      // RPE é o mais importante
    const pesoDensidade = 0.2;
    const pesoTUT = 0.1;
    
    // Calcular score ponderado
    final score = (
      volumeNorm * pesoVolume +
      rpeNorm * pesoRPE +
      densidadeNorm * pesoDensidade +
      tutNorm * pesoTUT
    ) * 100;
    
    return score.round().clamp(0, 100);
  }
}
