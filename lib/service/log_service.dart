import 'package:workout_tracker/service/database_service.dart';

class LogData {
  /// Adiciona um log de exercício
  static Future<int> addLog({
    required String exercicioNome,
    required double peso,
    required int repeticoes,
  }) async {
    final db = await DatabaseService.getDatabase();
    
    // Garante que a tabela existe
    await DatabaseService.ensureLogsTableExists();
    
    final result = await db.insert('logs', {
      'exercicio_nome': exercicioNome,
      'peso': peso,
      'repeticoes': repeticoes,
    });
    
    print('Log salvo: $exercicioNome - ${peso}kg x ${repeticoes} reps (ID: $result)');
    return result;
  }

  /// Busca todos os logs de um exercício específico
  static Future<List<Map<String, dynamic>>> getLogsByExercicio(String exercicioNome) async {
    final db = await DatabaseService.getDatabase();
    return await db.query(
      'logs',
      where: 'exercicio_nome = ?',
      whereArgs: [exercicioNome],
      orderBy: 'data DESC',
    );
  }

  /// Busca todos os exercícios únicos que têm logs
  static Future<List<String>> getAllExerciciosWithLogs() async {
    final db = await DatabaseService.getDatabase();
    
    // Garante que a tabela existe
    await DatabaseService.ensureLogsTableExists();
    
    try {
      final result = await db.rawQuery('''
        SELECT DISTINCT exercicio_nome 
        FROM logs 
        ORDER BY exercicio_nome ASC
      ''');
      
      final exercicios = result.map((e) => e['exercicio_nome'] as String).toList();
      print('Exercícios com logs: $exercicios');
      return exercicios;
    } catch (e) {
      print('Erro ao buscar exercícios: $e');
      return [];
    }
  }

  /// Busca o peso máximo de um exercício
  static Future<double> getMaxPeso(String exercicioNome) async {
    final db = await DatabaseService.getDatabase();
    final result = await db.rawQuery('''
      SELECT MAX(peso) as max_peso 
      FROM logs 
      WHERE exercicio_nome = ?
    ''', [exercicioNome]);
    
    if (result.isNotEmpty && result.first['max_peso'] != null) {
      return (result.first['max_peso'] as num).toDouble();
    }
    return 0.0;
  }

  /// Busca o volume total de um exercício (soma de peso * repetições)
  static Future<double> getVolumeTotalExercicio(String exercicioNome) async {
    final db = await DatabaseService.getDatabase();
    final result = await db.rawQuery('''
      SELECT SUM(peso * repeticoes) as volume_total 
      FROM logs 
      WHERE exercicio_nome = ?
    ''', [exercicioNome]);
    
    if (result.isNotEmpty && result.first['volume_total'] != null) {
      return (result.first['volume_total'] as num).toDouble();
    }
    return 0.0;
  }

  /// Busca logs agrupados por data para gráficos
  static Future<List<Map<String, dynamic>>> getLogsGroupedByDate(String exercicioNome) async {
    final db = await DatabaseService.getDatabase();
    return await db.rawQuery('''
      SELECT 
        DATE(data) as date,
        MAX(peso) as max_peso,
        SUM(peso * repeticoes) as volume,
        COUNT(*) as total_series
      FROM logs 
      WHERE exercicio_nome = ?
      GROUP BY DATE(data)
      ORDER BY date ASC
    ''', [exercicioNome]);
  }

  /// Deleta todos os logs de um exercício
  static Future<int> deleteLogsByExercicio(String exercicioNome) async {
    final db = await DatabaseService.getDatabase();
    return await db.delete(
      'logs',
      where: 'exercicio_nome = ?',
      whereArgs: [exercicioNome],
    );
  }

  /// Deleta todos os logs
  static Future<int> deleteAllLogs() async {
    final db = await DatabaseService.getDatabase();
    return await db.delete('logs');
  }

  /// Adiciona dados fictícios para teste (últimos 30 dias)
  static Future<void> addFakeData(String exercicioNome) async {
    final db = await DatabaseService.getDatabase();
    
    // Garante que a tabela existe
    await DatabaseService.ensureLogsTableExists();
    
    final now = DateTime.now();
    
    // Adiciona dados dos últimos 30 dias (com alguns dias sem treino)
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      
      // Pula alguns dias aleatoriamente (simula dias de descanso)
      if (i % 3 == 0 || i % 7 == 0) continue;
      
      // Progressão de peso: começa com 20kg e aumenta gradualmente
      final basePeso = 20.0 + (29 - i) * 0.5;
      
      // Adiciona 3-4 séries por dia
      final numSeries = 3 + (i % 2);
      
      for (int serie = 0; serie < numSeries; serie++) {
        // Varia o peso um pouco entre as séries
        final peso = basePeso + (serie * 2.5);
        // Varia as repetições entre 8-12
        final repeticoes = 8 + (serie % 5);
        
        await db.insert('logs', {
          'exercicio_nome': exercicioNome,
          'peso': peso,
          'repeticoes': repeticoes,
          'data': date.toIso8601String(),
        });
      }
    }
    
    print('Dados fictícios adicionados para $exercicioNome');
  }
}