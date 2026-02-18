import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:workout_tracker/service/log_service.dart';

class SerieScreenWidget extends StatefulWidget {
  final String nome;
  final int exercicioId;
  const SerieScreenWidget({super.key, required this.nome, required this.exercicioId});

  @override
  State<SerieScreenWidget> createState() => _SerieScreenWidgetState();
}

class _SerieScreenWidgetState extends State<SerieScreenWidget> {
  int _refreshKey = 0;

  void _refreshSeries() {
    setState(() {
      _refreshKey++;
    });
  }

  Future<void> _addSet() async {
    await DatabaseService.insertSerie(
      exercicioId: widget.exercicioId,
      peso: 1.0,
      repeticoes: 1,
    );
    _refreshSeries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: widget.nome),
      body: Column(
        children: [
          // Informações superiores: PR e Grupo Muscular
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              LogData.getMaxPeso(widget.nome),
              DatabaseService.getGrupoMuscularFromExercicio(widget.exercicioId),
            ]),
            builder: (context, snapshot) {
              final prPeso = snapshot.hasData ? snapshot.data![0] as double : 0.0;
              final grupoMuscular = snapshot.hasData ? snapshot.data![1] as String : 'Carregando...';
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PR (Recorde Pessoal) - Lado Esquerdo (sem caixa)
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: const Color.fromARGB(255, 255, 0, 0),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PR',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prPeso.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Grupo Muscular - Lado Direito (caixa compacta)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(30, 30, 30, 100),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromRGBO(50, 50, 50, 100),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        grupoMuscular,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Caixa de Volume Total
          FutureBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(_refreshKey),
            future: DatabaseService.getSeries(widget.exercicioId),
            builder: (context, snapshot) {
              double volumeTotal = 0;
              if (snapshot.hasData) {
                for (var serie in snapshot.data!) {
                  volumeTotal += (serie['peso'] as double) * (serie['repeticoes'] as int);
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(30, 255, 0, 0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 0, 0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VOLUME TOTAL',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 0, 0),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${volumeTotal > 999 ? volumeTotal.toStringAsFixed(0) : volumeTotal.toStringAsFixed(1)}kg',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.trending_up,
                        color: const Color.fromARGB(255, 255, 0, 0),
                        size: 32,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Cabeçalho da tabela
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'SÉRIE',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'KG',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'REPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
          ),
          // Lista de séries
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    key: ValueKey(_refreshKey),
                    future: DatabaseService.getSeries(widget.exercicioId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final series = snapshot.data!.map((e) => Map<String, dynamic>.from(e)).toList();

                      if (series.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Nenhuma série cadastrada',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (var index = 0; index < series.length; index++)
                            StatefulBuilder(
                              builder: (context, setItemState) {
                                final serie = series[index];
                                final isCompleted = serie['is_completed'] == 1;
                                final pesoValue = serie['peso'] ?? 0.0;
                                final repsValue = serie['repeticoes'] ?? 0;
                                final TextEditingController pesoController = TextEditingController(text: '$pesoValue');
                                final TextEditingController repsController = TextEditingController(text: '$repsValue');
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: InkWell(
                                    onLongPress: () async {
                                      // Mostrar diálogo de confirmação
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                          title: Text(
                                            'Remover Série',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          content: Text(
                                            'Deseja remover a série ${index + 1}?',
                                            style: TextStyle(color: Colors.grey.shade400),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(149, 156, 167, 100)
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text(
                                                'Remover',
                                                style: TextStyle(
                                                  color: Color.fromARGB(255, 255, 0, 0)
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirmar == true) {
                                        await DatabaseService.deleteSerie(serie['id']);
                                        _refreshSeries();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(30, 30, 30, 100),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: const Color.fromRGBO(50, 50, 50, 100),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Número do set
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: const Color.fromRGBO(30, 30, 30, 100),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color.fromRGBO(50, 50, 50, 100),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Peso (editável)
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: TextField(
                                                controller: pesoController,
                                                textAlign: TextAlign.center,
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(
                                                      color: Color.fromARGB(255, 255, 0, 0),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                  filled: true,
                                                  fillColor: Colors.grey.shade900,
                                                ),
                                                onChanged: (value) {
                                                  final peso = double.tryParse(value) ?? 0.0;
                                                  serie['peso'] = peso;
                                                  DatabaseService.updateSerie(
                                                    serieId: serie['id'],
                                                    peso: peso,
                                                    repeticoes: int.tryParse(repsController.text) ?? 0,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          // Repetições (editável)
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: TextField(
                                                controller: repsController,
                                                textAlign: TextAlign.center,
                                                keyboardType: TextInputType.number,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(
                                                      color: Color.fromARGB(255, 255, 0, 0),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                  filled: true,
                                                  fillColor: Colors.grey.shade900,
                                                ),
                                                onChanged: (value) {
                                                  final reps = int.tryParse(value) ?? 0;
                                                  serie['repeticoes'] = reps;
                                                  DatabaseService.updateSerie(
                                                    serieId: serie['id'],
                                                    peso: double.tryParse(pesoController.text) ?? 0.0,
                                                    repeticoes: reps,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          // Botão de check (concluir)
                                          InkWell(
                                            onTap: () async {
                                              final wasCompleted = isCompleted;
                                              
                                              // Pega os valores atuais antes de atualizar
                                              final peso = double.tryParse(pesoController.text) ?? serie['peso'] ?? 0.0;
                                              final reps = int.tryParse(repsController.text) ?? serie['repeticoes'] ?? 0;
                                              
                                              await DatabaseService.markSerieAsCompleted(
                                                serie['id'],
                                                !isCompleted,
                                              );
                                              
                                              // Se está marcando como completo, salva o log
                                              if (!wasCompleted) {
                                                print('Salvando log: ${widget.nome} - ${peso}kg x $reps reps');
                                                
                                                try {
                                                  await LogData.addLog(
                                                    exercicioNome: widget.nome,
                                                    peso: peso,
                                                    repeticoes: reps,
                                                  );
                                                  print('Log salvo com sucesso!');
                                                } catch (e) {
                                                  print('Erro ao salvar log: $e');
                                                }
                                              }
                                              
                                              // Atualiza o status no map local
                                              serie['is_completed'] = isCompleted ? 0 : 1;
                                              setItemState(() {});
                                              
                                              // Verifica e atualiza o status do dia
                                              final diaId = await DatabaseService.getDiaIdFromExercicio(widget.exercicioId);
                                              if (diaId != null) {
                                                await DatabaseService.checkAndUpdateDiaStatus(diaId);
                                              }
                                              
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.only(
                                                    topLeft: Radius.circular(15),
                                                    topRight: Radius.circular(15) 
                                                      
                                                      ))
                                                  
                                                      ,
                                                    content: Text(
                                                      isCompleted 
                                                        ? 'Série ${index + 1} desmarcada!' 
                                                        : 'Série ${index + 1} concluída!'
                                                    ),
                                                    duration: const Duration(seconds: 1),
                                                    backgroundColor: const Color.fromARGB(255, 28, 28, 28),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: isCompleted 
                                                  ? const Color.fromARGB(255, 255, 0, 0)
                                                  : Colors.grey.shade700,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  // Botão Add Set (dentro do scroll, após as séries)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: Colors.grey.shade700,
                        strokeWidth: 1,
                        dashWidth: 5,
                        dashSpace: 5,
                      ),
                      child: ElevatedButton(
                        onPressed: _addSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.grey.shade400, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Adicionar série',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
}

// CustomPainter para criar borda pontilhada
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(15),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        dashPath.addPath(extractPath, Offset.zero);
        distance = nextDistance + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}