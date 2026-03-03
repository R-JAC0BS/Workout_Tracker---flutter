import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

/// Serviço para gerenciar configurações de intensidade do usuário
/// 
/// Gerencia duas categorias de configurações:
/// 1. Configurações globais (SharedPreferences): preferências gerais do app
/// 2. Configurações por exercício (Database): alvos específicos de cada exercício
class ConfigService {
  // ----------------------
  // Configurações por exercício (Database)
  // ----------------------

  /// Salva tempo de descanso alvo para um exercício específico
  /// 
  /// @param exercicioNome Nome do exercício
  /// @param segundos Tempo alvo em segundos (30-300)
  static Future<void> salvarTempoDescansoAlvo(String exercicioNome, int segundos) async {
    final config = await DatabaseService.getConfiguracaoExercicio(exercicioNome);
    
    await DatabaseService.saveConfiguracaoExercicio(
      exercicioNome: exercicioNome,
      tempoDescansoAlvo: segundos,
      rpeAlvo: config?['rpe_alvo'] as int?,
    );
  }

  /// Busca tempo de descanso alvo configurado para um exercício
  /// 
  /// @param exercicioNome Nome do exercício
  /// @return Tempo em segundos, ou null se não configurado
  static Future<int?> getTempoDescansoAlvo(String exercicioNome) async {
    final config = await DatabaseService.getConfiguracaoExercicio(exercicioNome);
    return config?['tempo_descanso_alvo'] as int?;
  }

  /// Salva RPE (Rate of Perceived Exertion) alvo para um exercício específico
  /// 
  /// @param exercicioNome Nome do exercício
  /// @param rpe RPE alvo (1-10)
  static Future<void> salvarRPEAlvo(String exercicioNome, int rpe) async {
    final config = await DatabaseService.getConfiguracaoExercicio(exercicioNome);
    
    await DatabaseService.saveConfiguracaoExercicio(
      exercicioNome: exercicioNome,
      tempoDescansoAlvo: config?['tempo_descanso_alvo'] as int?,
      rpeAlvo: rpe,
    );
  }

  /// Busca RPE alvo configurado para um exercício
  /// 
  /// @param exercicioNome Nome do exercício
  /// @return RPE alvo (1-10), ou null se não configurado
  static Future<int?> getRPEAlvo(String exercicioNome) async {
    final config = await DatabaseService.getConfiguracaoExercicio(exercicioNome);
    return config?['rpe_alvo'] as int?;
  }

  // ----------------------
  // Configurações globais (SharedPreferences)
  // ----------------------

  // Chaves para SharedPreferences
  static const String _keyUsarRPE = 'usar_rpe';
  static const String _keyUsarRIR = 'usar_rir';
  static const String _keyCronometroAutomatico = 'cronometro_automatico';
  static const String _keyNotificacaoDescanso = 'notificacao_descanso';
  static const String _keyTempoDescansoDefault = 'tempo_descanso_default';

  /// Define se o usuário quer usar RPE (Rate of Perceived Exertion)
  /// 
  /// @param usar true para habilitar, false para desabilitar
  static Future<void> setUsarRPE(bool usar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUsarRPE, usar);
  }

  /// Verifica se o usuário quer usar RPE
  /// 
  /// @return true se habilitado (padrão: true)
  static Future<bool> getUsarRPE() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUsarRPE) ?? true; // Padrão: true
  }

  /// Define se o usuário quer usar RIR (Reps in Reserve)
  /// 
  /// @param usar true para habilitar, false para desabilitar
  static Future<void> setUsarRIR(bool usar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUsarRIR, usar);
  }

  /// Verifica se o usuário quer usar RIR
  /// 
  /// @return true se habilitado (padrão: false)
  static Future<bool> getUsarRIR() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUsarRIR) ?? false; // Padrão: false
  }

  /// Define se o cronômetro de descanso deve iniciar automaticamente
  /// 
  /// @param automatico true para iniciar automaticamente
  static Future<void> setCronometroAutomatico(bool automatico) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCronometroAutomatico, automatico);
  }

  /// Verifica se o cronômetro deve iniciar automaticamente
  /// 
  /// @return true se habilitado (padrão: true)
  static Future<bool> getCronometroAutomatico() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCronometroAutomatico) ?? true; // Padrão: true
  }

  /// Define se notificações de descanso estão habilitadas
  /// 
  /// @param ativar true para habilitar notificações
  static Future<void> setNotificacaoDescanso(bool ativar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificacaoDescanso, ativar);
  }

  /// Verifica se notificações de descanso estão habilitadas
  /// 
  /// @return true se habilitado (padrão: true)
  static Future<bool> getNotificacaoDescanso() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificacaoDescanso) ?? true; // Padrão: true
  }

  /// Define o tempo de descanso padrão (usado quando não há configuração específica)
  /// 
  /// @param segundos Tempo em segundos (30-300)
  static Future<void> setTempoDescansoDefault(int segundos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTempoDescansoDefault, segundos);
  }

  /// Busca o tempo de descanso padrão
  /// 
  /// @return Tempo em segundos (padrão: 90s = 1min30s)
  static Future<int> getTempoDescansoDefault() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTempoDescansoDefault) ?? 90; // Padrão: 90s
  }
}
