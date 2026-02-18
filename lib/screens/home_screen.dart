import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:workout_tracker/screens/training_screen.dart';

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
      appBar: AppBarWidget(text: 'Divisão de treino', showBackButton: false),
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
                    return const Text("Carregando...");
                  }
                  final dias = snapshot.data!;
                  
                  // Calcular dias completados
                  final totalDias = dias.length;
                  final diasCompletados = dias.where((dia) => dia['is_completed'] == 1).length;
                  final percentual = totalDias > 0 ? diasCompletados / totalDias : 0.0;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card de meta semanal atualizado
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
                                  '$diasCompletados / $totalDias completos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Progresso circular
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
                      return FutureBuilder<void>(
                        future: DatabaseService.checkAndUpdateDiaStatus(dia['id']),
                        builder: (context, statusSnapshot) {
                          // Aguarda a verificação do status antes de continuar
                          if (statusSnapshot.connectionState != ConnectionState.done) {
                            return const SizedBox.shrink();
                          }
                          
                          return FutureBuilder<Map<String, dynamic>>(
                            future: DatabaseService.getDatabase().then((db) => 
                              db.query('dias', where: 'id = ?', whereArgs: [dia['id']]).then((result) => result.first)
                            ),
                            builder: (context, diaSnapshot) {
                              if (!diaSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }
                              
                              final diaAtualizado = diaSnapshot.data!;
                              final isCompleted = diaAtualizado['is_completed'] == 1;
                      
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
                          
                          // Formatar volume (converter para kg se necessário)
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
                              child: diaAtualizado['is_cardio'] == 1
                                ? // Layout para dia de cardio
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                                bool isCardio = diaAtualizado['is_cardio'] == 1;
                                                
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) => StatefulBuilder(
                                                    builder: (context, setDialogState) => AlertDialog(
                                                      backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                                      title: Text(
                                                        'Editar Dia',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          TextField(
                                                            controller: controller,
                                                            maxLength: 30,
                                                            style: TextStyle(color: Colors.white),
                                                            decoration: InputDecoration(
                                                              labelText: 'Descrição',
                                                              labelStyle: TextStyle(
                                                                color: Color.fromRGBO(149, 156, 167, 100)
                                                              ),
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
                                                          const SizedBox(height: 20),
                                                          Row(
                                                            children: [
                                                              Checkbox(
                                                                value: isCardio,
                                                                activeColor: Color.fromARGB(255, 255, 0, 0),
                                                                onChanged: (value) {
                                                                  setDialogState(() {
                                                                    isCardio = value ?? false;
                                                                  });
                                                                },
                                                              ),
                                                              Text(
                                                                'Dia de Cardio',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Icon(
                                                                Icons.directions_run,
                                                                color: isCardio 
                                                                  ? Color.fromARGB(255, 255, 0, 0)
                                                                  : Color.fromRGBO(149, 156, 167, 100),
                                                                size: 24,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
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
                                                            await DatabaseService.updateDiaCardio(
                                                              dia['id'],
                                                              isCardio
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
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.directions_run,
                                              color: Color.fromARGB(255, 70, 70, 70),
                                              size: 45,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Descanso & Cardio',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : // Layout normal para dia de treino
                                  ElevatedButton(
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
                                                bool isCardio = diaAtualizado['is_cardio'] == 1;
                                                
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) => StatefulBuilder(
                                                    builder: (context, setDialogState) => AlertDialog(
                                                      backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                                      title: Text(
                                                        'Editar Dia',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          TextField(
                                                            controller: controller,
                                                            maxLength: 30,
                                                            style: TextStyle(color: Colors.white),
                                                            decoration: InputDecoration(
                                                              labelText: 'Descrição',
                                                              labelStyle: TextStyle(
                                                                color: Color.fromRGBO(149, 156, 167, 100)
                                                              ),
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
                                                          const SizedBox(height: 20),
                                                          Row(
                                                            children: [
                                                              Checkbox(
                                                                value: isCardio,
                                                                activeColor: Color.fromARGB(255, 255, 0, 0),
                                                                onChanged: (value) {
                                                                  setDialogState(() {
                                                                    isCardio = value ?? false;
                                                                  });
                                                                },
                                                              ),
                                                              Text(
                                                                'Dia de Cardio',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Icon(
                                                                Icons.directions_run,
                                                                color: isCardio 
                                                                  ? Color.fromARGB(255, 255, 0, 0)
                                                                  : Color.fromRGBO(149, 156, 167, 100),
                                                                size: 24,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
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
                                                            await DatabaseService.updateDiaCardio(
                                                              dia['id'],
                                                              isCardio
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
                                            diaAtualizado['is_cardio'] == 1 
                                              ? Icons.directions_run 
                                              : Icons.fitness_center,
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
                                                'Começar treino',
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
                            }
                          );
                        }
                      );
                    }).toList(),
                    ],
                  );
                }
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
