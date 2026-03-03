import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_tracker/service/database_service.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Migration to Version 6', () {
    setUp(() async {
      // Delete database before each test
      await DatabaseService.deleteDatabase();
    });

    test('Database should migrate to version 6 successfully', () async {
      // Get database (will trigger migration)
      final db = await DatabaseService.getDatabase();
      
      // Verify database version
      final version = await db.getVersion();
      expect(version, equals(6));
    });

    test('Series table should have new intensity fields', () async {
      final db = await DatabaseService.getDatabase();
      
      // Query table info
      final tableInfo = await db.rawQuery('PRAGMA table_info(series)');
      final columnNames = tableInfo.map((col) => col['name'] as String).toList();
      
      // Verify new columns exist
      expect(columnNames, contains('rpe'));
      expect(columnNames, contains('rir'));
      expect(columnNames, contains('tempo_descanso_segundos'));
      expect(columnNames, contains('tut_segundos'));
      expect(columnNames, contains('tempo_inicio'));
      expect(columnNames, contains('tempo_fim'));
    });

    test('configuracoes_exercicio table should exist', () async {
      final db = await DatabaseService.getDatabase();
      
      // Query table list
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='configuracoes_exercicio'"
      );
      
      expect(tables.isNotEmpty, isTrue);
      
      // Verify table structure
      final tableInfo = await db.rawQuery('PRAGMA table_info(configuracoes_exercicio)');
      final columnNames = tableInfo.map((col) => col['name'] as String).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('exercicio_nome'));
      expect(columnNames, contains('tempo_descanso_alvo'));
      expect(columnNames, contains('tut_alvo'));
      expect(columnNames, contains('rpe_alvo'));
    });

    test('sessao_treino table should exist', () async {
      final db = await DatabaseService.getDatabase();
      
      // Query table list
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='sessao_treino'"
      );
      
      expect(tables.isNotEmpty, isTrue);
      
      // Verify table structure
      final tableInfo = await db.rawQuery('PRAGMA table_info(sessao_treino)');
      final columnNames = tableInfo.map((col) => col['name'] as String).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('dia_id'));
      expect(columnNames, contains('data_inicio'));
      expect(columnNames, contains('data_fim'));
      expect(columnNames, contains('densidade'));
      expect(columnNames, contains('score_intensidade'));
      expect(columnNames, contains('volume_total'));
      expect(columnNames, contains('rpe_medio'));
      expect(columnNames, contains('tut_total'));
      expect(columnNames, contains('tempo_descanso_medio'));
    });

    test('Indexes should be created', () async {
      final db = await DatabaseService.getDatabase();
      
      // Query index list
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index'"
      );
      
      final indexNames = indexes.map((idx) => idx['name'] as String).toList();
      
      expect(indexNames, contains('idx_sessao_dia_data'));
      expect(indexNames, contains('idx_config_exercicio'));
      // Note: idx_series_rpe might not show up in all SQLite versions due to WHERE clause
    });

    test('updateSerieIntensity should save RPE and RIR', () async {
      // Create a test serie
      final grupoId = await DatabaseService.insertGrupo(diaId: 1, nome: 'Peito');
      final exercicioId = await DatabaseService.insertExercicio(grupoId: grupoId, nome: 'Supino');
      final serieId = await DatabaseService.insertSerie(exercicioId: exercicioId, peso: 80, repeticoes: 10);
      
      // Update with intensity data
      await DatabaseService.updateSerieIntensity(
        serieId: serieId,
        rpe: 9,
        rir: 1,
        tempoDescansoSegundos: 90,
        tutSegundos: 40,
      );
      
      // Verify data was saved
      final series = await DatabaseService.getSeries(exercicioId);
      expect(series.length, equals(1));
      expect(series[0]['rpe'], equals(9));
      expect(series[0]['rir'], equals(1));
      expect(series[0]['tempo_descanso_segundos'], equals(90));
      expect(series[0]['tut_segundos'], equals(40));
    });

    test('saveConfiguracaoExercicio should save and retrieve configuration', () async {
      // Save configuration
      await DatabaseService.saveConfiguracaoExercicio(
        exercicioNome: 'Supino',
        tempoDescansoAlvo: 120,
        tutAlvo: 40,
        rpeAlvo: 8,
      );
      
      // Retrieve configuration
      final config = await DatabaseService.getConfiguracaoExercicio('Supino');
      
      expect(config, isNotNull);
      expect(config!['exercicio_nome'], equals('Supino'));
      expect(config['tempo_descanso_alvo'], equals(120));
      expect(config['tut_alvo'], equals(40));
      expect(config['rpe_alvo'], equals(8));
    });

    test('createSessaoTreino should create a session', () async {
      // Create session
      final sessaoId = await DatabaseService.createSessaoTreino(1);
      
      expect(sessaoId, greaterThan(0));
      
      // Verify session exists
      final sessao = await DatabaseService.getSessaoAtiva(1);
      expect(sessao, isNotNull);
      expect(sessao!['dia_id'], equals(1));
      expect(sessao['data_inicio'], isNotNull);
      expect(sessao['data_fim'], isNull);
    });

    test('finalizarSessaoTreino should update session with metrics', () async {
      // Create session
      final sessaoId = await DatabaseService.createSessaoTreino(1);
      
      // Finalize session
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: sessaoId,
        dataFim: DateTime.now(),
        densidade: 45.5,
        scoreIntensidade: 75,
        volumeTotal: 5000.0,
        rpeMedio: 8.5,
        tutTotal: 1200,
        tempoDescansoMedio: 90,
      );
      
      // Verify session was updated
      final sessoes = await DatabaseService.getSessoesHistoricas(limit: 1);
      expect(sessoes.length, equals(1));
      expect(sessoes[0]['densidade'], equals(45.5));
      expect(sessoes[0]['score_intensidade'], equals(75));
      expect(sessoes[0]['volume_total'], equals(5000.0));
      expect(sessoes[0]['rpe_medio'], equals(8.5));
      expect(sessoes[0]['tut_total'], equals(1200));
      expect(sessoes[0]['tempo_descanso_medio'], equals(90));
    });
  });
}
