import '../service/database_service.dart';
import '../service/intensity_service.dart';

/// Serviço para análises e cálculos agregados de intensidade.
/// 
/// Este serviço fornece métodos para:
/// - Calcular médias de métricas de intensidade (RPE, RIR, descanso, TUT)
/// - Calcular totais (TUT total)
/// - Analisar sessões completas de treino
/// - Comparar métricas entre sessões
/// - Gerar recomendações baseadas em dados
class AnalysisService {
  /// Calcula RPE médio de um exercício na sessão atual
  /// 
  /// Usa query SQL com AVG() para performance otimizada.
  /// Retorna 0.0 se não houver séries com RPE registrado.
  /// 
  /// @param exercicioId ID do exercício
  /// @return RPE médio (1-10) ou 0.0 se não houver dados
  static Future<double> calcularRPEMedioExercicio(int exercicioId) async {
    final db = await DatabaseService.getDatabase();
    
    final result = await db.rawQuery('''
      SELECT AVG(rpe) as rpe_medio
      FROM series
      WHERE exercicio_id = ? AND rpe IS NOT NULL
    ''', [exercicioId]);
    
    if (result.isNotEmpty && result.first['rpe_medio'] != null) {
      return (result.first['rpe_medio'] as num).toDouble();
    }
    return 0.0;
  }

  /// Calcula RIR médio de um exercício na sessão atual
  /// 
  /// Usa query SQL com AVG() para performance otimizada.
  /// Retorna 0.0 se não houver séries com RIR registrado.
  /// 
  /// @param exercicioId ID do exercício
  /// @return RIR médio (0-5+) ou 0.0 se não houver dados
  static Future<double> calcularRIRMedioExercicio(int exercicioId) async {
    final db = await DatabaseService.getDatabase();
    
    final result = await db.rawQuery('''
      SELECT AVG(rir) as rir_medio
      FROM series
      WHERE exercicio_id = ? AND rir IS NOT NULL
    ''', [exercicioId]);
    
    if (result.isNotEmpty && result.first['rir_medio'] != null) {
      return (result.first['rir_medio'] as num).toDouble();
    }
    return 0.0;
  }

  /// Calcula tempo médio de descanso de um exercício
  /// 
  /// Usa query SQL com AVG() para performance otimizada.
  /// Retorna 0.0 se não houver séries com tempo de descanso registrado.
  /// 
  /// @param exercicioId ID do exercício
  /// @return Tempo médio de descanso em segundos ou 0.0 se não houver dados
  static Future<double> calcularDescansoMedioExercicio(int exercicioId) async {
    final db = await DatabaseService.getDatabase();
    
    final result = await db.rawQuery('''
      SELECT AVG(tempo_descanso_segundos) as descanso_medio
      FROM series
      WHERE exercicio_id = ? AND tempo_descanso_segundos IS NOT NULL
    ''', [exercicioId]);
    
    if (result.isNotEmpty && result.first['descanso_medio'] != null) {
      return (result.first['descanso_medio'] as num).toDouble();
    }
    return 0.0;
  }

  /// Calcula TUT médio de um exercício
  /// 
  /// Usa query SQL com AVG() para performance otimizada.
  /// Retorna 0.0 se não houver séries com TUT registrado.
  /// 
  /// @param exercicioId ID do exercício
  /// @return TUT médio em segundos ou 0.0 se não houver dados
  static Future<double> calcularTUTMedioExercicio(int exercicioId) async {
    final db = await DatabaseService.getDatabase();
    
    final result = await db.rawQuery('''
      SELECT AVG(tut_segundos) as tut_medio
      FROM series
      WHERE exercicio_id = ? AND tut_segundos IS NOT NULL
    ''', [exercicioId]);
    
    if (result.isNotEmpty && result.first['tut_medio'] != null) {
      return (result.first['tut_medio'] as num).toDouble();
    }
    return 0.0;
  }

  /// Calcula TUT total de um exercício
  /// 
  /// Usa query SQL com SUM() para performance otimizada.
  /// Retorna 0 se não houver séries com TUT registrado.
  /// 
  /// @param exercicioId ID do exercício
  /// @return TUT total em segundos ou 0 se não houver dados
  static Future<int> calcularTUTTotalExercicio(int exercicioId) async {
    final db = await DatabaseService.getDatabase();
    
    final result = await db.rawQuery('''
      SELECT SUM(tut_segundos) as tut_total
      FROM series
      WHERE exercicio_id = ? AND tut_segundos IS NOT NULL
    ''', [exercicioId]);
    
    if (result.isNotEmpty && result.first['tut_total'] != null) {
      return (result.first['tut_total'] as num).toInt();
    }
    return 0;
  }

