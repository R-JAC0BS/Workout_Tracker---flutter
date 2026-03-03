class Serie {
  final int id;
  final int exercicioId;
  final double? peso;
  final int? repeticoes;
  final bool isCompleted;
  
  // Campos de intensidade
  final int? rpe;                    // 1-10
  final int? rir;                    // 0-5+
  final int? tempoDescansoSegundos;  // tempo real de descanso
  final int? tutSegundos;            // tempo sob tensão
  final DateTime? tempoInicio;       // timestamp início da série
  final DateTime? tempoFim;          // timestamp fim da série
  
  Serie({
    required this.id,
    required this.exercicioId,
    this.peso,
    this.repeticoes,
    required this.isCompleted,
    this.rpe,
    this.rir,
    this.tempoDescansoSegundos,
    this.tutSegundos,
    this.tempoInicio,
    this.tempoFim,
  });
  
  factory Serie.fromMap(Map<String, dynamic> map) {
    return Serie(
      id: map['id'] as int,
      exercicioId: map['exercicio_id'] as int,
      peso: map['peso'] as double?,
      repeticoes: map['repeticoes'] as int?,
      isCompleted: map['is_completed'] == 1,
      rpe: map['rpe'] as int?,
      rir: map['rir'] as int?,
      tempoDescansoSegundos: map['tempo_descanso_segundos'] as int?,
      tutSegundos: map['tut_segundos'] as int?,
      tempoInicio: map['tempo_inicio'] != null 
        ? DateTime.parse(map['tempo_inicio'] as String) 
        : null,
      tempoFim: map['tempo_fim'] != null 
        ? DateTime.parse(map['tempo_fim'] as String) 
        : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercicio_id': exercicioId,
      'peso': peso,
      'repeticoes': repeticoes,
      'is_completed': isCompleted ? 1 : 0,
      'rpe': rpe,
      'rir': rir,
      'tempo_descanso_segundos': tempoDescansoSegundos,
      'tut_segundos': tutSegundos,
      'tempo_inicio': tempoInicio?.toIso8601String(),
      'tempo_fim': tempoFim?.toIso8601String(),
    };
  }
}
