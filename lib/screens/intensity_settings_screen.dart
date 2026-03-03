import 'package:flutter/material.dart';
import '../service/config_service.dart';

/// Tela de configurações de intensidade
/// 
/// Permite ao usuário configurar:
/// - Uso de RPE/RIR
/// - Cronômetro automático
/// - Notificações de descanso
/// - Tempo de descanso padrão
class IntensitySettingsScreen extends StatefulWidget {
  const IntensitySettingsScreen({super.key});

  @override
  State<IntensitySettingsScreen> createState() => _IntensitySettingsScreenState();
}

class _IntensitySettingsScreenState extends State<IntensitySettingsScreen> {
  bool _usarRPE = true;
  bool _usarRIR = false;
  bool _cronometroAutomatico = true;
  bool _notificacaoDescanso = true;
  double _tempoDescansoDefault = 90.0; // segundos
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  /// Carrega configurações salvas
  Future<void> _carregarConfiguracoes() async {
    final usarRPE = await ConfigService.getUsarRPE();
    final usarRIR = await ConfigService.getUsarRIR();
    final cronometroAuto = await ConfigService.getCronometroAutomatico();
    final notificacao = await ConfigService.getNotificacaoDescanso();
    final tempoDefault = await ConfigService.getTempoDescansoDefault();

    setState(() {
      _usarRPE = usarRPE;
      _usarRIR = usarRIR;
      _cronometroAutomatico = cronometroAuto;
      _notificacaoDescanso = notificacao;
      _tempoDescansoDefault = tempoDefault.toDouble();
      _isLoading = false;
    });
  }

  /// Formata segundos para exibição (ex: "1:30")
  String _formatarTempo(double segundos) {
    final minutos = (segundos / 60).floor();
    final segs = (segundos % 60).round();
    return '$minutos:${segs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configurações de Intensidade'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Intensidade'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Seção: Métricas de Esforço
          const Text(
            'Métricas de Esforço',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Usar RPE'),
                  subtitle: const Text('Rate of Perceived Exertion (escala 1-10)'),
                  value: _usarRPE,
                  onChanged: (value) async {
                    setState(() => _usarRPE = value);
                    await ConfigService.setUsarRPE(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Usar RIR'),
                  subtitle: const Text('Reps in Reserve (repetições na reserva)'),
                  value: _usarRIR,
                  onChanged: (value) async {
                    setState(() => _usarRIR = value);
                    await ConfigService.setUsarRIR(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção: Cronômetro de Descanso
          const Text(
            'Cronômetro de Descanso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Cronômetro Automático'),
                  subtitle: const Text('Iniciar automaticamente após completar série'),
                  value: _cronometroAutomatico,
                  onChanged: (value) async {
                    setState(() => _cronometroAutomatico = value);
                    await ConfigService.setCronometroAutomatico(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notificações de Descanso'),
                  subtitle: const Text('Alertar quando tempo alvo é atingido'),
                  value: _notificacaoDescanso,
                  onChanged: (value) async {
                    setState(() => _notificacaoDescanso = value);
                    await ConfigService.setNotificacaoDescanso(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção: Tempo de Descanso Padrão
          const Text(
            'Tempo de Descanso Padrão',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
                        'Tempo Padrão',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        _formatarTempo(_tempoDescansoDefault),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _tempoDescansoDefault,
                    min: 30,
                    max: 300,
                    divisions: 27, // 30s incrementos de 10s até 300s
                    label: _formatarTempo(_tempoDescansoDefault),
                    onChanged: (value) {
                      setState(() => _tempoDescansoDefault = value);
                    },
                    onChangeEnd: (value) async {
                      await ConfigService.setTempoDescansoDefault(value.round());
                    },
                  ),
                  const Text(
                    'Usado quando não há configuração específica para o exercício',
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
                        'Dica',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Você pode configurar tempos de descanso específicos para cada exercício na tela de séries.',
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
