import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/customAppBar.dart';
import 'package:workout_tracker/Widget/navBar/navBar.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:workout_tracker/service/reload_service.dart';
import 'package:workout_tracker/screens/home_screen.dart';
import 'package:workout_tracker/screens/stats_screen.dart';
import 'package:workout_tracker/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 
  // await resetDatabase();
  
  await DatabaseService.getDatabase();
  await DatabaseService.ensureLogsTableExists();
  await ReloadData.checkAndResetWeeklyData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rastreador de Treinos',
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
              const HistoryScreen(),
              StatsScreen(key: ValueKey(_statsRefreshKey)),
              const PlaceholderScreen(title: 'Eu'),
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
