import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:workout_tracker/service/analysis_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseService.deleteDatabase();
  });

  group('Session Finalization Integration', () {
    test('should calculate and save metrics when finalizing session with data', () async {
      // Create a training session
      final diaId = 1;
      final sessaoId = await DatabaseService.createSessaoTreino(diaId);
      
      // Create a grupo and exercicio for testing
      final grupoId = await DatabaseService.insertGrupo(diaId: diaId, nome: 'Peito');
      final exercicioId = await DatabaseService.insertExercicio(grupoId: grupoId, nome: 'Supino');
      
      // Add some series with intensity metrics
      final serieId1 = await DatabaseService.insertSerie(exercicioId: exercicioId);
      await DatabaseService.updateSerie(
        serieId: serieId1,
        peso: 100.0,
        repeticoes: 10,
      );
      await DatabaseService.updateSerieIntensity(
        serieId: serieId1,
        rpe: 8,
        tutSegundos: 40,
        tempoDescansoSegundos: 90,
      );
      await DatabaseService.markSerieAsCompleted(serieId1, true);
      
      final serieId2 = await DatabaseService.insertSerie(exercicioId: exercicioId);
      await DatabaseService.updateSerie(
        serieId: serieId2,
        peso: 100.0,
        repeticoes: 10,
      );
      await DatabaseService.updateSerieIntensity(
        serieId: serieId2,
        rpe: 9,
        tutSegundos: 38,
        tempoDescansoSegundos: 95,
      );
      await DatabaseService.markSerieAsCompleted(serieId2, true);
      
      final serieId3 = await DatabaseService.insertSerie(exercicioId: exercicioId);
      await DatabaseService.updateSerie(
        serieId: serieId3,
        peso: 100.0,
        repeticoes: 8,
      );
      await DatabaseService.updateSerieIntensity(
        serieId: serieId3,
        rpe: 10,
        tutSegundos: 35,
        tempoDescansoSegundos: 100,
      );
      await DatabaseService.markSerieAsCompleted(serieId3, true);
      
      // Wait a bit to simulate workout duration (at least 1 second for densidade calculation)
      await Future.delayed(Duration(seconds: 1));
      
      // Calculate metrics using AnalysisService (simulating what TrainingScreen does)
      final metricas = await AnalysisService.analisarIntensidadeSessao(sessaoId);
      
      // Verify metrics were calculated
      expect(metricas.containsKey('error'), isFalse);
      expect(metricas['volume_total'], equals(2800.0)); // (100*10 + 100*10 + 100*8)
      expect(metricas['rpe_medio'], equals(9.0)); // (8+9+10)/3
      expect(metricas['tut_total'], equals(113)); // 40+38+35
      expect(metricas['tempo_descanso_medio'], equals(95.0)); // (90+95+100)/3
      expect(metricas['densidade'], greaterThan(0.0));
      expect(metricas['score_intensidade'], greaterThan(0));
      expect(metricas['score_intensidade'], lessThanOrEqualTo(100));
      
      // Finalize session with calculated metrics (simulating what TrainingScreen.dispose does)
      final volumeTotal = metricas['volume_total'] as double;
      final rpeMedio = metricas['rpe_medio'] as double;
      final densidade = metricas['densidade'] as double;
      final tutTotal = metricas['tut_total'] as int;
      final tempoDescansoMedio = metricas['tempo_descanso_medio'] as double;
      final scoreIntensidade = metricas['score_intensidade'] as int;
      
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: sessaoId,
        dataFim: DateTime.now(),
        volumeTotal: volumeTotal,
        rpeMedio: rpeMedio > 0 ? rpeMedio : null,
        densidade: densidade > 0 ? densidade : null,
        tutTotal: tutTotal > 0 ? tutTotal : null,
        tempoDescansoMedio: tempoDescansoMedio > 0 ? tempoDescansoMedio.round() : null,
        scoreIntensidade: scoreIntensidade,
      );
      
      // Verify session was finalized with all metrics
      final db = await DatabaseService.getDatabase();
      final result = await db.query(
        'sessao_treino',
        where: 'id = ?',
        whereArgs: [sessaoId],
      );
      
      expect(result.length, equals(1));
      final sessao = result.first;
      
      expect(sessao['data_fim'], isNotNull);
      expect(sessao['volume_total'], equals(2800.0));
      expect(sessao['rpe_medio'], equals(9.0));
      expect(sessao['densidade'], greaterThan(0.0));
      expect(sessao['tut_total'], equals(113));
      expect(sessao['tempo_descanso_medio'], equals(95));
      expect(sessao['score_intensidade'], greaterThan(0));
      expect(sessao['score_intensidade'], lessThanOrEqualTo(100));
    });

    test('should handle session with no series gracefully', () async {
      // Create a training session with no series
      final diaId = 2;
      final sessaoId = await DatabaseService.createSessaoTreino(diaId);
      
      // Calculate metrics (should return zeros)
      final metricas = await AnalysisService.analisarIntensidadeSessao(sessaoId);
      
      expect(metricas.containsKey('error'), isFalse);
      expect(metricas['volume_total'], equals(0.0));
      expect(metricas['rpe_medio'], equals(0.0));
      expect(metricas['tut_total'], equals(0));
      expect(metricas['tempo_descanso_medio'], equals(0.0));
      expect(metricas['densidade'], equals(0.0));
      expect(metricas['score_intensidade'], equals(0));
      
      // Finalize session
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: sessaoId,
        dataFim: DateTime.now(),
        volumeTotal: 0.0,
        scoreIntensidade: 0,
      );
      
      // Verify session was finalized
      final db = await DatabaseService.getDatabase();
      final result = await db.query(
        'sessao_treino',
        where: 'id = ?',
        whereArgs: [sessaoId],
      );
      
      expect(result.length, equals(1));
      expect(result.first['data_fim'], isNotNull);
    });

    test('should handle session with series but no intensity metrics', () async {
      // Create a training session
      final diaId = 3;
      final sessaoId = await DatabaseService.createSessaoTreino(diaId);
      
      // Create a grupo and exercicio
      final grupoId = await DatabaseService.insertGrupo(diaId: diaId, nome: 'Costas');
      final exercicioId = await DatabaseService.insertExercicio(grupoId: grupoId, nome: 'Remada');
      
      // Add series without intensity metrics (only peso and reps)
      final serieId1 = await DatabaseService.insertSerie(exercicioId: exercicioId);
      await DatabaseService.updateSerie(
        serieId: serieId1,
        peso: 80.0,
        repeticoes: 12,
      );
      await DatabaseService.markSerieAsCompleted(serieId1, true);
      
      final serieId2 = await DatabaseService.insertSerie(exercicioId: exercicioId);
      await DatabaseService.updateSerie(
        serieId: serieId2,
        peso: 80.0,
        repeticoes: 10,
      );
      await DatabaseService.markSerieAsCompleted(serieId2, true);
      
      // Calculate metrics
      final metricas = await AnalysisService.analisarIntensidadeSessao(sessaoId);
      
      // Should have volume but no intensity metrics
      expect(metricas['volume_total'], equals(1760.0)); // (80*12 + 80*10)
      expect(metricas['rpe_medio'], equals(0.0));
      expect(metricas['tut_total'], equals(0));
      expect(metricas['tempo_descanso_medio'], equals(0.0));
      
      // Finalize session
      final volumeTotal = metricas['volume_total'] as double;
      final scoreIntensidade = metricas['score_intensidade'] as int;
      
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: sessaoId,
        dataFim: DateTime.now(),
        volumeTotal: volumeTotal,
        scoreIntensidade: scoreIntensidade,
      );
      
      // Verify session was finalized
      final db = await DatabaseService.getDatabase();
      final result = await db.query(
        'sessao_treino',
        where: 'id = ?',
        whereArgs: [sessaoId],
      );
      
      expect(result.length, equals(1));
      final sessao = result.first;
      expect(sessao['data_fim'], isNotNull);
      expect(sessao['volume_total'], equals(1760.0));
      expect(sessao['rpe_medio'], isNull);
      expect(sessao['tut_total'], isNull);
      expect(sessao['tempo_descanso_medio'], isNull);
    });
  });
}
