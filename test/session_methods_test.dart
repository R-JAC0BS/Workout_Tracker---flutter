import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:workout_tracker/models/sessao_treino.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseService.deleteDatabase();
  });

  group('Session Management Methods', () {
    test('getSessaoAtivaModel should return SessaoTreino object', () async {
      // Create session
      final sessaoId = await DatabaseService.createSessaoTreino(1);
      expect(sessaoId, greaterThan(0));
      
      // Get active session as model
      final sessao = await DatabaseService.getSessaoAtivaModel(1);
      
      expect(sessao, isNotNull);
      expect(sessao, isA<SessaoTreino>());
      expect(sessao!.id, equals(sessaoId));
      expect(sessao.diaId, equals(1));
      expect(sessao.dataFim, isNull);
    });

    test('getSessaoAtivaModel should return null when no active session', () async {
      final sessao = await DatabaseService.getSessaoAtivaModel(1);
      expect(sessao, isNull);
    });

    test('getSessoesHistoricasModel should return list of SessaoTreino objects', () async {
      // Create and finalize multiple sessions
      final sessaoId1 = await DatabaseService.createSessaoTreino(1);
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: sessaoId1,
        dataFim: DateTime.now(),
        densidade: 45.5,
        scoreIntensidade: 75,
        volumeTotal: 5000.0,
        rpeMedio: 8.5,
        tutTotal: 1200,
        tempoDescansoMedio: 90,
      );

      final sessaoId2 = await DatabaseService.createSessaoTreino(2);
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: sessaoId2,
        dataFim: DateTime.now(),
        densidade: 50.0,
        scoreIntensidade: 80,
        volumeTotal: 6000.0,
        rpeMedio: 9.0,
        tutTotal: 1500,
        tempoDescansoMedio: 85,
      );

      // Get historical sessions as models
      final sessoes = await DatabaseService.getSessoesHistoricasModel(limit: 10);
      
      expect(sessoes.length, equals(2));
      expect(sessoes[0], isA<SessaoTreino>());
      expect(sessoes[1], isA<SessaoTreino>());
      
      // Verify they are ordered by date (most recent first)
      expect(sessoes[0].id, equals(sessaoId2));
      expect(sessoes[1].id, equals(sessaoId1));
      
      // Verify metrics
      expect(sessoes[0].densidade, equals(50.0));
      expect(sessoes[0].scoreIntensidade, equals(80));
      expect(sessoes[1].densidade, equals(45.5));
      expect(sessoes[1].scoreIntensidade, equals(75));
    });

    test('getSessoesHistoricasModel should filter by date range', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));
      final twoDaysAgo = now.subtract(Duration(days: 2));

      // Create sessions with different start dates
      // We need to manually insert to control data_inicio
      final db = await DatabaseService.getDatabase();
      
      final sessaoId1 = await db.insert('sessao_treino', {
        'dia_id': 1,
        'data_inicio': twoDaysAgo.toIso8601String(),
        'data_fim': twoDaysAgo.add(Duration(hours: 1)).toIso8601String(),
        'densidade': 45.5,
      });

      final sessaoId2 = await db.insert('sessao_treino', {
        'dia_id': 2,
        'data_inicio': yesterday.toIso8601String(),
        'data_fim': yesterday.add(Duration(hours: 1)).toIso8601String(),
        'densidade': 50.0,
      });

      // Get sessions from yesterday onwards
      final sessoes = await DatabaseService.getSessoesHistoricasModel(
        limit: 10,
        dataInicio: yesterday.subtract(Duration(hours: 1)),
      );
      
      // Should only get the session from yesterday
      expect(sessoes.length, equals(1));
      expect(sessoes[0].id, equals(sessaoId2));
    });

    test('getSessoesHistoricasModel should respect limit parameter', () async {
      // Create 5 sessions
      for (int i = 0; i < 5; i++) {
        final sessaoId = await DatabaseService.createSessaoTreino(i + 1);
        await DatabaseService.finalizarSessaoTreino(
          sessaoId: sessaoId,
          dataFim: DateTime.now(),
        );
      }

      // Get only 3 sessions
      final sessoes = await DatabaseService.getSessoesHistoricasModel(limit: 3);
      
      expect(sessoes.length, equals(3));
    });

    test('createSessaoTreino should return valid session ID', () async {
      final sessaoId = await DatabaseService.createSessaoTreino(1);
      
      expect(sessaoId, isA<int>());
      expect(sessaoId, greaterThan(0));
    });

    test('finalizarSessaoTreino should update all metrics', () async {
      final sessaoId = await DatabaseService.createSessaoTreino(1);
      final dataFim = DateTime.now();
      
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: sessaoId,
        dataFim: dataFim,
        densidade: 45.5,
        scoreIntensidade: 75,
        volumeTotal: 5000.0,
        rpeMedio: 8.5,
        tutTotal: 1200,
        tempoDescansoMedio: 90,
      );

      final sessao = await DatabaseService.getSessaoAtivaModel(1);
      
      // Session should no longer be active after finalization
      expect(sessao, isNull);
      
      // Get from historical sessions
      final sessoes = await DatabaseService.getSessoesHistoricasModel(limit: 1);
      expect(sessoes.length, equals(1));
      
      final finalizedSessao = sessoes[0];
      expect(finalizedSessao.dataFim, isNotNull);
      expect(finalizedSessao.densidade, equals(45.5));
      expect(finalizedSessao.scoreIntensidade, equals(75));
      expect(finalizedSessao.volumeTotal, equals(5000.0));
      expect(finalizedSessao.rpeMedio, equals(8.5));
      expect(finalizedSessao.tutTotal, equals(1200));
      expect(finalizedSessao.tempoDescansoMedio, equals(90));
    });
  });
}
