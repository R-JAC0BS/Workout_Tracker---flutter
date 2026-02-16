import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  /// Retorna a instância do banco (singleton)
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'treinos.db');

    _database = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        // Ativa as foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Criar tabelas
        await db.execute('''
          CREATE TABLE dias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL
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
            FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
          );
        ''');

        // Pré-popular os 7 dias da semana
        final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
        for (final dia in dias) {
          await db.insert('dias', {'nome': dia});
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
    });
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

  // Função para listar todos os grupos (debug)
  static Future<List<Map<String, dynamic>>> getAllGrupos() async {
    final db = await getDatabase();
    return await db.query('grupos');
  }
}
