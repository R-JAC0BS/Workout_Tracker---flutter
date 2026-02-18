import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/Widget/navBar/navBar.dart';
import 'package:workout_tracker/data/database.dart';
import 'package:workout_tracker/service/reloadData.dart';
import 'package:workout_tracker/screens/training_screen.dart';
import 'package:workout_tracker/screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.getDatabase();
  
  // Garante que a tabela de logs existe
  await DatabaseService.ensureLogsTableExists();
  
  // Verifica e reseta dados semanalmente
  await ReloadData.checkAndResetWeeklyData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(18, 18, 18, 100),
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(18, 18, 18, 100),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  int _statsRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const TrainingWidget(),
              const PlaceholderScreen(title: 'History'),
              StatsScreen(key: ValueKey(_statsRefreshKey)),
              const PlaceholderScreen(title: 'Me'),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NabBarWidget(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  // Atualiza a tela Stats quando navegar para ela
                  if (index == 2) {
                    _statsRefreshKey++;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: title, showBackButton: false),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class TrainingWidget extends StatefulWidget {
  const TrainingWidget({super.key});

  @override
  State<TrainingWidget> createState() => _TrainingWidgetState();
}

class _TrainingWidgetState extends State<TrainingWidget> {
  int _refreshKey = 0;

  void _refreshDias() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Divisao de treino', showBackButton: false),
      body: SingleChildScrollView(
        child: Container(

          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             

            
              FutureBuilder<List<Map<String,dynamic>>>(
                
                key: ValueKey(_refreshKey),
                future: DatabaseService.getDias(), 
                builder: (context,snapshot){
                  if (!snapshot.hasData){
                    return const Text("Carregando");
                  }
                  final dias = snapshot.data!;
                  
                  // Calcular dias completados
                  final totalDias = dias.length;
                  final diasCompletados = dias.where((dia) => dia['is_completed'] == 1).length;
                  final percentual = totalDias > 0 ? diasCompletados / totalDias : 0.0;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      // Weekly Goal Card atualizado
                      Container(
                        padding: const EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(60, 20, 20, 100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color.fromARGB(255, 100, 30, 30),
                            width: 1.3,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TREINOS COMPLETOS',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 0, 0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$diasCompletados / $totalDias completo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Circular Progress
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: CircularProgressIndicator(
                                    value: percentual,
                                    strokeWidth: 8,
                                    backgroundColor: const Color.fromARGB(255, 80, 30, 30),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 255, 0, 0),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(percentual * 100).toInt()}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Título da seção
                      Text(
                        'Monte seu treino',
                        style: TextStyle(
                          color: Color.fromRGBO(149, 156, 167, 100),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Lista de dias
                      ...dias.map((dia) {
                      final isCompleted = dia['is_completed'] == 1;
                      
                      // Determinar o dia atual da semana (1 = Segunda, 7 = Domingo)
                      final hoje = DateTime.now().weekday;
                      final diaIndex = dia['id'] as int;
                      final isDiaAtual = diaIndex == hoje;
                      
                      // Definir cor da borda: Verde se completo, Vermelho se dia atual, Cinza caso contrário
                      final borderColor = isCompleted 
                        ? const Color.fromRGBO(34, 197, 94, 100) 
                        : isDiaAtual
                          ? const Color.fromRGBO(220, 38, 38, 100)
                          : const Color.fromRGBO(100, 100, 100, 100);
                      
                      return FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          DatabaseService.getFirst3ExerciciosFromDia(dia['id']),
                          DatabaseService.getVolumeTotalDia(dia['id']),
                          DatabaseService.getTempoEstimadoDia(dia['id']),
                        ]),
                        builder: (context, snapshot) {
                          final exercicios = snapshot.hasData ? snapshot.data![0] as List<String> : <String>[];
                          final volumeTotal = snapshot.hasData ? snapshot.data![1] as double : 0.0;
                          final tempoEstimado = snapshot.hasData ? snapshot.data![2] as int : 0;
                          
                          final exerciciosText = exercicios.isEmpty 
                            ? 'Nenhum exercício' 
                            : exercicios.join(', ') + (exercicios.length >= 3 ? '...' : '');
                          
                          // Formatar volume (converter para lbs se necessário)
                          final volumeFormatado = volumeTotal > 0 
                            ? '${volumeTotal.toStringAsFixed(0)} kg Vol' 
                            : '0 kg Vol';
                          
                          // Formatar tempo
                          final tempoFormatado = tempoEstimado > 0
                            ? tempoEstimado >= 60 
                              ? '${(tempoEstimado / 60).floor()}h ${tempoEstimado % 60}m'
                              : '${tempoEstimado}m'
                            : '0m';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(30, 30, 30, 100),
                                borderRadius: BorderRadius.circular(10),
                                border: Border(
                                  left: BorderSide(
                                    color: borderColor,
                                    width: 5,
                                  ),
                                ),
                              ),
                              child: ElevatedButton(
                                
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  )
                                  
                                ),
                                onPressed: () async {
                                  await Navigator.push(context, 
                                  MaterialPageRoute(builder: (context) {
                                    return TrainingScreen(
                                    diaId: dia['id'],
                                    name : dia['nome']
                                  );
                                  })
                                  );
                                  // Atualiza a lista quando voltar da tela
                                  _refreshDias();
                                  print('Dia clicado: ${dia['nome']}');
                                },
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dia['nome'].toUpperCase(),
                                          style: TextStyle(
                                            color: borderColor, 
                                            fontSize: 16, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Color.fromRGBO(149, 156, 167, 100),
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                final controller = TextEditingController(
                                                  text: dia['descricao'] ?? ''
                                                );
                                                
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                                    title: Text(
                                                      'Editar Descrição',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                    content: TextField(
                                                      controller: controller,
                                                      maxLength: 30,
                                                      style: TextStyle(color: Colors.white),
                                                      decoration: InputDecoration(
                                                        hintText: 'Digite a descrição',
                                                        hintStyle: TextStyle(
                                                          color: Color.fromRGBO(149, 156, 167, 100)
                                                        ),
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Color.fromRGBO(149, 156, 167, 100)
                                                          ),
                                                        ),
                                                        focusedBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Color.fromARGB(255, 255, 0, 0)
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          'Cancelar',
                                                          style: TextStyle(
                                                            color: Color.fromRGBO(149, 156, 167, 100)
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await DatabaseService.updateDiaDescricao(
                                                            dia['id'],
                                                            controller.text
                                                          );
                                                          Navigator.pop(context);
                                                          _refreshDias();
                                                        },
                                                        child: Text(
                                                          'Salvar',
                                                          style: TextStyle(
                                                            color: Color.fromARGB(255, 255, 0, 0)
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            if (isCompleted)
                                              Icon(
                                                Icons.check_circle,
                                                color: const Color.fromRGBO(34, 197, 94, 100),
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (dia['descricao'] != null && dia['descricao'].toString().isNotEmpty) 
                                      ? dia['descricao'] 
                                      : 'Não definido',
                                    style: TextStyle(
                                      color : Colors.white,
                                      fontSize: 23
                                      
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                     Text(
                                    exerciciosText,
                                    style: TextStyle(
                                      color : Color.fromRGBO(149, 156, 167, 100),
                                      fontSize: 15
                                      
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.fitness_center,
                                            color: Color.fromRGBO(149, 156, 167, 100),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            volumeFormatado,
                                            style: TextStyle(
                                              color: Color.fromRGBO(149, 156, 167, 100),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Icon(
                                            Icons.access_time,
                                            color: Color.fromRGBO(149, 156, 167, 100),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            tempoFormatado,
                                            style: TextStyle(
                                              color: Color.fromRGBO(149, 156, 167, 100),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isDiaAtual && !isCompleted)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(220, 38, 38, 100),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromRGBO(220, 38, 38, 0.6),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Começar Treino',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  )

                                    ],
                                  ),
                                  
                                
                                  
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    ],
                  );
                }
                
              )
            ],
          ),
        ),
      ),
    );
  }
}
