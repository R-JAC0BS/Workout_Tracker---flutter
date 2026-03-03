import 'package:flutter/material.dart';
import '../service/config_service.dart';
import '../service/intensity_service.dart';

/// Tela de configurações de intensidade específicas por exercício
/// 
/// Permite configurar:
/// - Tempo de descanso alvo
/// - RPE alvo
class ExerciseIntensityConfigScreen extends StatefulWidget {
  final String exercicioNome;

  const ExerciseIntensityConfigScreen({
    super.key,
    required this.exercicioNome,
  });

  @override
  State<ExerciseIntensityConfigScreen> createState() => _ExerciseIntensityConfigScreenState();
}

class _ExerciseIntensityConfigScreenState extends State<ExerciseIntensityConfigScreen> {
  double? _tempoDescansoAlvo;
  int? _rpeAlvo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  /// Carrega configurações salvas para o exercício
  Future<void> _carregarConfiguracoes() async {
    final tempoDescanso = await ConfigService.getTempoDescansoAlvo(widget.exercicioNome);
    final rpe = await ConfigService.getRPEAlvo(widget.exercicioNome);

    setState(() {
      _tempoDescansoAlvo = tempoDescanso?.toDouble();
      _rpeAlvo = rpe;
      _isLoading = false;
    });
  }

  /// Formata segundos para exibição (ex: "1:30")
  String _formatarTempo(double segundos) {
    final minutos = (segundos / 60).floor();
    final segs = (segundos % 60).round();
    return '$minutos:${segs.toString().padLeft(2, '0')}';
  }

  /// Salva tempo de descanso alvo
  Future<void> _salvarTempoDescanso(double? segundos) async {
    if (segundos != null) {
      await ConfigService.salvarTempoDescansoAlvo(
        widget.exercicioNome,
        segundos.round(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tempo de descanso salvo')),
        );
      }
    }
  }

  /// Salva RPE alvo
  Future<void> _salvarRPE(int? rpe) async {
    if (rpe != null) {
      await ConfigService.salvarRPEAlvo(widget.exercicioNome, rpe);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RPE alvo salvo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configurações do Exercício'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Exercício'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Nome do exercício
          Text(
            widget.exercicioNome,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Configure alvos específicos para este exercício',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // Tempo de Descanso Alvo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tempo de Descanso Alvo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_tempoDescansoAlvo != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => _tempoDescansoAlvo = null);
                            _salvarTempoDescanso(null);
                          },
                          tooltip: 'Limpar configuração',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_tempoDescansoAlvo != null)
                    Text(
                      _formatarTempo(_tempoDescansoAlvo!),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text(
                      'Não configurado (usa padrão)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _tempoDescansoAlvo ?? 90.0,
                    min: 30,
                    max: 300,
                    divisions: 27,
                    label: _formatarTempo(_tempoDescansoAlvo ?? 90.0),
                    onChanged: (value) {
                      setState(() => _tempoDescansoAlvo = value);
                    },
                    onChangeEnd: (value) async {
                      await _salvarTempoDescanso(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // RPE Alvo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RPE Alvo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_rpeAlvo != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => _rpeAlvo = null);
                            _salvarRPE(null);
                          },
                          tooltip: 'Limpar configuração',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_rpeAlvo != null)
                    Row(
                      children: [
                        Text(
                          'RPE $_rpeAlvo',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(RIR ${IntensityService.converterRPEparaRIR(_rpeAlvo!)})',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Não configurado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Slider(
                    value: (_rpeAlvo ?? 8).toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: 'RPE ${_rpeAlvo ?? 8}',
                    onChanged: (value) {
                      setState(() => _rpeAlvo = value.round());
                    },
                    onChangeEnd: (value) async {
                      await _salvarRPE(value.round());
                    },
                  ),
                  const Text(
                    'Intensidade alvo para este exercício (1-10)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Informações adicionais
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Sobre as Configurações',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Tempo de Descanso: usado pelo cronômetro automático\n'
                    '• RPE Alvo: sugerido no modal de registro de intensidade',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
