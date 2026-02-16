import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_tracker/Widget/Modal/modalDia.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/Widget/title.dart';
import 'package:workout_tracker/data/database.dart';
import 'package:workout_tracker/screens/training_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await DatabaseService.getDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 148, 112, 23),
        ),
        scaffoldBackgroundColor: Colors.grey.shade900,
      ),
      home: const TrainingWidget(),
    );
  }
}

class TrainingWidget extends StatelessWidget {
  const TrainingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Divisao de treino'),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Goal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(60, 20, 20, 100),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 100, 30, 30),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEEKLY GOAL',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 0, 0),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '4 / 5 Workouts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
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
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: 0.8,
                            strokeWidth: 8,
                            backgroundColor: const Color.fromARGB(255, 80, 30, 30),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 255, 0, 0),
                            ),
                          ),
                        ),
                        Text(
                          '80%',
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
              FutureBuilder<List<Map<String,dynamic>>>(
                future: DatabaseService.getDias(), 
                builder: (context,snapshot){
                  if (!snapshot.hasData){
                    return const Text("Carregando");
                  }
                  final dias = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: dias.map((dia) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(10),
                            border: Border(
                              left: BorderSide(
                                color: const Color.fromRGBO(34, 197, 94, 100),
                                width: 4,
                              ),
                            ),
                          ),
                          child: ElevatedButton(
                            
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(44, 44, 46, 100),
                              // Aumenta o tamanho da caixa de dias ajustando o padding vertical
                              padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              )
                              
                            ),
                            onPressed: () {
                              Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => TrainingScreen(
                                diaId: dia['id'],
                                name : dia['nome']
                              ))
                              );
                              print('Dia clicado: ${dia['nome']}');
                            },
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Text(
                                dia['nome'].toUpperCase(),
                                style: const TextStyle(color: Color.fromRGBO(34, 197, 94, 100), fontSize: 16, fontWeight: FontWeight.bold),

                              
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Push A (Chest & Tris)',
                                style: TextStyle(
                                  color : Colors.white,
                                  fontSize: 23
                                  
                                ),
                              ),
                              const SizedBox(height: 4),
                                 Text(
                                'Push A (Chest & Tris)',
                                style: TextStyle(
                                  color : Color.fromRGBO(149, 156, 167, 100),
                                  fontSize: 15
                                  
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    color: Color.fromRGBO(149, 156, 167, 100),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '12,450 lbs Vol',
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
                                    '1h 15m',
                                    style: TextStyle(
                                      color: Color.fromRGBO(149, 156, 167, 100),
                                      fontSize: 14,
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
                    }).toList(),
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
