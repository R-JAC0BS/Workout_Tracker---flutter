import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/service/log_service.dart';

class ExerciseStatsScreen extends StatefulWidget {
  final String exercicioNome;

  const ExerciseStatsScreen({
    super.key,
    required this.exercicioNome,
  });

  @override
  State<ExerciseStatsScreen> createState() => _ExerciseStatsScreenState();
}

class _ExerciseStatsScreenState extends State<ExerciseStatsScreen> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: widget.exercicioNome),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        key: ValueKey(_refreshKey),
        future: LogData.getLogsGroupedByDate(widget.exercicioNome),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }

          final logs = snapshot.data!;

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nenhum dado disponível',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Atualizar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
            },
            color: Colors.red,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChart(logs, 'Peso Máximo (kg)', 'max_peso'),
                  const SizedBox(height: 24),
                  _buildChart(logs, 'Volume Total (kg)', 'volume'),
                  const SizedBox(height: 24),
                  _buildLogsList(logs),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> logs, String title, String dataKey) {
    final spots = <FlSpot>[];
    double maxValue = 0;
    
    for (int i = 0; i < logs.length; i++) {
      final value = (logs[i][dataKey] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
      if (value > maxValue) maxValue = value;
    }

    // Adiciona margem de 10% ao topo do gráfico
    final maxY = maxValue * 1.1;
    final interval = maxY > 10 ? (maxY / 5).ceilToDouble() : 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(10),
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
                gridData: FlGridData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < logs.length) {
                          final date = logs[value.toInt()]['date'] as String;
                          final parts = date.split('-');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${parts[2]}/${parts[1]}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval.toDouble(),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: logs.length > 1 ? (logs.length - 1).toDouble() : 1,
                minY: 0,
                maxY: maxY > 0 ? maxY : 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: const Color.fromARGB(255, 255, 60, 60),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: const Color.fromARGB(255, 255, 60, 60),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color.fromARGB(255, 255, 60, 60).withOpacity(0.4),
                          const Color.fromARGB(255, 255, 60, 60).withOpacity(0.1),
                          const Color.fromARGB(255, 255, 60, 60).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(List<Map<String, dynamic>> logs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 30, 30, 100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...logs.map((log) {
            final date = log['date'] as String;
            final maxPeso = (log['max_peso'] as num).toDouble();
            final volume = (log['volume'] as num).toDouble();
            final totalSeries = log['total_series'] as int;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: Color.fromRGBO(149, 156, 167, 100),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${maxPeso.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${volume.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$totalSeries séries',
                      style: const TextStyle(
                        color: Color.fromRGBO(149, 156, 167, 100),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}
