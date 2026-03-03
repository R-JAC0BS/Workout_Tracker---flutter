import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/service/intensity_service.dart';

void main() {
  group('IntensityService - Conversão RPE↔RIR', () {
    group('converterRPEparaRIR', () {
      test('RPE 10 deve retornar RIR 0 (falha)', () {
        expect(IntensityService.converterRPEparaRIR(10), equals(0));
      });

      test('RPE 9 deve retornar RIR 1', () {
        expect(IntensityService.converterRPEparaRIR(9), equals(1));
      });

      test('RPE 8 deve retornar RIR 2', () {
        expect(IntensityService.converterRPEparaRIR(8), equals(2));
      });

      test('RPE 7 deve retornar RIR 3', () {
        expect(IntensityService.converterRPEparaRIR(7), equals(3));
      });

      test('RPE 6 deve retornar RIR 4', () {
        expect(IntensityService.converterRPEparaRIR(6), equals(4));
      });

      test('RPE 5 deve retornar RIR 5+', () {
        expect(IntensityService.converterRPEparaRIR(5), equals(5));
      });

      test('RPE 4 deve retornar RIR 5+', () {
        expect(IntensityService.converterRPEparaRIR(4), equals(5));
      });

      test('RPE 1 deve retornar RIR 5+', () {
        expect(IntensityService.converterRPEparaRIR(1), equals(5));
      });

      test('RPE acima de 10 deve retornar RIR 0', () {
        expect(IntensityService.converterRPEparaRIR(11), equals(0));
        expect(IntensityService.converterRPEparaRIR(15), equals(0));
      });
    });

    group('converterRIRparaRPE', () {
      test('RIR 0 deve retornar RPE 10 (falha)', () {
        expect(IntensityService.converterRIRparaRPE(0), equals(10));
      });

      test('RIR 1 deve retornar RPE 9', () {
        expect(IntensityService.converterRIRparaRPE(1), equals(9));
      });

      test('RIR 2 deve retornar RPE 8', () {
        expect(IntensityService.converterRIRparaRPE(2), equals(8));
      });

      test('RIR 3 deve retornar RPE 7', () {
        expect(IntensityService.converterRIRparaRPE(3), equals(7));
      });

      test('RIR 4 deve retornar RPE 6', () {
        expect(IntensityService.converterRIRparaRPE(4), equals(6));
      });

      test('RIR 5 deve retornar RPE 5', () {
        expect(IntensityService.converterRIRparaRPE(5), equals(5));
      });

      test('RIR 6+ deve retornar RPE 5', () {
        expect(IntensityService.converterRIRparaRPE(6), equals(5));
        expect(IntensityService.converterRIRparaRPE(10), equals(5));
      });
    });

    group('Conversão round-trip RPE→RIR→RPE', () {
      test('RPE 10 deve ser preservado após round-trip', () {
        final rpe = 10;
        final rir = IntensityService.converterRPEparaRIR(rpe);
        final rpeRecuperado = IntensityService.converterRIRparaRPE(rir);
        expect(rpeRecuperado, equals(rpe));
      });

      test('RPE 9 deve ser preservado após round-trip', () {
        final rpe = 9;
        final rir = IntensityService.converterRPEparaRIR(rpe);
        final rpeRecuperado = IntensityService.converterRIRparaRPE(rir);
        expect(rpeRecuperado, equals(rpe));
      });

      test('RPE 8 deve ser preservado após round-trip', () {
        final rpe = 8;
        final rir = IntensityService.converterRPEparaRIR(rpe);
        final rpeRecuperado = IntensityService.converterRIRparaRPE(rir);
        expect(rpeRecuperado, equals(rpe));
      });

      test('RPE 7 deve ser preservado após round-trip', () {
        final rpe = 7;
        final rir = IntensityService.converterRPEparaRIR(rpe);
        final rpeRecuperado = IntensityService.converterRIRparaRPE(rir);
        expect(rpeRecuperado, equals(rpe));
      });

      test('RPE 6 deve ser preservado após round-trip', () {
        final rpe = 6;
        final rir = IntensityService.converterRPEparaRIR(rpe);
        final rpeRecuperado = IntensityService.converterRIRparaRPE(rir);
        expect(rpeRecuperado, equals(rpe));
      });

      test('RPE 5 deve ser preservado após round-trip', () {
        final rpe = 5;
        final rir = IntensityService.converterRPEparaRIR(rpe);
        final rpeRecuperado = IntensityService.converterRIRparaRPE(rir);
        expect(rpeRecuperado, equals(rpe));
      });
    });

    group('Conversão round-trip RIR→RPE→RIR', () {
      test('RIR 0 deve ser preservado após round-trip', () {
        final rir = 0;
        final rpe = IntensityService.converterRIRparaRPE(rir);
        final rirRecuperado = IntensityService.converterRPEparaRIR(rpe);
        expect(rirRecuperado, equals(rir));
      });

      test('RIR 1 deve ser preservado após round-trip', () {
        final rir = 1;
        final rpe = IntensityService.converterRIRparaRPE(rir);
        final rirRecuperado = IntensityService.converterRPEparaRIR(rpe);
        expect(rirRecuperado, equals(rir));
      });

      test('RIR 2 deve ser preservado após round-trip', () {
        final rir = 2;
        final rpe = IntensityService.converterRIRparaRPE(rir);
        final rirRecuperado = IntensityService.converterRPEparaRIR(rpe);
        expect(rirRecuperado, equals(rir));
      });

      test('RIR 3 deve ser preservado após round-trip', () {
        final rir = 3;
        final rpe = IntensityService.converterRIRparaRPE(rir);
        final rirRecuperado = IntensityService.converterRPEparaRIR(rpe);
        expect(rirRecuperado, equals(rir));
      });

      test('RIR 4 deve ser preservado após round-trip', () {
        final rir = 4;
        final rpe = IntensityService.converterRIRparaRPE(rir);
        final rirRecuperado = IntensityService.converterRPEparaRIR(rpe);
        expect(rirRecuperado, equals(rir));
      });

      test('RIR 5 deve ser preservado após round-trip', () {
        final rir = 5;
        final rpe = IntensityService.converterRIRparaRPE(rir);
        final rirRecuperado = IntensityService.converterRPEparaRIR(rpe);
        expect(rirRecuperado, equals(rir));
      });
    });
  });

  group('IntensityService - Validação', () {
    group('validarRPE', () {
      test('RPE 1 deve ser válido', () {
        expect(IntensityService.validarRPE(1), isTrue);
      });

      test('RPE 5 deve ser válido', () {
        expect(IntensityService.validarRPE(5), isTrue);
      });

      test('RPE 10 deve ser válido', () {
        expect(IntensityService.validarRPE(10), isTrue);
      });

      test('RPE 0 deve ser inválido', () {
        expect(IntensityService.validarRPE(0), isFalse);
      });

      test('RPE 11 deve ser inválido', () {
        expect(IntensityService.validarRPE(11), isFalse);
      });

      test('RPE negativo deve ser inválido', () {
        expect(IntensityService.validarRPE(-1), isFalse);
        expect(IntensityService.validarRPE(-5), isFalse);
      });

      test('RPE muito alto deve ser inválido', () {
        expect(IntensityService.validarRPE(15), isFalse);
        expect(IntensityService.validarRPE(100), isFalse);
      });
    });

    group('validarRIR', () {
      test('RIR 0 deve ser válido', () {
        expect(IntensityService.validarRIR(0), isTrue);
      });

      test('RIR 1 deve ser válido', () {
        expect(IntensityService.validarRIR(1), isTrue);
      });

      test('RIR 5 deve ser válido', () {
        expect(IntensityService.validarRIR(5), isTrue);
      });

      test('RIR 6+ deve ser válido', () {
        expect(IntensityService.validarRIR(6), isTrue);
        expect(IntensityService.validarRIR(10), isTrue);
        expect(IntensityService.validarRIR(100), isTrue);
      });

      test('RIR negativo deve ser inválido', () {
        expect(IntensityService.validarRIR(-1), isFalse);
        expect(IntensityService.validarRIR(-5), isFalse);
      });
    });
  });

  group('IntensityService - Cálculos de Intensidade', () {
    group('calcularTUTSugerido', () {
      test('10 repetições devem sugerir 40 segundos de TUT', () {
        expect(IntensityService.calcularTUTSugerido(10), equals(40));
      });

      test('5 repetições devem sugerir 20 segundos de TUT', () {
        expect(IntensityService.calcularTUTSugerido(5), equals(20));
      });

      test('1 repetição deve sugerir 4 segundos de TUT', () {
        expect(IntensityService.calcularTUTSugerido(1), equals(4));
      });

      test('0 repetições devem sugerir 0 segundos de TUT', () {
        expect(IntensityService.calcularTUTSugerido(0), equals(0));
      });

      test('15 repetições devem sugerir 60 segundos de TUT', () {
        expect(IntensityService.calcularTUTSugerido(15), equals(60));
      });
    });

    group('Alerta de TUT Baixo (70% do sugerido)', () {
      test('TUT de 25s para 10 reps (sugerido 40s) deve disparar alerta', () {
        final tutSugerido = IntensityService.calcularTUTSugerido(10);
        final limiteMinimo = (tutSugerido * 0.7).round();
        final tutReal = 25;
        expect(tutReal < limiteMinimo, isTrue, reason: 'TUT $tutReal < $limiteMinimo deve disparar alerta');
      });

      test('TUT de 28s para 10 reps (sugerido 40s, limite 28s) não deve disparar alerta', () {
        final tutSugerido = IntensityService.calcularTUTSugerido(10);
        final limiteMinimo = (tutSugerido * 0.7).round();
        final tutReal = 28;
        expect(tutReal < limiteMinimo, isFalse, reason: 'TUT $tutReal >= $limiteMinimo não deve disparar alerta');
      });

      test('TUT de 40s para 10 reps (sugerido 40s) não deve disparar alerta', () {
        final tutSugerido = IntensityService.calcularTUTSugerido(10);
        final limiteMinimo = (tutSugerido * 0.7).round();
        final tutReal = 40;
        expect(tutReal < limiteMinimo, isFalse, reason: 'TUT $tutReal >= $limiteMinimo não deve disparar alerta');
      });

      test('TUT de 10s para 5 reps (sugerido 20s, limite 14s) deve disparar alerta', () {
        final tutSugerido = IntensityService.calcularTUTSugerido(5);
        final limiteMinimo = (tutSugerido * 0.7).round();
        final tutReal = 10;
        expect(tutReal < limiteMinimo, isTrue, reason: 'TUT $tutReal < $limiteMinimo deve disparar alerta');
      });

      test('TUT de 14s para 5 reps (sugerido 20s, limite 14s) não deve disparar alerta', () {
        final tutSugerido = IntensityService.calcularTUTSugerido(5);
        final limiteMinimo = (tutSugerido * 0.7).round();
        final tutReal = 14;
        expect(tutReal < limiteMinimo, isFalse, reason: 'TUT $tutReal >= $limiteMinimo não deve disparar alerta');
      });

      test('TUT de 35s para 15 reps (sugerido 60s, limite 42s) deve disparar alerta', () {
        final tutSugerido = IntensityService.calcularTUTSugerido(15);
        final limiteMinimo = (tutSugerido * 0.7).round();
        final tutReal = 35;
        expect(tutReal < limiteMinimo, isTrue, reason: 'TUT $tutReal < $limiteMinimo deve disparar alerta');
      });
    });

    group('calcularDensidade', () {
      test('1000kg em 600 segundos (10min) deve retornar 100 kg/min', () {
        final densidade = IntensityService.calcularDensidade(1000, 600);
        expect(densidade, equals(100.0));
      });

      test('5000kg em 3600 segundos (60min) deve retornar ~83.33 kg/min', () {
        final densidade = IntensityService.calcularDensidade(5000, 3600);
        expect(densidade, closeTo(83.33, 0.01));
      });

      test('500kg em 300 segundos (5min) deve retornar 100 kg/min', () {
        final densidade = IntensityService.calcularDensidade(500, 300);
        expect(densidade, equals(100.0));
      });

      test('0kg em qualquer tempo deve retornar 0 kg/min', () {
        final densidade = IntensityService.calcularDensidade(0, 600);
        expect(densidade, equals(0.0));
      });

      test('Tempo 0 deve retornar 0 kg/min (evitar divisão por zero)', () {
        final densidade = IntensityService.calcularDensidade(1000, 0);
        expect(densidade, equals(0.0));
      });

      test('2400kg em 1800 segundos (30min) deve retornar 80 kg/min', () {
        final densidade = IntensityService.calcularDensidade(2400, 1800);
        expect(densidade, equals(80.0));
      });
    });

    group('detectarRiscoOvertraining', () {
      test('RPE médio de 9.5 deve detectar risco de overtraining', () {
        expect(IntensityService.detectarRiscoOvertraining(9.5), isTrue);
      });

      test('RPE médio de 9.1 deve detectar risco de overtraining', () {
        expect(IntensityService.detectarRiscoOvertraining(9.1), isTrue);
      });

      test('RPE médio de 10.0 deve detectar risco de overtraining', () {
        expect(IntensityService.detectarRiscoOvertraining(10.0), isTrue);
      });

      test('RPE médio de 9.0 não deve detectar risco (limite)', () {
        expect(IntensityService.detectarRiscoOvertraining(9.0), isFalse);
      });

      test('RPE médio de 8.9 não deve detectar risco', () {
        expect(IntensityService.detectarRiscoOvertraining(8.9), isFalse);
      });

      test('RPE médio de 8.0 não deve detectar risco', () {
        expect(IntensityService.detectarRiscoOvertraining(8.0), isFalse);
      });

      test('RPE médio de 7.5 não deve detectar risco', () {
        expect(IntensityService.detectarRiscoOvertraining(7.5), isFalse);
      });

      test('RPE médio de 5.0 não deve detectar risco', () {
        expect(IntensityService.detectarRiscoOvertraining(5.0), isFalse);
      });

      test('RPE médio de 0.0 não deve detectar risco', () {
        expect(IntensityService.detectarRiscoOvertraining(0.0), isFalse);
      });
    });

    group('calcularScoreIntensidade', () {
      test('Score deve estar entre 0 e 100 para valores típicos', () {
        final score = IntensityService.calcularScoreIntensidade(
          volumeTotal: 3000,
          rpeMedio: 8.0,
          densidade: 40,
          tutTotal: 1200,
        );
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('Score deve ser 0 quando todas as métricas são zero', () {
        final score = IntensityService.calcularScoreIntensidade(
          volumeTotal: 0,
          rpeMedio: 1.0,
          densidade: 0,
          tutTotal: 0,
        );
        expect(score, equals(0));
      });

      test('Score deve ser 100 quando todas as métricas estão no máximo', () {
        final score = IntensityService.calcularScoreIntensidade(
          volumeTotal: 5000,
          rpeMedio: 10.0,
          densidade: 50,
          tutTotal: 1800,
        );
        expect(score, equals(100));
      });

      test('Score deve ser limitado a 100 mesmo com valores acima das referências', () {
        final score = IntensityService.calcularScoreIntensidade(
          volumeTotal: 10000,
          rpeMedio: 10.0,
          densidade: 100,
          tutTotal: 3600,
        );
        expect(score, equals(100));
      });

      test('Score deve refletir peso maior do RPE (40%)', () {
        // Teste com RPE alto e outras métricas baixas
        final scoreRPEAlto = IntensityService.calcularScoreIntensidade(
          volumeTotal: 1000,
          rpeMedio: 10.0,
          densidade: 10,
          tutTotal: 300,
        );
        
        // Teste com RPE baixo e outras métricas altas
        final scoreRPEBaixo = IntensityService.calcularScoreIntensidade(
          volumeTotal: 4000,
          rpeMedio: 1.0,
          densidade: 40,
          tutTotal: 1500,
        );
        
        // RPE alto deve ter impacto significativo mesmo com outras métricas baixas
        expect(scoreRPEAlto, greaterThan(30));
      });

      test('Score deve calcular corretamente com valores de referência médios', () {
        // Volume: 2500kg (50% de 5000) = 0.5 norm
        // RPE: 5.5 (meio da escala 1-10) = 0.5 norm
        // Densidade: 25 kg/min (50% de 50) = 0.5 norm
        // TUT: 900s (50% de 1800) = 0.5 norm
        // Score esperado: 0.5 * 100 = 50
        final score = IntensityService.calcularScoreIntensidade(
          volumeTotal: 2500,
          rpeMedio: 5.5,
          densidade: 25,
          tutTotal: 900,
        );
        expect(score, equals(50));
      });

      test('Score deve normalizar RPE corretamente (escala 1-10)', () {
        // RPE 1 (mínimo) deve contribuir 0
        final scoreMin = IntensityService.calcularScoreIntensidade(
          volumeTotal: 0,
          rpeMedio: 1.0,
          densidade: 0,
          tutTotal: 0,
        );
        expect(scoreMin, equals(0));
        
        // RPE 10 (máximo) deve contribuir 40% do score
        final scoreMax = IntensityService.calcularScoreIntensidade(
          volumeTotal: 0,
          rpeMedio: 10.0,
          densidade: 0,
          tutTotal: 0,
        );
        expect(scoreMax, equals(40));
      });

      test('Score deve aplicar pesos corretos: volume 30%, RPE 40%, densidade 20%, TUT 10%', () {
        // Testar cada métrica isoladamente no máximo
        
        // Apenas volume no máximo (5000kg)
        final scoreVolume = IntensityService.calcularScoreIntensidade(
          volumeTotal: 5000,
          rpeMedio: 1.0,
          densidade: 0,
          tutTotal: 0,
        );
        expect(scoreVolume, equals(30));
        
        // Apenas RPE no máximo (10)
        final scoreRPE = IntensityService.calcularScoreIntensidade(
          volumeTotal: 0,
          rpeMedio: 10.0,
          densidade: 0,
          tutTotal: 0,
        );
        expect(scoreRPE, equals(40));
        
        // Apenas densidade no máximo (50 kg/min)
        final scoreDensidade = IntensityService.calcularScoreIntensidade(
          volumeTotal: 0,
          rpeMedio: 1.0,
          densidade: 50,
          tutTotal: 0,
        );
        expect(scoreDensidade, equals(20));
        
        // Apenas TUT no máximo (1800s)
        final scoreTUT = IntensityService.calcularScoreIntensidade(
          volumeTotal: 0,
          rpeMedio: 1.0,
          densidade: 0,
          tutTotal: 1800,
        );
        expect(scoreTUT, equals(10));
      });

      test('Score deve ser consistente com valores reais de treino', () {
        // Treino leve: volume baixo, RPE baixo
        final scoreLeve = IntensityService.calcularScoreIntensidade(
          volumeTotal: 1500,
          rpeMedio: 6.0,
          densidade: 20,
          tutTotal: 600,
        );
        expect(scoreLeve, lessThan(50));
        
        // Treino moderado
        final scoreModerado = IntensityService.calcularScoreIntensidade(
          volumeTotal: 3000,
          rpeMedio: 7.5,
          densidade: 35,
          tutTotal: 1200,
        );
        expect(scoreModerado, greaterThan(40));
        expect(scoreModerado, lessThan(70));
        
        // Treino intenso: volume alto, RPE alto
        final scoreIntenso = IntensityService.calcularScoreIntensidade(
          volumeTotal: 4500,
          rpeMedio: 9.0,
          densidade: 45,
          tutTotal: 1600,
        );
        expect(scoreIntenso, greaterThan(70));
      });
    });
  });
}
