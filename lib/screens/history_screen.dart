import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/service/log_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _refreshKey = 0;

  @override
  void didUpdateWidget(HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Força rebuild quando a tela é reativada
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Histórico', showBackButton: false),
      body: FutureBuilder<List<String>>(
        key: ValueKey(_refreshKey),
        future: LogData.getAllExerciciosWithLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 255, 0, 0),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum histórico ainda',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete séries para ver seu histórico',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final exercicios = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercicios.length + 1,
            itemBuilder: (context, index) {
              // Adiciona espaçamento no final
              if (index == exercicios.length) {
                return const SizedBox(height: 80);
              }
              
              final exercicioNome = exercicios[index];
              
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: LogData.getLogsByExercicio(exercicioNome),
                builder: (context, logsSnapshot) {
                  if (!logsSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final logs = logsSnapshot.data!;
                  final pesosUnicos = logs
                      .map((log) => log['peso'] as double)
                      .toSet()
                      .toList()
                    ..sort((a, b) => b.compareTo(a));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(30, 30, 30, 100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(60, 60, 60, 100),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(60, 20, 20, 100),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    exercicioNome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(40, 40, 40, 100),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.scale,
                                        color: Colors.grey.shade400,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pesos utilizados:',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: pesosUnicos.map((peso) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(60, 20, 20, 100),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color.fromARGB(255, 100, 30, 30),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '${peso.toStringAsFixed(peso.truncateToDouble() == peso ? 0 : 1)} kg',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 255, 0, 0),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total de registros: ${logs.length}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Peso máx: ${pesosUnicos.first.toStringAsFixed(pesosUnicos.first.truncateToDouble() == pesosUnicos.first ? 0 : 1)} kg',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 0, 0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
