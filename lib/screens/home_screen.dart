import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:workout_tracker/screens/training_screen.dart';
import 'package:workout_tracker/screens/intensity_dashboard_screen.dart';
import 'package:workout_tracker/screens/intensity_settings_screen.dart';

class TrainingWidget extends StatefulWidget {
  const TrainingWidget({super.key});

  @override
  State<TrainingWidget> createState() => _TrainingWidgetState();
}

class _TrainingWidgetState extends State<TrainingWidget> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _diasComDados = [];
  int _diaSelecionado = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    
    final dias = await DatabaseService.getDias();
    final diasComDados = <Map<String, dynamic>>[];
    
    for (final dia in dias) {
      await DatabaseService.checkAndUpdateDiaStatus(dia['id']);
      
      final db = await DatabaseService.getDatabase();
      final diaAtualizado = (await db.query('dias', where: 'id = ?', whereArgs: [dia['id']])).first;
      
      final exercicios = await DatabaseService.getFirst3ExerciciosFromDia(dia['id']);
      final volumeTotal = await DatabaseService.getVolumeTotalDia(dia['id']);
      final tempoEstimado = await DatabaseService.getTempoEstimadoDia(dia['id']);
      
      diasComDados.add({
        ...diaAtualizado,
        'exercicios': exercicios,
        'volumeTotal': volumeTotal,
        'tempoEstimado': tempoEstimado,
      });
    }
    
    setState(() {
      _diasComDados = diasComDados;
      _isLoading = false;
    });
  }

  void _refreshDias() {
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: 'Divisão de treino', 
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IntensitySettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 255, 0, 0),
            ),
          )
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContent(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildContent() {
    final diaAtual = _diasComDados.firstWhere(
      (dia) => dia['id'] == _diaSelecionado,
      orElse: () => _diasComDados.isNotEmpty ? _diasComDados[0] : {},
    );
    
    if (diaAtual.isEmpty) {
      return Center(
        child: Text(
          'Nenhum dia cadastrado',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final isCompleted = diaAtual['is_completed'] == 1;
    final volumeTotal = diaAtual['volumeTotal'] as double;
    final tempoEstimado = diaAtual['tempoEstimado'] as int;
    final isCardio = diaAtual['is_cardio'] == 1;
    
    final totalDias = _diasComDados.length;
    final diasCompletados = _diasComDados.where((dia) => dia['is_completed'] == 1).length;
    final percentual = totalDias > 0 ? diasCompletados / totalDias : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card de progresso semanal
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(60, 20, 20, 1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.fromARGB(255, 100, 30, 30),
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
                    'TREINOS COMPLETOS',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 0, 0),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$diasCompletados / $totalDias completos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: percentual,
                      strokeWidth: 6,
                      backgroundColor: Color.fromARGB(255, 80, 30, 30),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ),
                  Text(
                    '${(percentual * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
       
        const SizedBox(height: 16),
        
        // Lista horizontal de dias
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _diasComDados.length,
            itemBuilder: (context, index) {
              final dia = _diasComDados[index];
              final isSelecionado = dia['id'] == _diaSelecionado;
              final isDiaCompleto = dia['is_completed'] == 1;
              final isDiaAtual = dia['id'] == DateTime.now().weekday;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _diaSelecionado = dia['id'];
                  });
                },
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDiaCompleto
                      ? Color.fromRGBO(34, 197, 94, 1)  // Verde quando completo
                      : isSelecionado 
                        ? Color.fromARGB(255, 255, 0, 0)  // Vermelho quando selecionado
                        : Color.fromRGBO(40, 40, 40, 1),  // Cinza escuro quando não selecionado
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDiaAtual && !isSelecionado && !isDiaCompleto
                        ? Color.fromARGB(255, 255, 0, 0).withOpacity(0.5)
                        : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (isDiaCompleto)
                        BoxShadow(
                          color: Color.fromRGBO(34, 197, 94, 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      else if (isSelecionado)
                        BoxShadow(
                          color: Color.fromARGB(255, 255, 0, 0).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dia['nome'].toString().substring(0, 3).toUpperCase(),
                            style: TextStyle(
                              color: (isSelecionado || isDiaCompleto) ? Colors.white : Color.fromRGBO(149, 156, 167, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isDiaAtual && !isSelecionado && !isDiaCompleto)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 0, 0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'HOJE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isDiaCompleto && !isSelecionado)
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                        ],
                      ),
                      Icon(
                        dia['is_cardio'] == 1 
                          ? Icons.directions_run 
                          : Icons.fitness_center,
                        color: (isSelecionado || isDiaCompleto)
                          ? Colors.white.withOpacity(0.9)
                          : Color.fromRGBO(149, 156, 167, 1),
                        size: 32,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dia['is_cardio'] == 1 ? 'Recovery' : (dia['descricao'] ?? 'Treino'),
                            style: TextStyle(
                              color: (isSelecionado || isDiaCompleto) ? Colors.white : Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            dia['is_cardio'] == 1 ? 'Descanso' : 'Treino',
                            style: TextStyle(
                              color: (isSelecionado || isDiaCompleto)
                                ? Colors.white.withOpacity(0.8)
                                : Color.fromRGBO(149, 156, 167, 1),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Card do treino selecionado
        Container(
          padding: EdgeInsets.all(16),      
          decoration: BoxDecoration(
            color: isCompleted 
              ? Color.fromRGBO(20, 50, 30, 1)  // Verde escuro quando completo
              : Color.fromRGBO(40, 40, 40, 1),  // Cinza escuro quando não completo
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                ? Color.fromRGBO(34, 197, 94, 1)  // Borda verde quando completo
                : Color.fromARGB(255, 80, 40, 35),  // Borda marrom quando não completo
              width: 1,
            ),
            boxShadow: [
              if (isCompleted)
                BoxShadow(
                  color: Color.fromRGBO(34, 197, 94, 0.3),
                  blurRadius: 20,
                  spreadRadius: 3,
                )
              else
                BoxShadow(
                  color: Color.fromARGB(255, 255, 0, 0).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted
                        ? Color.fromRGBO(34, 197, 94, 1).withOpacity(0.2)  // Verde claro quando completo
                        : Color.fromARGB(255, 255, 0, 0).withOpacity(0.2),  // Vermelho quando não completo
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCompleted ? 'TREINO COMPLETO' : 'OBJETIVO PRINCIPAL',
                      style: TextStyle(
                        color: isCompleted
                          ? Color.fromRGBO(34, 197, 94, 1)  // Verde quando completo
                          : Color.fromARGB(255, 255, 0, 0),  // Vermelho quando não completo
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isCompleted
                        ? Color.fromRGBO(34, 197, 94, 1)  // Verde quando completo
                        : Color.fromARGB(255, 255, 0, 0),  // Vermelho quando não completo
                      size: 24,
                    ),
                    onPressed: () async {
                      final controller = TextEditingController(
                        text: diaAtual['descricao'] ?? ''
                      );
                      bool isCardio = diaAtual['is_cardio'] == 1;
                      
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
                                    diaAtual['id'],
                                    controller.text
                                  );
                                  await DatabaseService.updateDiaCardio(
                                    diaAtual['id'],
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
              const SizedBox(height: 16),
              Text(
                isCardio ? 'Descanso & Cardio' : (diaAtual['descricao'] ?? 'Treino'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Métricas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricCard(
                    'Volume',
                    '${volumeTotal.toStringAsFixed(0)}',
                    'kg',
                    null,
                  ),
                  _buildMetricCard(
                    'Intensidade',
                    'Média',
                    '',
                    null,
                  ),
                  _buildMetricCard(
                    'Tempo',
                    '${tempoEstimado}m',
                    'Est.',
                    null,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Botão Start Session
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isCardio ? null : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainingScreen(
                          diaId: diaAtual['id'],
                          name: diaAtual['nome'],
                        ),
                      ),
                    );
                    _refreshDias();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted
                      ? Color.fromRGBO(34, 197, 94, 1)  // Verde quando completo
                      : Color.fromARGB(255, 255, 0, 0),  // Vermelho quando não completo
                    disabledBackgroundColor: Color.fromRGBO(100, 100, 100, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: isCompleted
                      ? Color.fromRGBO(34, 197, 94, 0.5)
                      : Color.fromARGB(255, 255, 0, 0).withOpacity(0.5),
                  ).copyWith(
                    elevation: MaterialStateProperty.all(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCardio 
                          ? 'Dia de Descanso' 
                          : isCompleted 
                            ? 'Treino Completo' 
                            : 'Iniciar Treino',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Cards lado a lado: Volume Total e RPE
        if (!isCardio)
          Column(
            children: [
              Row(
                children: [
                  // Card Volume Total
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(40, 40, 40, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                color: Color.fromARGB(255, 255, 0, 0),
                                size: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Volume Total',
                            style: TextStyle(
                              color: Color.fromRGBO(149, 156, 167, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${volumeTotal.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'kg',
                                  style: TextStyle(
                                    color: Color.fromRGBO(149, 156, 167, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Card RPE
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(40, 40, 40, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.speed,
                                color: Color.fromARGB(255, 255, 0, 0),
                                size: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'RPE Médio',
                            style: TextStyle(
                              color: Color.fromRGBO(149, 156, 167, 1),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '7.5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '/10',
                                  style: TextStyle(
                                    color: Color.fromRGBO(149, 156, 167, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Botão Dashboard
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IntensityDashboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(40, 40, 40, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Color.fromARGB(255, 255, 0, 0),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ver Dashboard do Dia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Future<List<Map<String, dynamic>>> _getPRsFromDia(int diaId) async {
    final db = await DatabaseService.getDatabase();
    
    // Buscar todos os exercícios do dia
    final exercicios = await db.rawQuery('''
      SELECT e.id, e.nome
      FROM exercicios e
      INNER JOIN grupos g ON e.grupo_id = g.id
      WHERE g.dia_id = ?
      ORDER BY g.ordem, e.ordem
    ''', [diaId]);
    
    List<Map<String, dynamic>> prs = [];
    
    for (final exercicio in exercicios) {
      // Buscar o maior peso registrado para este exercício nas séries
      final result = await db.rawQuery('''
        SELECT MAX(peso) as pr
        FROM series
        WHERE exercicio_id = ? AND peso IS NOT NULL AND peso > 0
      ''', [exercicio['id']]);
      
      double? prValue;
      
      if (result.isNotEmpty && result[0]['pr'] != null) {
        prValue = result[0]['pr'] as double;
      } else {
        // Se não encontrou nas séries, buscar nos logs pelo nome do exercício
        final logResult = await db.rawQuery('''
          SELECT MAX(peso) as pr
          FROM logs
          WHERE exercicio_nome = ? AND peso IS NOT NULL AND peso > 0
        ''', [exercicio['nome']]);
        
        if (logResult.isNotEmpty && logResult[0]['pr'] != null) {
          prValue = logResult[0]['pr'] as double;
        }
      }
      
      if (prValue != null && prValue > 0) {
        prs.add({
          'nome': exercicio['nome'],
          'pr': prValue,
        });
      }
    }
    
    return prs;
  }
  
  Widget _buildMetricCard(String label, String value, String subtitle, String? change) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(30, 25, 22, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color.fromRGBO(149, 156, 167, 1),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    color: change != null 
                      ? Color.fromARGB(255, 255, 0, 0)
                      : Color.fromRGBO(149, 156, 167, 1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (change != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    change,
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 0, 0),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