  /// Analisa intensidade completa de uma sessão de treino
  /// 
  /// Calcula todas as métricas agregadas da sessão:
  /// - Volume total (kg)
  /// - RPE médio
  /// - RIR médio
  /// - TUT total
  /// - Tempo de descanso médio
  /// - Densidade (kg/min)
  /// - Score de intensidade (0-100)
  /// 
  /// @param sessaoId ID da sessão na tabela sessao_treino
  /// @return Mapa com todas as métricas calculadas
  static Future<Map<String, dynamic>> analisarIntensidadeSessao(int sessaoId) async {
    final db = await DatabaseService.getDatabase();
    
    // Buscar dados da sessão
    final sessaoResult = await db.query(
      'sessao_treino',
      where: 'id = ?',
      whereArgs: [sessaoId],
    );
    
    if (sessaoResult.isEmpty) {
      return {
        'error': 'Sessão não encontrada',
      };
    }
    
    final sessao = sessaoResult.first;
    final diaId = sessao['dia_id'] as int;
    final dataInicio = DateTime.parse(sessao['data_inicio'] as String);
    final dataFim = sessao['data_fim'] != null 
        ? DateTime.parse(sessao['data_fim'] as String)
        : DateTime.now();
    
    // Calcular tempo total em segundos
    final tempoTotalSegundos = dataFim.difference(dataInicio).inSeconds;
    
    // Buscar todas as séries da sessão
    final seriesResult = await db.rawQuery('''
      SELECT 
        series.peso,
        series.repeticoes,
        series.rpe,
        series.rir,
        series.tut_segundos,
        series.tempo_descanso_segundos
      FROM series
      INNER JOIN exercicios ON series.exercicio_id = exercicios.id
      INNER JOIN grupos ON exercicios.grupo_id = grupos.id
      WHERE grupos.dia_id = ?
    ''', [diaId]);
    
    if (seriesResult.isEmpty) {
      return {
        'volume_total': 0.0,
        'rpe_medio': 0.0,
        'rir_medio': 0.0,
        'tut_total': 0,
        'tempo_descanso_medio': 0.0,
        'densidade': 0.0,
        'score_intensidade': 0,
        'tempo_total_segundos': tempoTotalSegundos,
      };
    }
    
    // Calcular volume total
    double volumeTotal = 0.0;
    for (final serie in seriesResult) {
      final peso = (serie['peso'] as num?)?.toDouble() ?? 0.0;
      final reps = (serie['repeticoes'] as num?)?.toInt() ?? 0;
      volumeTotal += peso * reps;
    }
    
    // Calcular RPE médio (apenas séries com RPE)
    final seriesComRPE = seriesResult.where((s) => s['rpe'] != null).toList();
    double rpeMedio = 0.0;
    if (seriesComRPE.isNotEmpty) {
      final somaRPE = seriesComRPE.fold<double>(
        0.0,
        (sum, s) => sum + ((s['rpe'] as num).toDouble()),
      );
      rpeMedio = somaRPE / seriesComRPE.length;
    }
    
    // Calcular RIR médio (apenas séries com RIR)
    final seriesComRIR = seriesResult.where((s) => s['rir'] != null).toList();
    double rirMedio = 0.0;
    if (seriesComRIR.isNotEmpty) {
      final somaRIR = seriesComRIR.fold<double>(
        0.0,
        (sum, s) => sum + ((s['rir'] as num).toDouble()),
      );
      rirMedio = somaRIR / seriesComRIR.length;
    }
    
    // Calcular TUT total
    final seriesComTUT = seriesResult.where((s) => s['tut_segundos'] != null).toList();
    int tutTotal = 0;
    if (seriesComTUT.isNotEmpty) {
      tutTotal = seriesComTUT.fold<int>(
        0,
        (sum, s) => sum + ((s['tut_segundos'] as num).toInt()),
      );
    }
    
    // Calcular tempo de descanso médio
    final seriesComDescanso = seriesResult.where((s) => s['tempo_descanso_segundos'] != null).toList();
    double tempoDescansoMedio = 0.0;
    if (seriesComDescanso.isNotEmpty) {
      final somaDescanso = seriesComDescanso.fold<double>(
        0.0,
        (sum, s) => sum + ((s['tempo_descanso_segundos'] as num).toDouble()),
      );
      tempoDescansoMedio = somaDescanso / seriesComDescanso.length;
    }
    
    // Calcular densidade (kg/min) usando IntensityService
    double densidade = IntensityService.calcularDensidade(
      volumeTotal,
      tempoTotalSegundos,
    );
    
    // Calcular score de intensidade (0-100) usando IntensityService
    int scoreIntensidade = IntensityService.calcularScoreIntensidade(
      volumeTotal: volumeTotal,
      rpeMedio: rpeMedio,
      densidade: densidade,
      tutTotal: tutTotal,
    );
    
    return {
      'volume_total': volumeTotal,
      'rpe_medio': rpeMedio,
      'rir_medio': rirMedio,
      'tut_total': tutTotal,
      'tempo_descanso_medio': tempoDescansoMedio,
      'densidade': densidade,
      'score_intensidade': scoreIntensidade,
      'tempo_total_segundos': tempoTotalSegundos,
    };
  }

