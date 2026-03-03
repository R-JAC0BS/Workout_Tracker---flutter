import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/service/analysis_service.dart';
import 'package:workout_tracker/service/database_service.dart';

/// Tela de dashboard de intensidade
/// 
/// Exibe métricas agregadas de intensidade de treino:
/// - Score de intensidade (gauge 0-100)
/// - Volume total
/// - RPE médio
/// - Densidade (kg/min)
/// - TUT total
/// - Tempo de descanso médio
class IntensityDashboardScreen extends StatefulWidget {
  const IntensityDashboardScreen({super.key});

  @override
  State<IntensityDashboardScreen> createState() => _IntensityDashboardScreenState();
}

class _IntensityDashboardScreenState extends State<IntensityDashboardScreen> {
  Map<String, dynamic>? _metricas;
  Map<String, dynamic>? _comparacao;
  List<String> _recomendacoes = [];
  List<Map<String, dynamic>> _sessoesHistoricas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = await DatabaseService.getDatabase();
      
      // Buscar a última sessão finalizada
      final result = await db.query(
        'sessao_treino',
        where: 'data_fim IS NOT NULL',
        orderBy: 'data_inicio DESC',
        limit: 1,
      );

      if (result.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Nenhuma sessão de treino finalizada encontrada';
        });
        return;
      }

      final sessaoId = result.first['id'] as int;
      final metricas = await AnalysisService.analisarIntensidadeSessao(sessaoId);

      // Buscar últimas 10 sessões para gráficos
      final sessoesResult = await db.query(
        'sessao_treino',
        where: 'data_fim IS NOT NULL',
        orderBy: 'data_inicio ASC',
        limit: 10,
      );

      // Calcular comparação com últimas 5 sessões
      final comparacao = await _calcularComparacao(metricas);

      // Buscar recomendações
      final recomendacoes = await AnalysisService.gerarRecomendacoes(sessaoId);

      setState(() {
        _metricas = metricas;
        _comparacao = comparacao;
        _recomendacoes = recomendacoes;
        _sessoesHistoricas = sessoesResult.map((row) => Map<String, dynamic>.from(row)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados: $e';
      });
    }
  }

  Future<Map<String, dynamic>> _calcularComparacao(Map<String, dynamic> metricasAtuais) async {
    final db = await DatabaseService.getDatabase();
    
    // Buscar últimas 5 sessões (excluindo a atual)
    final sessoesAnteriores = await db.query(
      'sessao_treino',
      where: 'data_fim IS NOT NULL',
      orderBy: 'data_inicio DESC',
      limit: 6, // 6 para pegar 5 anteriores (a primeira é a atual)
    );

    if (sessoesAnteriores.length < 2) {
      return {
        'tem_dados': false,
      };
    }

    // Pular a primeira (atual) e pegar as próximas 5
    final anteriores = sessoesAnteriores.skip(1).take(5).toList();

    // Calcular médias das sessões anteriores
    double somaVolume = 0;
    double somaRPE = 0;
    double somaDensidade = 0;
    double somaTUT = 0;
    double somaDescanso = 0;
    double somaScore = 0;
    int countRPE = 0;
    int countDensidade = 0;
    int countTUT = 0;
    int countDescanso = 0;

    for (final sessao in anteriores) {
      somaVolume += (sessao['volume_total'] as num?)?.toDouble() ?? 0;
      
      final rpe = (sessao['rpe_medio'] as num?)?.toDouble();
      if (rpe != null && rpe > 0) {
        somaRPE += rpe;
        countRPE++;
      }
      
      final densidade = (sessao['densidade'] as num?)?.toDouble();
      if (densidade != null && densidade > 0) {
        somaDensidade += densidade;
        countDensidade++;
      }
      
      final tut = (sessao['tut_total'] as num?)?.toInt();
      if (tut != null && tut > 0) {
        somaTUT += tut.toDouble();
        countTUT++;
      }
      
      final descanso = (sessao['tempo_descanso_medio'] as num?)?.toDouble();
      if (descanso != null && descanso > 0) {
        somaDescanso += descanso;
        countDescanso++;
      }
      
      somaScore += (sessao['score_intensidade'] as num?)?.toInt() ?? 0;
    }

    final numSessoes = anteriores.length;
    final mediaVolume = somaVolume / numSessoes;
    final mediaRPE = countRPE > 0 ? somaRPE / countRPE : 0.0;
    final mediaDensidade = countDensidade > 0 ? somaDensidade / countDensidade : 0.0;
    final mediaTUT = countTUT > 0 ? somaTUT / countTUT : 0.0;
    final mediaDescanso = countDescanso > 0 ? somaDescanso / countDescanso : 0.0;
    final mediaScore = somaScore / numSessoes;

    // Calcular variações percentuais
    final volumeAtual = metricasAtuais['volume_total'] as double;
    final rpeAtual = metricasAtuais['rpe_medio'] as double;
    final densidadeAtual = metricasAtuais['densidade'] as double;
    final tutAtual = (metricasAtuais['tut_total'] as int).toDouble();
    final descansoAtual = metricasAtuais['tempo_descanso_medio'] as double;
    final scoreAtual = (metricasAtuais['score_intensidade'] as int).toDouble();

    return {
      'tem_dados': true,
      'volume_variacao': _calcularVariacao(volumeAtual, mediaVolume),
      'rpe_variacao': mediaRPE > 0 ? _calcularVariacao(rpeAtual, mediaRPE) : null,
      'densidade_variacao': mediaDensidade > 0 ? _calcularVariacao(densidadeAtual, mediaDensidade) : null,
      'tut_variacao': mediaTUT > 0 ? _calcularVariacao(tutAtual, mediaTUT) : null,
      'descanso_variacao': mediaDescanso > 0 ? _calcularVariacao(descansoAtual, mediaDescanso) : null,
      'score_variacao': _calcularVariacao(scoreAtual, mediaScore),
    };
  }

  double _calcularVariacao(double atual, double media) {
    if (media == 0) return 0;
    return ((atual - media) / media) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Dashboard de Intensidade', showBackButton: true),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildDashboard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _carregarDados,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Tentar Novamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    if (_metricas == null) return const SizedBox.shrink();

    final scoreIntensidade = _metricas!['score_intensidade'] as int;
    final volumeTotal = _metricas!['volume_total'] as double;
    final rpeMedio = _metricas!['rpe_medio'] as double;
    final densidade = _metricas!['densidade'] as double;
    final tutTotal = _metricas!['tut_total'] as int;
    final tempoDescansoMedio = _metricas!['tempo_descanso_medio'] as double;

    return RefreshIndicator(
      onRefresh: _carregarDados,
      color: Colors.red,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gauge de Score de Intensidade
            _buildScoreGauge(scoreIntensidade),
            const SizedBox(height: 24),
            
            // Cards de métricas
            _buildMetricsGrid(
              volumeTotal: volumeTotal,
              rpeMedio: rpeMedio,
              densidade: densidade,
              tutTotal: tutTotal,
              tempoDescansoMedio: tempoDescansoMedio,
            ),
            
            const SizedBox(height: 24),
            
            // Recomendações
            if (_recomendacoes.isNotEmpty) ...[
              _buildSectionTitle('Recomendações'),
              const SizedBox(height: 16),
              _buildRecommendationsSection(),
              const SizedBox(height: 24),
            ],
            
            // Comparação com sessões anteriores
            if (_comparacao != null && _comparacao!['tem_dados'] == true) ...[
              _buildSectionTitle('Comparação com Últimas 5 Sessões'),
              const SizedBox(height: 16),
              _buildComparisonSection(),
              const SizedBox(height: 24),
            ],
            
            // Gráficos de evolução temporal
            if (_sessoesHistoricas.length >= 2) ...[
              _buildSectionTitle('Evolução Temporal'),
              const SizedBox(height: 16),
              _buildRPEChart(),
              const SizedBox(height: 16),
              _buildDensidadeChart(),
              const SizedBox(height: 16),
              _buildVolumeVsRPEChart(),
              const SizedBox(height: 16),
              _buildDescansoChart(),
            ],
            
            const SizedBox(height: 80), // Espaço para navegação
          ],
        ),
      ),
    );
  }

  Widget _buildScoreGauge(int score) {
    // Determinar cor baseada no score
    Color scoreColor;
    String scoreLabel;
    
    if (score < 30) {
      scoreColor = Colors.green;
      scoreLabel = 'Baixa';
    } else if (score < 50) {
      scoreColor = Colors.lightGreen;
      scoreLabel = 'Moderada';
    } else if (score < 70) {
      scoreColor = Colors.orange;
      scoreLabel = 'Alta';
    } else if (score < 85) {
      scoreColor = Colors.deepOrange;
      scoreLabel = 'Muito Alta';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Extrema';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          const Text(
            'Score de Intensidade',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Gauge circular
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 180,
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    sections: [
                      // Seção preenchida (score)
                      PieChartSectionData(
                        value: score.toDouble(),
                        color: scoreColor,
                        radius: 30,
                        showTitle: false,
                      ),
                      // Seção vazia (restante)
                      PieChartSectionData(
                        value: (100 - score).toDouble(),
                        color: Colors.grey.shade800,
                        radius: 30,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      scoreLabel,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legenda de cores
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green, 'Baixa'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.orange, 'Moderada'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.red, 'Alta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid({
    required double volumeTotal,
    required double rpeMedio,
    required double densidade,
    required int tutTotal,
    required double tempoDescansoMedio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas da Sessão',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Primeira linha: Volume e RPE
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.fitness_center,
                label: 'Volume Total',
                value: '${volumeTotal.toStringAsFixed(0)} kg',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.speed,
                label: 'RPE Médio',
                value: rpeMedio > 0 ? rpeMedio.toStringAsFixed(1) : 'N/A',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Segunda linha: Densidade e TUT
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.compress,
                label: 'Densidade',
                value: densidade > 0 ? '${densidade.toStringAsFixed(1)} kg/min' : 'N/A',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.timer,
                label: 'TUT Total',
                value: tutTotal > 0 ? _formatarTempo(tutTotal) : 'N/A',
                color: Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Terceira linha: Descanso Médio
        _buildMetricCard(
          icon: Icons.hotel,
          label: 'Descanso Médio',
          value: tempoDescansoMedio > 0 
              ? _formatarTempo(tempoDescansoMedio.toInt())
              : 'N/A',
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    
    if (minutos > 0) {
      return '${minutos}min ${segs}s';
    } else {
      return '${segs}s';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      children: _recomendacoes.asMap().entries.map((entry) {
        final index = entry.key;
        final recomendacao = entry.value;
        
        // Determinar ícone e cor baseado no conteúdo da recomendação
        IconData icon;
        Color color;
        
        if (recomendacao.toLowerCase().contains('ideal') || 
            recomendacao.toLowerCase().contains('continue') ||
            recomendacao.toLowerCase().contains('bem balanceado')) {
          icon = Icons.check_circle;
          color = Colors.green;
        } else if (recomendacao.toLowerCase().contains('alto') || 
                   recomendacao.toLowerCase().contains('muito') ||
                   recomendacao.toLowerCase().contains('deload') ||
                   recomendacao.toLowerCase().contains('fadiga')) {
          icon = Icons.warning;
          color = Colors.orange;
        } else if (recomendacao.toLowerCase().contains('baixo') || 
                   recomendacao.toLowerCase().contains('aumentar')) {
          icon = Icons.trending_up;
          color = Colors.blue;
        } else {
          icon = Icons.info;
          color = Colors.grey;
        }
        
        return Padding(
          padding: EdgeInsets.only(bottom: index < _recomendacoes.length - 1 ? 12 : 0),
          child: _buildRecommendationCard(
            icon: icon,
            color: color,
            text: recomendacao,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    if (_comparacao == null || _comparacao!['tem_dados'] != true) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variação em relação à média',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonItem(
            label: 'Volume Total',
            variacao: _comparacao!['volume_variacao'] as double,
            icon: Icons.fitness_center,
          ),
          const Divider(color: Color.fromRGBO(50, 50, 50, 100), height: 24),
          if (_comparacao!['rpe_variacao'] != null)
            _buildComparisonItem(
              label: 'RPE Médio',
              variacao: _comparacao!['rpe_variacao'] as double,
              icon: Icons.speed,
            ),
          if (_comparacao!['rpe_variacao'] != null)
            const Divider(color: Color.fromRGBO(50, 50, 50, 100), height: 24),
          if (_comparacao!['densidade_variacao'] != null)
            _buildComparisonItem(
              label: 'Densidade',
              variacao: _comparacao!['densidade_variacao'] as double,
              icon: Icons.compress,
            ),
          if (_comparacao!['densidade_variacao'] != null)
            const Divider(color: Color.fromRGBO(50, 50, 50, 100), height: 24),
          if (_comparacao!['tut_variacao'] != null)
            _buildComparisonItem(
              label: 'TUT Total',
              variacao: _comparacao!['tut_variacao'] as double,
              icon: Icons.timer,
            ),
          if (_comparacao!['tut_variacao'] != null)
            const Divider(color: Color.fromRGBO(50, 50, 50, 100), height: 24),
          if (_comparacao!['descanso_variacao'] != null)
            _buildComparisonItem(
              label: 'Descanso Médio',
              variacao: _comparacao!['descanso_variacao'] as double,
              icon: Icons.hotel,
            ),
          if (_comparacao!['descanso_variacao'] != null)
            const Divider(color: Color.fromRGBO(50, 50, 50, 100), height: 24),
          _buildComparisonItem(
            label: 'Score de Intensidade',
            variacao: _comparacao!['score_variacao'] as double,
            icon: Icons.dashboard,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem({
    required String label,
    required double variacao,
    required IconData icon,
  }) {
    final isPositive = variacao > 0;
    final isNeutral = variacao.abs() < 1; // Menos de 1% é considerado neutro
    
    Color color;
    IconData trendIcon;
    
    if (isNeutral) {
      color = Colors.grey;
      trendIcon = Icons.remove;
    } else if (isPositive) {
      color = Colors.green;
      trendIcon = Icons.arrow_upward;
    } else {
      color = Colors.red;
      trendIcon = Icons.arrow_downward;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        Icon(
          trendIcon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '${variacao.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRPEChart() {
    final sessoesComRPE = _sessoesHistoricas
        .where((s) => s['rpe_medio'] != null && (s['rpe_medio'] as double) > 0)
        .toList();

    if (sessoesComRPE.isEmpty) {
      return _buildEmptyChart('RPE ao Longo do Tempo', 'Nenhum dado de RPE disponível');
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sessoesComRPE.length; i++) {
      final rpe = (sessoesComRPE[i]['rpe_medio'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), rpe));
    }

    return _buildLineChart(
      title: 'RPE ao Longo do Tempo',
      spots: spots,
      color: Colors.purple,
      minY: 0,
      maxY: 10,
      leftTitles: true,
    );
  }

  Widget _buildDensidadeChart() {
    final sessoesComDensidade = _sessoesHistoricas
        .where((s) => s['densidade'] != null && (s['densidade'] as double) > 0)
        .toList();

    if (sessoesComDensidade.isEmpty) {
      return _buildEmptyChart('Densidade ao Longo do Tempo', 'Nenhum dado de densidade disponível');
    }

    final spots = <FlSpot>[];
    double maxDensidade = 0;
    for (int i = 0; i < sessoesComDensidade.length; i++) {
      final densidade = (sessoesComDensidade[i]['densidade'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), densidade));
      if (densidade > maxDensidade) maxDensidade = densidade;
    }

    return _buildLineChart(
      title: 'Densidade ao Longo do Tempo (kg/min)',
      spots: spots,
      color: Colors.orange,
      minY: 0,
      maxY: (maxDensidade * 1.2).ceilToDouble(),
      leftTitles: true,
    );
  }

  Widget _buildVolumeVsRPEChart() {
    final sessoesComDados = _sessoesHistoricas
        .where((s) => 
          s['volume_total'] != null && 
          s['rpe_medio'] != null && 
          (s['volume_total'] as double) > 0 &&
          (s['rpe_medio'] as double) > 0)
        .toList();

    if (sessoesComDados.isEmpty) {
      return _buildEmptyChart('Volume vs RPE por Sessão', 'Nenhum dado disponível');
    }

    final volumeBars = <BarChartGroupData>[];
    double maxVolume = 0;

    for (int i = 0; i < sessoesComDados.length; i++) {
      final volume = (sessoesComDados[i]['volume_total'] as num).toDouble();
      final rpe = (sessoesComDados[i]['rpe_medio'] as num).toDouble();
      
      if (volume > maxVolume) maxVolume = volume;

      // Normalizar RPE para escala de volume (multiplicar por fator)
      final rpeNormalizado = rpe * (maxVolume / 10);

      volumeBars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: volume,
              color: Colors.blue,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: rpeNormalizado,
              color: Colors.purple,
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Volume vs RPE por Sessão',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(Colors.blue, 'Volume (kg)'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.purple, 'RPE (normalizado)'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVolume * 1.2,
                barGroups: volumeBars,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt() + 1}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVolume / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade800,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescansoChart() {
    // Para este gráfico, precisamos buscar dados mais detalhados
    // Por simplicidade, vamos mostrar o descanso médio por sessão
    final sessoesComDescanso = _sessoesHistoricas
        .where((s) => 
          s['tempo_descanso_medio'] != null && 
          (s['tempo_descanso_medio'] as double) > 0)
        .toList();

    if (sessoesComDescanso.isEmpty) {
      return _buildEmptyChart('Descanso Médio por Sessão', 'Nenhum dado de descanso disponível');
    }

    final spots = <FlSpot>[];
    double maxDescanso = 0;
    for (int i = 0; i < sessoesComDescanso.length; i++) {
      final descanso = (sessoesComDescanso[i]['tempo_descanso_medio'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), descanso));
      if (descanso > maxDescanso) maxDescanso = descanso;
    }

    // Linha de referência para tempo alvo (90 segundos)
    final tempoAlvo = 90.0;

    return _buildLineChartWithReference(
      title: 'Descanso Real vs Alvo',
      spots: spots,
      color: Colors.teal,
      referenceY: tempoAlvo,
      referenceLabel: 'Alvo (90s)',
      minY: 0,
      maxY: (maxDescanso > tempoAlvo ? maxDescanso * 1.2 : tempoAlvo * 1.5).ceilToDouble(),
      leftTitles: true,
    );
  }

  Widget _buildLineChart({
    required String title,
    required List<FlSpot> spots,
    required Color color,
    required double minY,
    required double maxY,
    required bool leftTitles,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt() + 1}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: leftTitles,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade800,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartWithReference({
    required String title,
    required List<FlSpot> spots,
    required Color color,
    required double referenceY,
    required String referenceLabel,
    required double minY,
    required double maxY,
    required bool leftTitles,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(color, 'Real'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.grey, referenceLabel),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: referenceY,
                      color: Colors.grey,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt() + 1}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: leftTitles,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade800,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
