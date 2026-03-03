/// Serviço para gerenciamento de rastreamento de Tempo Sob Tensão (TUT).
/// 
/// Este serviço fornece funcionalidades para:
/// - Iniciar rastreamento de TUT para uma série
/// - Parar rastreamento e retornar tempo em segundos
/// - Consultar TUT atual durante execução
/// - Verificar se TUT está sendo rastreado
/// 
/// O serviço usa um Stopwatch do Dart para medir o tempo com precisão.
/// Apenas um rastreamento pode estar ativo por vez.
class TUTService {
  static Stopwatch? _stopwatch;

  /// Inicia rastreamento de TUT para uma série
  /// 
  /// Se já existir um rastreamento ativo, ele será parado antes de iniciar o novo.
  /// O Stopwatch começa a contar imediatamente após a chamada.
  static void iniciarTUT() {
    // Parar rastreamento anterior se existir
    if (_stopwatch != null && _stopwatch!.isRunning) {
      _stopwatch!.stop();
    }

    // Criar novo stopwatch e iniciar
    _stopwatch = Stopwatch();
    _stopwatch!.start();
  }

  /// Para rastreamento e retorna TUT em segundos
  /// 
  /// Para o Stopwatch ativo e retorna o tempo decorrido em segundos.
  /// Se não houver rastreamento ativo, retorna 0.
  /// 
  /// @return Tempo sob tensão em segundos
  static int pararTUT() {
    if (_stopwatch == null || !_stopwatch!.isRunning) {
      return 0;
    }

    _stopwatch!.stop();
    final segundos = (_stopwatch!.elapsedMilliseconds / 1000).round();
    
    // Limpar stopwatch após parar
    _stopwatch = null;
    
    return segundos;
  }

  /// Retorna TUT atual em segundos (durante execução)
  /// 
  /// Retorna o tempo decorrido desde o início do rastreamento.
  /// Se não houver rastreamento ativo, retorna 0.
  /// 
  /// @return Tempo sob tensão atual em segundos
  static int getTUTAtual() {
    if (_stopwatch == null || !_stopwatch!.isRunning) {
      return 0;
    }

    return (_stopwatch!.elapsedMilliseconds / 1000).round();
  }

  /// Verifica se TUT está sendo rastreado
  /// 
  /// @return true se há um rastreamento ativo, false caso contrário
  static bool isRastreando() {
    return _stopwatch != null && _stopwatch!.isRunning;
  }
}