  /// Compara densidade entre sessões
  /// 
  /// Busca as últimas N sessões finalizadas e retorna suas densidades
  /// ordenadas por data (mais recente primeiro).
  /// 
  /// @param numSessoes Número de sessões a buscar
  /// @return Lista de densidades das últimas N sessões
  static Future<List<double>> compararDensidadeSessoes(int numSessoes) async {
    final db = await DatabaseService.getDatabase();
    
    final result = await db.query(
      'sessao_treino',
      columns: ['densidade'],
      where: 'data_fim IS NOT NULL AND densidade IS NOT NULL',
      orderBy: 'data_inicio DESC',
      limit: numSessoes,
    );
    
    return result
        .map((row) => (row['densidade'] as num).toDouble())
        .toList();
  }

  /// Gera recomendações baseadas em métricas de intensidade
  /// 
  /// Analisa as métricas da sessão e gera sugestões contextuais para
  /// melhorar o treino ou prevenir overtraining.
  /// 
  /// @param sessaoId ID da sessão
  /// @return Lista de strings com recomendações
  static Future<List<String>> gerarRecomendacoes(int sessaoId) async {
    final metricas = await analisarIntensidadeSessao(sessaoId);
    final recomendacoes = <String>[];
    
    if (metricas.containsKey('error')) {
      return ['Não foi possível gerar recomendações: ${metricas['error']}'];
    }
    
    final rpeMedio = metricas['rpe_medio'] as double;
    final densidade = metricas['densidade'] as double;
    final tutTotal = metricas['tut_total'] as int;
    final scoreIntensidade = metricas['score_intensidade'] as int;
    
    // Recomendações baseadas em RPE
    if (rpeMedio > 9.0) {
      recomendacoes.add('RPE muito alto (${rpeMedio.toStringAsFixed(1)}). Considere reduzir a intensidade ou fazer um deload.');
    } else if (rpeMedio > 0 && rpeMedio < 6.0) {
      recomendacoes.add('RPE baixo (${rpeMedio.toStringAsFixed(1)}). Você pode aumentar a intensidade para melhores resultados.');
    } else if (rpeMedio >= 7.0 && rpeMedio <= 9.0) {
      recomendacoes.add('RPE ideal para hipertrofia (${rpeMedio.toStringAsFixed(1)}). Continue assim!');
    }
    
    // Recomendações baseadas em densidade
    if (densidade > 0 && densidade < 20.0) {
      recomendacoes.add('Densidade baixa (${densidade.toStringAsFixed(1)} kg/min). Tente reduzir o tempo de descanso ou aumentar o volume.');
    } else if (densidade > 60.0) {
      recomendacoes.add('Densidade muito alta (${densidade.toStringAsFixed(1)} kg/min). Certifique-se de descansar adequadamente entre séries.');
    }
    
    // Recomendações baseadas em TUT
    if (tutTotal > 0 && tutTotal < 600) {
      recomendacoes.add('TUT total baixo (${tutTotal}s). Considere aumentar o tempo sob tensão para melhor estímulo muscular.');
    }
    
    // Recomendações baseadas em score geral
    if (scoreIntensidade < 30) {
      recomendacoes.add('Intensidade geral baixa (score: $scoreIntensidade). Considere aumentar volume, peso ou reduzir descanso.');
    } else if (scoreIntensidade > 80) {
      recomendacoes.add('Intensidade muito alta (score: $scoreIntensidade). Monitore sinais de fadiga e considere periodização.');
    } else if (scoreIntensidade >= 50 && scoreIntensidade <= 80) {
      recomendacoes.add('Intensidade ideal (score: $scoreIntensidade). Treino bem balanceado!');
    }
    
    if (recomendacoes.isEmpty) {
      recomendacoes.add('Continue com o bom trabalho! Registre mais métricas para recomendações mais precisas.');
    }
    
    return recomendacoes;
  }
}
