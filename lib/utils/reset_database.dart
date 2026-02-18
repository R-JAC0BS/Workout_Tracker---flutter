import 'package:workout_tracker/data/database.dart';

/// Script para resetar o banco de dados
/// Use apenas em desenvolvimento!
Future<void> resetDatabase() async {
  print('🗑️ Deletando banco de dados...');
  await DatabaseService.deleteDatabase();
  
  print('✅ Banco deletado com sucesso!');
  print('🔄 Recriando banco de dados...');
  
  await DatabaseService.getDatabase();
  await DatabaseService.ensureLogsTableExists();
  
  print('✅ Banco recriado com sucesso!');
  print('📊 Estrutura:');
  print('   - Tabela dias (com is_cardio)');
  print('   - Tabela grupos');
  print('   - Tabela exercicios');
  print('   - Tabela series');
  print('   - Tabela logs');
  print('   - 7 dias da semana pré-populados');
}
