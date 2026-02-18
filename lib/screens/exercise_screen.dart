import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/Modal/modalExercicio.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/data/database.dart';
import 'package:workout_tracker/screens/series_screen.dart';

class ExerciseScreenWidget extends StatefulWidget {
  final String nome;
  final int  id;
  const ExerciseScreenWidget({super.key, required this.nome, required this.id});

  @override
  State<ExerciseScreenWidget> createState() => _ExerciseScreenWidgetState();
}

class _ExerciseScreenWidgetState extends State<ExerciseScreenWidget> {
  int _refreshKey = 0;
  String _searchQuery = '';

  void _refreshExercicios() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: widget.nome),
      body: 
        Column(
          children: [
            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: const Color.fromRGBO(30, 30, 30, 100),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(50, 50, 50, 100),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(50, 50, 50, 100),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
            ),
            // Lista de exercícios
            Divider(
              color: const Color.fromARGB(255, 65, 65, 65),
              height: 1,
            )
            ,
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  key: ValueKey(_refreshKey),
                  future: DatabaseService.getExercicios(widget.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text("Carregando..."));
                    }
                    
                    final exercicios = snapshot.data!;
                    
                    // Filtrar exercícios pela pesquisa
                    final exerciciosFiltrados = exercicios.where((exercicio) {
                      return exercicio['nome'].toString().toLowerCase().contains(_searchQuery);
                    }).toList();
                    
                    if (exerciciosFiltrados.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _searchQuery.isEmpty 
                              ? "Nenhum exercício cadastrado"
                              : "Nenhum exercício encontrado",
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: [
                        for (var i = 0; i < exerciciosFiltrados.length; i++)
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: DatabaseService.getSeries(exerciciosFiltrados[i]['id'] as int),
                            builder: (context, seriesSnapshot) {
                              final numSeries = seriesSnapshot.hasData ? seriesSnapshot.data!.length : 0;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context) => SerieScreenWidget(
                                          exercicioId: exerciciosFiltrados[i]['id'] as int,
                                          nome: exerciciosFiltrados[i]['nome'] as String,
                                        ),
                                      ),
                                    );
                                  },
                                  onLongPress: () async {
                                    // Mostrar diálogo de confirmação
                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                        title: Text(
                                          'Remover Exercício',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Text(
                                          'Deseja remover "${exerciciosFiltrados[i]['nome']}"?\nTodas as séries serão removidas.',
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
                                      await DatabaseService.deleteExercicio(exerciciosFiltrados[i]['id']);
                                      _refreshExercicios();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    height: 100,
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
                                      title: Text(
                                        exerciciosFiltrados[i]['nome'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$numSeries ${numSeries == 1 ? 'set' : 'sets'}',
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
              return ModalexercicioWidget(groupId: widget.id);
            },
          );
          _refreshExercicios();
        },
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}