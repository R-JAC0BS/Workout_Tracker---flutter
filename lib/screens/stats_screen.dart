import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/service/log_service.dart';
import 'package:workout_tracker/screens/exercise_stats_screen.dart';
import 'package:workout_tracker/screens/intensity_dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  int _refreshKey = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedGrupo; // Filtro de grupo muscular

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  Future<void> _addTestLog() async {
    try {
      await LogData.addLog(
        exercicioNome: 'Teste',
        peso: 50.0,
        repeticoes: 10,
      );
      print('Log de teste adicionado!');
      _refresh();
    } catch (e) {
      print('Erro ao adicionar log de teste: $e');
    }
  }

  Future<void> _navigateToExerciseStats(String exercicioNome) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseStatsScreen(
          exercicioNome: exercicioNome,
        ),
      ),
    );
    // Atualiza a lista quando voltar
    _refresh();
  }

  Future<void> _navigateToIntensityDashboard() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IntensityDashboardScreen(),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBarWidget(text: 'Status', showBackButton: false),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar exercício...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color.fromRGBO(30, 30, 30, 100),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Botão de Dashboard de Intensidade
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToIntensityDashboard,
                icon: const Icon(Icons.dashboard, color: Colors.white),
                label: const Text(
                  'Dashboard de Intensidade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filtros por grupo muscular
          FutureBuilder<List<String>>(
            future: LogData.getAllGruposWithLogs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              
              final grupos = snapshot.data!;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtrar por grupo',
                      style: TextStyle(
                        color: Color.fromRGBO(149, 156, 167, 100),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Botão "Todos"
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text('Todos'),
                                selected: _selectedGrupo == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedGrupo = null;
                                  });
                                },
                                backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                selectedColor: Colors.red,
                                labelStyle: TextStyle(
                                  color: _selectedGrupo == null ? Colors.white : Colors.grey.shade400,
                                  fontWeight: _selectedGrupo == null ? FontWeight.bold : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: _selectedGrupo == null ? Colors.red : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            // Botões de grupos
                            ...grupos.map((grupo) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(grupo),
                                selected: _selectedGrupo == grupo,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedGrupo = selected ? grupo : null;
                                  });
                                },
                                backgroundColor: const Color.fromRGBO(30, 30, 30, 100),
                                selectedColor: Colors.red,
                                labelStyle: TextStyle(
                                  color: _selectedGrupo == grupo ? Colors.white : Colors.grey.shade400,
                                  fontWeight: _selectedGrupo == grupo ? FontWeight.bold : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: _selectedGrupo == grupo ? Colors.red : Colors.grey.shade700,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
          // Lista de exercícios
          Expanded(
            child: FutureBuilder<List<String>>(
              key: ValueKey(_refreshKey),
              future: LogData.getAllExerciciosWithLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar dados',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  );
                }

                final exercicios = snapshot.data!;
                
                if (exercicios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 80,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum log registrado',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete séries para ver estatísticas',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
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
                
                return FutureBuilder<Map<String, String?>>(
                  future: Future.wait(
                    exercicios.map((ex) => LogData.getGrupoByExercicioNome(ex))
                  ).then((grupos) {
                    return Map.fromIterables(exercicios, grupos);
                  }),
                  builder: (context, gruposSnapshot) {
                    if (!gruposSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      );
                    }
                    
                    final exerciciosComGrupos = gruposSnapshot.data!;
                    
                    // Filtrar exercícios pela busca e pelo grupo selecionado
                    final exerciciosFiltrados = exercicios.where((exercicio) {
                      final matchSearch = exercicio.toLowerCase().contains(_searchQuery);
                      final matchGrupo = _selectedGrupo == null || 
                                         exerciciosComGrupos[exercicio] == _selectedGrupo;
                      return matchSearch && matchGrupo;
                    }).toList();

                    if (exerciciosFiltrados.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum exercício encontrado',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tente buscar por outro nome',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: exerciciosFiltrados.length + 1,
                      itemBuilder: (context, index) {
                        // Adiciona espaçamento no final
                        if (index == exerciciosFiltrados.length) {
                          return const SizedBox(height: 80);
                        }
                        
                        final exercicio = exerciciosFiltrados[index];
                        final grupoNome = exerciciosComGrupos[exercicio];
                  
                        return FutureBuilder<List<dynamic>>(
                          future: Future.wait([
                            LogData.getMaxPeso(exercicio),
                            LogData.getVolumeTotalExercicio(exercicio),
                            LogData.getLogsByExercicio(exercicio),
                          ]),
                          builder: (context, snapshot) {
                            final maxPeso = snapshot.hasData ? snapshot.data![0] as double : 0.0;
                            final volumeTotal = snapshot.hasData ? snapshot.data![1] as double : 0.0;
                            final logs = snapshot.hasData ? snapshot.data![2] as List<Map<String, dynamic>> : [];
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(30, 30, 30, 100),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade800
                                    
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => _navigateToExerciseStats(exercicio),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  exercicio.toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (grupoNome != null)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade800,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    grupoNome,
                                                    style: TextStyle(
                                                      color: Colors.grey.shade400,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildStatItem(
                                                  icon: Icons.fitness_center,
                                                  label: 'Peso Máximo',
                                                  value: '${maxPeso.toStringAsFixed(1)} kg',
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildStatItem(
                                                  icon: Icons.trending_up,
                                                  label: 'Volume Total',
                                                  value: '${volumeTotal.toStringAsFixed(0)} kg',
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildStatItem(
                                                  icon: Icons.history,
                                                  label: 'Registros',
                                                  value: '${logs.length}',
                                                ),
                                              ),
                                            ],
                                          ),
                                              
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color.fromRGBO(149, 156, 167, 100),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color.fromRGBO(149, 156, 167, 100),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
