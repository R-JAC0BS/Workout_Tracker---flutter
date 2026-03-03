import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_tracker/service/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseService.deleteDatabase();
  });

  group('TrainingScreen Session Integration', () {
    test('should create new session when none exists', () async {
      // Use diaId 1 (dias are pre-populated in the database)
      final diaId = 1;
      
      // Verify no active session exists
      final sessaoAntes = await DatabaseService.getSessaoAtiva(diaId);
      expect(sessaoAntes, isNull);
      
      // Simulate what TrainingScreen does: check for active session, create if none
      var sessaoAtiva = await DatabaseService.getSessaoAtiva(diaId);
      int? sessaoId;
      
      if (sessaoAtiva != null) {
        sessaoId = sessaoAtiva['id'] as int;
      } else {
        sessaoId = await DatabaseService.createSessaoTreino(diaId);
      }
      
      // Verify session was created
      expect(sessaoId, isNotNull);
      expect(sessaoId, greaterThan(0));
      
      // Verify session is now active
      final sessaoDepois = await DatabaseService.getSessaoAtiva(diaId);
      expect(sessaoDepois, isNotNull);
      expect(sessaoDepois!['id'], equals(sessaoId));
      expect(sessaoDepois['dia_id'], equals(diaId));
    });

    test('should reuse existing active session', () async {
      // Use diaId 2
      final diaId = 2;
      
      // Create an initial session
      final primeiroSessaoId = await DatabaseService.createSessaoTreino(diaId);
      
      // Simulate what TrainingScreen does: check for active session, create if none
      var sessaoAtiva = await DatabaseService.getSessaoAtiva(diaId);
      int? sessaoId;
      
      if (sessaoAtiva != null) {
        sessaoId = sessaoAtiva['id'] as int;
      } else {
        sessaoId = await DatabaseService.createSessaoTreino(diaId);
      }
      
      // Verify the same session ID is reused
      expect(sessaoId, equals(primeiroSessaoId));
      
      // Verify only one active session exists for this dia
      final sessaoAtiva2 = await DatabaseService.getSessaoAtiva(diaId);
      expect(sessaoAtiva2, isNotNull);
      expect(sessaoAtiva2!['id'], equals(primeiroSessaoId));
    });

    test('should create new session after previous one is finalized', () async {
      // Use diaId 3
      final diaId = 3;
      
      // Create and finalize a session
      final primeiroSessaoId = await DatabaseService.createSessaoTreino(diaId);
      await DatabaseService.finalizarSessaoTreino(
        sessaoId: primeiroSessaoId,
        dataFim: DateTime.now(),
      );
      
      // Simulate what TrainingScreen does: check for active session, create if none
      var sessaoAtiva = await DatabaseService.getSessaoAtiva(diaId);
      int? sessaoId;
      
      if (sessaoAtiva != null) {
        sessaoId = sessaoAtiva['id'] as int;
      } else {
        sessaoId = await DatabaseService.createSessaoTreino(diaId);
      }
      
      // Verify a new session was created
      expect(sessaoId, isNotNull);
      expect(sessaoId, isNot(equals(primeiroSessaoId)));
      
      // Verify the new session is active
      final sessaoNova = await DatabaseService.getSessaoAtiva(diaId);
      expect(sessaoNova, isNotNull);
      expect(sessaoNova!['id'], equals(sessaoId));
    });
  });
}
