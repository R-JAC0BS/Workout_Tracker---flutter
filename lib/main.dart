import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/Widget/navBar/navBar.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:workout_tracker/service/reload_service.dart';
import 'package:workout_tracker/service/rest_timer_service.dart';
import 'package:workout_tracker/screens/home_screen.dart';
import 'package:workout_tracker/screens/stats_screen.dart';
import 'package:workout_tracker/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 
  // await resetDatabase();
  
  await DatabaseService.getDatabase();
  await DatabaseService.ensureLogsTableExists();
  await ReloadData.checkAndResetWeeklyData();
  
  // Inicializar sistema de notificações
  await RestTimerService.inicializarNotificacoes();
  // Solicitar permissões de notificação
  await RestTimerService.solicitarPermissoes();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(18, 18, 18, 100),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(18, 18, 18, 100),
        canvasColor: const Color.fromRGBO(18, 18, 18, 100),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
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

class _MainNavigatorState extends State<MainNavigator> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _statsRefreshKey = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_fadeController);
    _fadeController.value = 1.0;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) async {
    if (_currentIndex == index) return;

    // Fade out
    _fadeController.animateTo(0.0, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    
    // Aguarda o fade out completar
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Troca a tela
    setState(() {
      _currentIndex = index;
      if (index == 2) {
        _statsRefreshKey++;
      }
    });

    // Aguarda 2 frames para garantir que a tela foi construída e renderizada
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Fade in
    _fadeController.animateTo(1.0, duration: const Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(18, 18, 18, 100),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const TrainingWidget(),
                const HistoryScreen(),
                StatsScreen(key: ValueKey(_statsRefreshKey)),
                const PlaceholderScreen(title: 'Eu'),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NabBarWidget(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
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
