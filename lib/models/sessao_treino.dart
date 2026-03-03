class SessaoTreino {
  final int id;
  final int diaId;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final double? densidade;           // kg/min
  final int? scoreIntensidade;       // 0-100
  final double? volumeTotal;         // kg
  final double? rpeMedio;            // 1-10
  final int? tutTotal;               // segundos
  final int? tempoDescansoMedio;     // segundos
  
  SessaoTreino({
    required this.id,
    required this.diaId,
    required this.dataInicio,
    this.dataFim,
    this.densidade,
    this.scoreIntensidade,
    this.volumeTotal,
    this.rpeMedio,
    this.tutTotal,
    this.tempoDescansoMedio,
  });
  
  factory SessaoTreino.fromMap(Map<String, dynamic> map) {
    return SessaoTreino(
      id: map['id'] as int,
      diaId: map['dia_id'] as int,
      dataInicio: DateTime.parse(map['data_inicio'] as String),
      dataFim: map['data_fim'] != null 
        ? DateTime.parse(map['data_fim'] as String) 
        : null,
      densidade: map['densidade'] as double?,
      scoreIntensidade: map['score_intensidade'] as int?,
      volumeTotal: map['volume_total'] as double?,
      rpeMedio: map['rpe_medio'] as double?,
      tutTotal: map['tut_total'] as int?,
      tempoDescansoMedio: map['tempo_descanso_medio'] as int?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dia_id': diaId,
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim?.toIso8601String(),
      'densidade': densidade,
      'score_intensidade': scoreIntensidade,
      'volume_total': volumeTotal,
      'rpe_medio': rpeMedio,
      'tut_total': tutTotal,
      'tempo_descanso_medio': tempoDescansoMedio,
    };
  }
}
