import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sessao_treino.dart';

class DatabaseService {
  static Database? _database;

  /// Função para deletar o banco de dados (útil para desenvolvimento)
  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'treinos.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Verifica se a tabela de logs existe e cria se necessário
  static Future<void> ensureLogsTableExists() async {
    final db = await getDatabase();
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exercicio_nome TEXT NOT NULL,
          peso REAL NOT NULL,
          repeticoes INTEGER NOT NULL,
          data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');
    } catch (e) {
      // Tabela já existe ou erro
    }
  }

  /// Retorna a instância do banco (singleton)
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'treinos.db');

    _database = await openDatabase(
      path,
      version: 6,
      onConfigure: (db) async {
        // Ativa as foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Criar tabelas
        await db.execute('''
          CREATE TABLE dias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT,
            is_completed INTEGER NOT NULL DEFAULT 0,
            is_cardio INTEGER NOT NULL DEFAULT 0
          );
        ''');

        await db.execute('''
          CREATE TABLE grupos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dia_id INTEGER NOT NULL,
            nome TEXT NOT NULL,
            FOREIGN KEY (dia_id) REFERENCES dias(id) ON DELETE CASCADE
          );
        ''');

        await db.execute('''
          CREATE TABLE exercicios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            grupo_id INTEGER NOT NULL,
            nome TEXT NOT NULL,
            FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE CASCADE
          );
        ''');

        await db.execute('''
          CREATE TABLE series (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercicio_id INTEGER NOT NULL,
            peso REAL,
            repeticoes INTEGER,
            is_completed INTEGER NOT NULL DEFAULT 0,
            rpe INTEGER,
            rir INTEGER,
            tempo_descanso_segundos INTEGER,
            tut_segundos INTEGER,
            tempo_inicio TEXT,
            tempo_fim TEXT,
            FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
          );
        ''');

        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercicio_nome TEXT NOT NULL,
            peso REAL NOT NULL,
            repeticoes INTEGER NOT NULL,
            data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );
        ''');

        await db.execute('''
          CREATE TABLE configuracoes_exercicio (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercicio_nome TEXT NOT NULL UNIQUE,
            tempo_descanso_alvo INTEGER,
            tut_alvo INTEGER,
            rpe_alvo INTEGER
          );
        ''');

        await db.execute('''
          CREATE TABLE sessao_treino (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dia_id INTEGER NOT NULL,
            data_inicio TEXT NOT NULL,
            data_fim TEXT,
            densidade REAL,
            score_intensidade INTEGER,
            volume_total REAL,
            rpe_medio REAL,
            tut_total INTEGER,
            tempo_descanso_medio INTEGER,
            FOREIGN KEY (dia_id) REFERENCES dias(id) ON DELETE CASCADE
          );
        ''');

        // Create indexes
        await db.execute('CREATE INDEX idx_sessao_dia_data ON sessao_treino(dia_id, data_inicio)');
        await db.execute('CREATE INDEX idx_config_exercicio ON configuracoes_exercicio(exercicio_nome)');

        // Pré-popular os 7 dias da semana
        final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
        for (final dia in dias) {
          await db.insert('dias', {'nome': dia, 'descricao': '', 'is_completed': 0, 'is_cardio': 0});
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Adicionar novos campos às tabelas existentes
          try {
            await db.execute('ALTER TABLE dias ADD COLUMN descricao TEXT');
          } catch (e) {
            // Coluna já existe
          }
          try {
            await db.execute('ALTER TABLE dias ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0');
          } catch (e) {
            // Coluna já existe
          }
          try {
            await db.execute('ALTER TABLE series ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0');
          } catch (e) {
            // Coluna já existe
          }
        }
        if (oldVersion < 4) {
          // Criar tabela de logs
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                exercicio_nome TEXT NOT NULL,
                peso REAL NOT NULL,
                repeticoes INTEGER NOT NULL,
                data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
              );
            ''');
          } catch (e) {
            // Tabela já existe
          }
        }
        if (oldVersion < 5) {
          // Adicionar campo is_cardio
          try {
            await db.execute('ALTER TABLE dias ADD COLUMN is_cardio INTEGER NOT NULL DEFAULT 0');
          } catch (e) {
            // Coluna já existe
          }
        }
        if (oldVersion < 6) {
          // Adicionar campos de intensidade à tabela series
          try {
            await db.execute('ALTER TABLE series ADD COLUMN rpe INTEGER');
          } catch (e) {
            // Coluna já existe
          }
          try {
            await db.execute('ALTER TABLE series ADD COLUMN rir INTEGER');
          } catch (e) {
            // Coluna já existe
          }
          try {
            await db.execute('ALTER TABLE series ADD COLUMN tempo_descanso_segundos INTEGER');
          } catch (e) {
            // Coluna já existe
          }
          try {
            await db.execute('ALTER TABLE series ADD COLUMN tut_segundos INTEGER');
          } catch (e) {
            // Coluna já existe
          }
          try {
            await db.execute('ALTER TABLE series ADD COLUMN tempo_inicio TEXT');
          } catch (e) {
            // Coluna já existe
          }
          try {
            await db.execute('ALTER TABLE series ADD COLUMN tempo_fim TEXT');
          } catch (e) {
            // Coluna já existe
          }
          
          // Criar tabela de configurações por exercício
          try {
            await db.execute('''
              CREATE TABLE configuracoes_exercicio (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                exercicio_nome TEXT NOT NULL UNIQUE,
                tempo_descanso_alvo INTEGER,
                tut_alvo INTEGER,
                rpe_alvo INTEGER
              )
            ''');
          } catch (e) {
            // Tabela já existe
          }
          
          // Criar tabela de sessões de treino
          try {
            await db.execute('''
              CREATE TABLE sessao_treino (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                dia_id INTEGER NOT NULL,
                data_inicio TEXT NOT NULL,
                data_fim TEXT,
                densidade REAL,
                score_intensidade INTEGER,
                volume_total REAL,
                rpe_medio REAL,
                tut_total INTEGER,
                tempo_descanso_medio INTEGER,
                FOREIGN KEY (dia_id) REFERENCES dias(id) ON DELETE CASCADE
              )
            ''');
          } catch (e) {
            // Tabela já existe
          }
          
          // Adicionar índices para otimização de queries
          try {
            await db.execute('CREATE INDEX idx_sessao_dia_data ON sessao_treino(dia_id, data_inicio)');
          } catch (e) {
            // Índice já existe
          }
          try {
            await db.execute('CREATE INDEX idx_series_rpe ON series(exercicio_id, rpe) WHERE rpe IS NOT NULL');
          } catch (e) {
            // Índice já existe
          }
          try {
            await db.execute('CREATE INDEX idx_config_exercicio ON configuracoes_exercicio(exercicio_nome)');
          } catch (e) {
            // Índice já existe
          }
        }
      },
    );

    return _database!;
  }

  // ----------------------
  // Funções de inserção
  // ----------------------

  // Grupos
  static Future<int> insertGrupo({
    required int diaId,
    required String nome,
  }) async {
    final db = await getDatabase();
    return await db.insert('grupos', {'dia_id': diaId, 'nome': nome});
  }

  // Exercícios
  static Future<int> insertExercicio({
    required int grupoId,
    required String nome,
  }) async {
    final db = await getDatabase();
    return await db.insert('exercicios', {'grupo_id': grupoId, 'nome': nome});
  }

  // Séries
  static Future<int> insertSerie({
    required int exercicioId,
    double? peso,
    int? repeticoes,
  }) async {
    final db = await getDatabase();
    return await db.insert('series', {
      'exercicio_id': exercicioId,
      'peso': peso ?? 0,
      'repeticoes': repeticoes ?? 0,
      'is_completed': 0,
    });
  }

  // ----------------------
  // Funções de deleção
  // ----------------------

  // Deletar exercício
  static Future<int> deleteExercicio(int exercicioId) async {
    final db = await getDatabase();
    return await db.delete('exercicios', where: 'id = ?', whereArgs: [exercicioId]);
  }

  // Deletar série
  static Future<int> deleteSerie(int serieId) async {
    final db = await getDatabase();
    return await db.delete('series', where: 'id = ?', whereArgs: [serieId]);
  }

  // Deletar grupo
  static Future<int> deleteGrupo(int grupoId) async {
    final db = await getDatabase();
    return await db.delete('grupos', where: 'id = ?', whereArgs: [grupoId]);
  }

  // ----------------------
  // Funções de atualização
  // ----------------------

  // Atualizar nome do grupo muscular
  static Future<int> updateGrupoNome(int grupoId, String novoNome) async {
    final db = await getDatabase();
    return await db.update(
      'grupos',
      {'nome': novoNome},
      where: 'id = ?',
      whereArgs: [grupoId],
    );
  }

  // Atualizar nome do exercício
  static Future<int> updateExercicioNome(int exercicioId, String novoNome) async {
    final db = await getDatabase();
    return await db.update(
      'exercicios',
      {'nome': novoNome},
      where: 'id = ?',
      whereArgs: [exercicioId],
    );
  }

  // Funções de leitura (opcional)
  static Future<List<Map<String, dynamic>>> getDias() async {
    final db = await getDatabase();
    return await db.query('dias');
  }

  static Future<List<Map<String, dynamic>>> getGrupos(int diaId) async {
    final db = await getDatabase();
    return await db.query('grupos', where: 'dia_id = ?', whereArgs: [diaId]);
  }

  static Future<List<Map<String, dynamic>>> getExercicios(int grupoId) async {
    final db = await getDatabase();
    return await db.query('exercicios', where: 'grupo_id = ?', whereArgs: [grupoId]);
  }

  static Future<List<Map<String, dynamic>>> getSeries(int exercicioId) async {
    final db = await getDatabase();
    return await db.query('series', where: 'exercicio_id = ?', whereArgs: [exercicioId]);
  }

  // Função auxiliar para verificar se um grupo existe
  static Future<bool> grupoExists(int grupoId) async {
    final db = await getDatabase();
    final result = await db.query('grupos', where: 'id = ?', whereArgs: [grupoId]);
    return result.isNotEmpty;
  }

  // Função para obter o diaId a partir de um exercicioId
  static Future<int?> getDiaIdFromExercicio(int exercicioId) async {
    final db = await getDatabase();
    final result = await db.rawQuery('''
      SELECT dias.id 
      FROM dias 
      INNER JOIN grupos ON dias.id = grupos.dia_id 
      INNER JOIN exercicios ON grupos.id = exercicios.grupo_id 
      WHERE exercicios.id = ?
    ''', [exercicioId]);
    
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;
  }

  // Função para listar todos os grupos (debug)
  static Future<List<Map<String, dynamic>>> getAllGrupos() async {
    final db = await getDatabase();
    return await db.query('grupos');
  }

  // Função para atualizar uma série
  static Future<int> updateSerie({
    required int serieId,
    required double peso,
    required int repeticoes,
  }) async {
    final db = await getDatabase();
    return await db.update(
      'series',
      {'peso': peso, 'repeticoes': repeticoes},
      where: 'id = ?',
      whereArgs: [serieId],
    );
  }

  // Função para marcar série como completa
  static Future<int> markSerieAsCompleted(int serieId, bool isCompleted) async {
    final db = await getDatabase();
    return await db.update(
      'series',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [serieId],
    );
  }

  // Função para marcar dia como completo
  static Future<int> markDiaAsCompleted(int diaId, bool isCompleted) async {
    final db = await getDatabase();
    return await db.update(
      'dias',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [diaId],
    );
  }

  // Função para atualizar descrição do dia
  static Future<int> updateDiaDescricao(int diaId, String descricao) async {
    final db = await getDatabase();
    // Limita a descrição a 30 caracteres
    final descricaoLimitada = descricao.length > 30 ? descricao.substring(0, 30) : descricao;
    return await db.update(
      'dias',
      {'descricao': descricaoLimitada},
      where: 'id = ?',
      whereArgs: [diaId],
    );
  }

  // Função para atualizar status de cardio do dia
  static Future<int> updateDiaCardio(int diaId, bool isCardio) async {
    final db = await getDatabase();
    return await db.update(
      'dias',
      {'is_cardio': isCardio ? 1 : 0},
      where: 'id = ?',
      whereArgs: [diaId],
    );
  }

  // Função para buscar os 3 primeiros exercícios de um dia
  static Future<List<String>> getFirst3ExerciciosFromDia(int diaId) async {
    final db = await getDatabase();
    
    final result = await db.rawQuery('''
      SELECT exercicios.nome 
      FROM exercicios 
      INNER JOIN grupos ON exercicios.grupo_id = grupos.id 
      WHERE grupos.dia_id = ?
      LIMIT 3
    ''', [diaId]);
    
    return result.map((e) => e['nome'] as String).toList();
  }

  // Função para calcular o volume total de um dia (soma de peso * repetições)
  static Future<double> getVolumeTotalDia(int diaId) async {
    final db = await getDatabase();
    
    final result = await db.rawQuery('''
      SELECT SUM(series.peso * series.repeticoes) as volume_total
      FROM series
      INNER JOIN exercicios ON series.exercicio_id = exercicios.id
      INNER JOIN grupos ON exercicios.grupo_id = grupos.id
      WHERE grupos.dia_id = ?
    ''', [diaId]);
    
    if (result.isNotEmpty && result.first['volume_total'] != null) {
      return (result.first['volume_total'] as num).toDouble();
    }
    return 0.0;
  }

  // Função para calcular o tempo estimado de treino (2 min por série: 1min30s descanso + 30s execução)
  static Future<int> getTempoEstimadoDia(int diaId) async {
    final db = await getDatabase();
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as total_series
      FROM series
      INNER JOIN exercicios ON series.exercicio_id = exercicios.id
      INNER JOIN grupos ON exercicios.grupo_id = grupos.id
      WHERE grupos.dia_id = ?
    ''', [diaId]);
    
    if (result.isNotEmpty && result.first['total_series'] != null) {
      final totalSeries = result.first['total_series'] as int;
      return (totalSeries * 2).round(); // 2 minutos por série (1min30s descanso + 30s execução)
    }
    return 0;
  }

  // Função para verificar e atualizar o status do dia baseado nas séries
  static Future<void> checkAndUpdateDiaStatus(int diaId) async {
    final db = await getDatabase();
    
    // Buscar todos os grupos do dia
    final grupos = await db.query('grupos', where: 'dia_id = ?', whereArgs: [diaId]);
    
    if (grupos.isEmpty) {
      // Se não há grupos, marca o dia como incompleto
      await markDiaAsCompleted(diaId, false);
      return;
    }
    
    // Para cada grupo, buscar exercícios
    for (final grupo in grupos) {
      final exercicios = await db.query('exercicios', where: 'grupo_id = ?', whereArgs: [grupo['id']]);
      
      if (exercicios.isEmpty) {
        // Se algum grupo não tem exercícios, dia incompleto
        await markDiaAsCompleted(diaId, false);
        return;
      }
      
      // Para cada exercício, buscar séries
      for (final exercicio in exercicios) {
        final series = await db.query('series', where: 'exercicio_id = ?', whereArgs: [exercicio['id']]);
        
        if (series.isEmpty) {
          // Se algum exercício não tem séries, dia incompleto
          await markDiaAsCompleted(diaId, false);
          return;
        }
        
        // Verificar se todas as séries estão completas
        for (final serie in series) {
          if (serie['is_completed'] == 0) {
            // Se alguma série não está completa, dia incompleto
            await markDiaAsCompleted(diaId, false);
            return;
          }
        }
      }
    }
    
    // Se chegou aqui, todas as séries de todos os exercícios estão completas
    await markDiaAsCompleted(diaId, true);
  }

  // Função para buscar o nome do grupo muscular a partir do exercício
  static Future<String> getGrupoMuscularFromExercicio(int exercicioId) async {
    final db = await getDatabase();
    final result = await db.rawQuery('''
      SELECT grupos.nome 
      FROM grupos 
      INNER JOIN exercicios ON grupos.id = exercicios.grupo_id 
      WHERE exercicios.id = ?
    ''', [exercicioId]);
    
    if (result.isNotEmpty) {
      return result.first['nome'] as String;
    }
    return 'Não definido';
  }

  // ----------------------
  // Funções de intensidade (versão 6)
  // ----------------------

  // Atualizar série com campos de intensidade
  static Future<int> updateSerieIntensity({
    required int serieId,
    int? rpe,
    int? rir,
    int? tempoDescansoSegundos,
    int? tutSegundos,
    DateTime? tempoInicio,
    DateTime? tempoFim,
  }) async {
    final db = await getDatabase();
    final Map<String, dynamic> values = {};
    
    if (rpe != null) values['rpe'] = rpe;
    if (rir != null) values['rir'] = rir;
    if (tempoDescansoSegundos != null) values['tempo_descanso_segundos'] = tempoDescansoSegundos;
    if (tutSegundos != null) values['tut_segundos'] = tutSegundos;
    if (tempoInicio != null) values['tempo_inicio'] = tempoInicio.toIso8601String();
    if (tempoFim != null) values['tempo_fim'] = tempoFim.toIso8601String();
    
    if (values.isEmpty) return 0;
    
    return await db.update(
      'series',
      values,
      where: 'id = ?',
      whereArgs: [serieId],
    );
  }

  // Salvar configuração de exercício
  static Future<int> saveConfiguracaoExercicio({
    required String exercicioNome,
    int? tempoDescansoAlvo,
    int? tutAlvo,
    int? rpeAlvo,
  }) async {
    final db = await getDatabase();
    
    // Verificar se já existe configuração
    final existing = await db.query(
      'configuracoes_exercicio',
      where: 'exercicio_nome = ?',
      whereArgs: [exercicioNome],
    );
    
    final Map<String, dynamic> values = {
      'exercicio_nome': exercicioNome,
      'tempo_descanso_alvo': tempoDescansoAlvo,
      'tut_alvo': tutAlvo,
      'rpe_alvo': rpeAlvo,
    };
    
    if (existing.isNotEmpty) {
      // Atualizar
      return await db.update(
        'configuracoes_exercicio',
        values,
        where: 'exercicio_nome = ?',
        whereArgs: [exercicioNome],
      );
    } else {
      // Inserir
      return await db.insert('configuracoes_exercicio', values);
    }
  }

  // Buscar configuração de exercício
  static Future<Map<String, dynamic>?> getConfiguracaoExercicio(String exercicioNome) async {
    final db = await getDatabase();
    final result = await db.query(
      'configuracoes_exercicio',
      where: 'exercicio_nome = ?',
      whereArgs: [exercicioNome],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Criar sessão de treino
  static Future<int> createSessaoTreino(int diaId) async {
    final db = await getDatabase();
    return await db.insert('sessao_treino', {
      'dia_id': diaId,
      'data_inicio': DateTime.now().toIso8601String(),
    });
  }

  // Finalizar sessão de treino
  static Future<int> finalizarSessaoTreino({
    required int sessaoId,
    required DateTime dataFim,
    double? densidade,
    int? scoreIntensidade,
    double? volumeTotal,
    double? rpeMedio,
    int? tutTotal,
    int? tempoDescansoMedio,
  }) async {
    final db = await getDatabase();
    
    final Map<String, dynamic> values = {
      'data_fim': dataFim.toIso8601String(),
    };
    
    if (densidade != null) values['densidade'] = densidade;
    if (scoreIntensidade != null) values['score_intensidade'] = scoreIntensidade;
    if (volumeTotal != null) values['volume_total'] = volumeTotal;
    if (rpeMedio != null) values['rpe_medio'] = rpeMedio;
    if (tutTotal != null) values['tut_total'] = tutTotal;
    if (tempoDescansoMedio != null) values['tempo_descanso_medio'] = tempoDescansoMedio;
    
    return await db.update(
      'sessao_treino',
      values,
      where: 'id = ?',
      whereArgs: [sessaoId],
    );
  }

  // Buscar sessão ativa de um dia
  static Future<Map<String, dynamic>?> getSessaoAtiva(int diaId) async {
    final db = await getDatabase();
    final result = await db.query(
      'sessao_treino',
      where: 'dia_id = ? AND data_fim IS NULL',
      whereArgs: [diaId],
      orderBy: 'data_inicio DESC',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Buscar sessão ativa de um dia (retorna modelo SessaoTreino)
  static Future<SessaoTreino?> getSessaoAtivaModel(int diaId) async {
    final map = await getSessaoAtiva(diaId);
    if (map != null) {
      return SessaoTreino.fromMap(map);
    }
    return null;
  }

  // Buscar sessões históricas
  static Future<List<Map<String, dynamic>>> getSessoesHistoricas({
    int limit = 10,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final db = await getDatabase();
    
    String whereClause = 'data_fim IS NOT NULL';
    List<dynamic> whereArgs = [];
    
    if (dataInicio != null) {
      whereClause += ' AND data_inicio >= ?';
      whereArgs.add(dataInicio.toIso8601String());
    }
    
    if (dataFim != null) {
      whereClause += ' AND data_inicio <= ?';
      whereArgs.add(dataFim.toIso8601String());
    }
    
    return await db.query(
      'sessao_treino',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'data_inicio DESC',
      limit: limit,
    );
  }

  // Buscar sessões históricas (retorna lista de modelos SessaoTreino)
  static Future<List<SessaoTreino>> getSessoesHistoricasModel({
    int limit = 10,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final maps = await getSessoesHistoricas(
      limit: limit,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
    return maps.map((map) => SessaoTreino.fromMap(map)).toList();
  }
}
