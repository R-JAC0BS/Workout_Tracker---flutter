class ConfiguracaoExercicio {
  final int id;
  final String exercicioNome;
  final int? tempoDescansoAlvo;  // segundos
  final int? rpeAlvo;            // 1-10
  
  ConfiguracaoExercicio({
    required this.id,
    required this.exercicioNome,
    this.tempoDescansoAlvo,
    this.rpeAlvo,
  });
  
  factory ConfiguracaoExercicio.fromMap(Map<String, dynamic> map) {
    return ConfiguracaoExercicio(
      id: map['id'] as int,
      exercicioNome: map['exercicio_nome'] as String,
      tempoDescansoAlvo: map['tempo_descanso_alvo'] as int?,
      rpeAlvo: map['rpe_alvo'] as int?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercicio_nome': exercicioNome,
      'tempo_descanso_alvo': tempoDescansoAlvo,
      'rpe_alvo': rpeAlvo,
    };
  }
}
