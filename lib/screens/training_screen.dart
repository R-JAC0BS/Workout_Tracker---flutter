import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/Modal/modalDia.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/data/database.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: widget.name),
      body: Column(
        children: [
          // Container de estatísticas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(44, 44, 46, 100),
                borderRadius: BorderRadius.circular(20),
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '65',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
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
                    child: Column(
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '7',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'total',
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
                        const Text(
                          'High',
                          style: TextStyle(
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(44, 44, 46, 100),
                                borderRadius: BorderRadius.circular(15),
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
                                subtitle: const Text(
                                  '3 exercises • 12 sets',
                                  style: TextStyle(
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
