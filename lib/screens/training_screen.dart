import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/Modal/modalDia.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/data/database.dart';
import 'package:workout_tracker/screens/exercise_screen.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key, required this.diaId, required this.name});
  final int diaId;
  final String name;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState(diaId);
}

class _TrainingScreenState extends State<TrainingScreen> {
  _TrainingScreenState(int diaId);
  
  // Chave para forçar rebuild do FutureBuilder
  int _refreshKey = 0;

  void _refreshGrupos() {
    setState(() {
      _refreshKey++;
    });
  }

  // Método para calcular total de séries de um grupo
  Future<int> _getTotalSeries(int grupoId) async {
    final exercicios = await DatabaseService.getExercicios(grupoId);
    int total = 0;
    
    for (var exercicio in exercicios) {
      final series = await DatabaseService.getSeries(exercicio['id'] as int);
      total += series.length;
    }
    
    return total;
  }

  // Método para calcular total de exercícios do dia
  Future<int> _getTotalExercicios() async {
    final grupos = await DatabaseService.getGrupos(widget.diaId);
    int total = 0;
    
    for (var grupo in grupos) {
      final exercicios = await DatabaseService.getExercicios(grupo['id'] as int);
      total += exercicios.length;
    }
    
    return total;
  }

  // Método para calcular total de séries do dia
  Future<int> _getTotalSeriesDia() async {
    final grupos = await DatabaseService.getGrupos(widget.diaId);
    int total = 0;
    
    for (var grupo in grupos) {
      final exercicios = await DatabaseService.getExercicios(grupo['id'] as int);
      for (var exercicio in exercicios) {
        final series = await DatabaseService.getSeries(exercicio['id'] as int);
        total += series.length;
      }
    }
    
    return total;
  }

  // Método para determinar o nível de volume
  String _getVolumeLevel(int totalSeries) {
    if (totalSeries >= 26) return 'High';
    if (totalSeries >= 20) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: widget.name),
      body: Column(
        children: [
          // Container de estatísticas
          FutureBuilder<int>(
            key: ValueKey(_refreshKey),
            future: _getTotalSeriesDia(),
            builder: (context, seriesSnapshot) {
              final totalSeries = seriesSnapshot.hasData ? seriesSnapshot.data! : 0;
              final duracaoMinutos = (totalSeries * 1.5).round();
              final volumeLevel = _getVolumeLevel(totalSeries);
              
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(30, 30, 30, 100),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(2, 5),
                        spreadRadius: 0,
                        blurRadius: 10,
                        color: const Color.fromARGB(255, 7, 4, 4).withOpacity(0.3),
                        
                      )
                    ],
                    border: Border.all(
                      color: const Color.fromRGBO(50, 50, 50, 100),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Estimated Duration
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Estimated Duration',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$duracaoMinutos',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'min',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey.shade700,
                      ),
                      // Exercises
                      Expanded(
                        child: FutureBuilder<int>(
                          future: _getTotalExercicios(),
                          builder: (context, exerciciosSnapshot) {
                            final totalExercicios = exerciciosSnapshot.hasData ? exerciciosSnapshot.data! : 0;
                            
                            return Column(
                              children: [
                                Text(
                                  'Exercises',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$totalExercicios',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'total',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Divider
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey.shade700,
                      ),
                      // Volume
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Volume',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              volumeLevel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Lista de grupos musculares
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder(
                key: ValueKey(_refreshKey),
                future: DatabaseService.getGrupos(widget.diaId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text("Carregando"));
                  }
                  final grupos = snapshot.data!;
                

                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Text('TARGET MUSCLES',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 119, 119, 119),
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                          ),
                          
                          ),
                        ),
                        for (var i = 0; i < grupos.length; i++)
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: DatabaseService.getExercicios(grupos[i]['id'] as int),
                            builder: (context, exerciciosSnapshot) {
                              final numExercicios = exerciciosSnapshot.hasData ? exerciciosSnapshot.data!.length : 0;
                              
                              // Buscar total de séries de todos os exercícios
                              return FutureBuilder<int>(
                                future: _getTotalSeries(grupos[i]['id'] as int),
                                builder: (context, seriesSnapshot) {
                                  final totalSeries = seriesSnapshot.hasData ? seriesSnapshot.data! : 0;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: InkWell(
                                      onTap: () {
                                        // Navegar para a tela de exercícios do grupo
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ExerciseScreenWidget(
                                              id: grupos[i]['id'],
                                              nome: grupos[i]['nome'] ,

                                            )
                                          
                                          )
                                        );
                                        print('Grupo clicado: ${grupos[i]['nome']}');
                                      },
                                      onLongPress: () async {
                                        // Mostrar diálogo de confirmação
                                        final confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                            title: Text(
                                              'Remover Grupo',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            content: Text(
                                              'Deseja remover "${grupos[i]['nome']}"?\nTodos os exercícios e séries serão removidos.',
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
                                          await DatabaseService.deleteGrupo(grupos[i]['id']);
                                          _refreshGrupos();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(30, 30, 30, 100),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: const Color.fromRGBO(50, 50, 50, 100),
                                            width: 1,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(16),
                                          leading: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(121, 60, 20, 20),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.fitness_center,
                                              color: Color.fromARGB(255, 255, 0, 0),
                                              size: 30,
                                            ),
                                          ),
                                          title: Text(
                                            grupos[i]['nome'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '$numExercicios ${numExercicios == 1 ? 'exercise' : 'exercises'} • $totalSeries ${totalSeries == 1 ? 'set' : 'sets'}',
                                            style: const TextStyle(
                                              color: Color.fromRGBO(149, 156, 167, 100),
                                              fontSize: 14,
                                            ),
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                      ],
                     
                  );

                },
              ),
            
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return ModalDayWidget(
                groupId: widget.diaId,
              );
            },
          );
          // Atualiza a lista após fechar o modal
          _refreshGrupos();
        },
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
