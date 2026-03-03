import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/screens/intensity_dashboard_screen.dart';
import 'package:workout_tracker/service/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Inicializar sqflite_ffi para testes
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('IntensityDashboardScreen pode ser instanciada', (WidgetTester tester) async {
    // Inicializar banco de dados
    await DatabaseService.getDatabase();

    // Construir a tela
    await tester.pumpWidget(
      const MaterialApp(
        home: IntensityDashboardScreen(),
      ),
    );

    // Verificar que a tela foi criada
    expect(find.byType(IntensityDashboardScreen), findsOneWidget);
    
    // Verificar que o loading indicator aparece inicialmente
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('IntensityDashboardScreen exibe mensagem quando não há dados', (WidgetTester tester) async {
    // Inicializar banco de dados
    await DatabaseService.getDatabase();

    // Construir a tela
    await tester.pumpWidget(
      const MaterialApp(
        home: IntensityDashboardScreen(),
      ),
    );

    // Aguardar carregamento
    await tester.pumpAndSettle();

    // Verificar que a mensagem de erro aparece (não há sessões finalizadas)
    expect(find.text('Nenhuma sessão de treino finalizada encontrada'), findsOneWidget);
  });
}
