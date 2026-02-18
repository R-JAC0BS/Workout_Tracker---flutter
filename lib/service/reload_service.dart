import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_tracker/service/database_service.dart';

class ReloadData {
  static const String _lastResetKey = 'last_reset_date';

  /// Verifica se é uma nova segunda-feira e reseta os dados se necessário
  static Future<void> checkAndResetWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Pega a última data de reset
    final lastResetString = prefs.getString(_lastResetKey);
    final lastReset = lastResetString != null 
        ? DateTime.parse(lastResetString) 
        : null;

    // Verifica se hoje é segunda-feira (weekday == 1)
    if (now.weekday == DateTime.monday) {
      // Se nunca resetou ou se a última segunda-feira foi em outra semana
      if (lastReset == null || !_isSameWeek(lastReset, now)) {
        await _resetAllCompletedStatus();
        await prefs.setString(_lastResetKey, now.toIso8601String());
      }
    }
  }

  /// Verifica se duas datas estão na mesma semana
  static bool _isSameWeek(DateTime date1, DateTime date2) {
    // Calcula o início da semana (segunda-feira) para cada data
    final startOfWeek1 = _getStartOfWeek(date1);
    final startOfWeek2 = _getStartOfWeek(date2);
    
    return startOfWeek1.isAtSameMomentAs(startOfWeek2);
  }

  /// Retorna o início da semana (segunda-feira às 00:00)
  static DateTime _getStartOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - DateTime.monday;
    final monday = date.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Reseta todos os status de completado (dias e séries)
  static Future<void> _resetAllCompletedStatus() async {
    final db = await DatabaseService.getDatabase();
    
    // Reseta is_completed de todos os dias
    await db.update(
      'dias',
      {'is_completed': 0},
    );
    
    // Reseta is_completed de todas as séries
    await db.update(
      'series',
      {'is_completed': 0},
    );
  }

  /// Força um reset manual (útil para testes)
  static Future<void> forceReset() async {
    await _resetAllCompletedStatus();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResetKey, DateTime.now().toIso8601String());
  }
}
