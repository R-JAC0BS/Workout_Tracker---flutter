import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Serviço para gerenciamento de cronômetros de descanso entre séries.
/// 
/// Este serviço fornece funcionalidades para:
/// - Iniciar cronômetro com tempo alvo e callbacks
/// - Pausar e retomar cronômetro
/// - Parar cronômetro
/// - Consultar tempo decorrido e estado do cronômetro
/// - Emitir notificações com som e vibração quando tempo alvo é atingido
/// 
/// O serviço mantém estado global do timer, permitindo que apenas um
/// cronômetro esteja ativo por vez.
class RestTimerService {
  static Timer? _timer;
  static int _segundosDecorridos = 0;
  static int _tempoAlvo = 0;
  static Function(int)? _onTick;
  static Function()? _onComplete;
  static bool _isPaused = false;
  
  // Plugin de notificações locais
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Inicia cronômetro de descanso
  /// 
  /// Se já existir um cronômetro ativo, ele será parado antes de iniciar o novo.
  /// O cronômetro chama [onTick] a cada segundo com o tempo decorrido,
  /// e chama [onComplete] quando o tempo alvo é atingido.
  /// 
  /// @param tempoAlvoSegundos Tempo alvo em segundos
  /// @param onTick Callback chamado a cada segundo com tempo decorrido
  /// @param onComplete Callback chamado quando tempo alvo é atingido
  static void iniciarCronometro({
    required int tempoAlvoSegundos,
    required Function(int segundosDecorridos) onTick,
    required Function() onComplete,
  }) {
    // Parar cronômetro anterior se existir
    pararCronometro();

    _segundosDecorridos = 0;
    _tempoAlvo = tempoAlvoSegundos;
    _onTick = onTick;
    _onComplete = onComplete;
    _isPaused = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _segundosDecorridos++;
        _onTick?.call(_segundosDecorridos);

        if (_segundosDecorridos >= _tempoAlvo) {
          _onComplete?.call();
          notificarTempoAlvo(); // Emitir notificação quando tempo alvo é atingido
          // Nota: não para o cronômetro automaticamente,
          // permitindo que continue contando após o tempo alvo
        }
      }
    });
  }

  /// Para o cronômetro atual e limpa o estado
  /// 
  /// Cancela o timer ativo e reseta todos os valores para o estado inicial.
  static void pararCronometro() {
    _timer?.cancel();
    _timer = null;
    _segundosDecorridos = 0;
    _tempoAlvo = 0;
    _onTick = null;
    _onComplete = null;
    _isPaused = false;
  }

  /// Pausa o cronômetro
  /// 
  /// O cronômetro continua ativo mas para de contar.
  /// Use [retomarCronometro] para continuar a contagem.
  static void pausarCronometro() {
    _isPaused = true;
  }

  /// Retoma cronômetro pausado
  /// 
  /// Continua a contagem de onde parou.
  static void retomarCronometro() {
    _isPaused = false;
  }

  /// Retorna tempo decorrido atual em segundos
  /// 
  /// @return Tempo decorrido em segundos desde o início do cronômetro
  static int getTempoDecorrido() => _segundosDecorridos;

  /// Verifica se há um cronômetro ativo
  /// 
  /// @return true se há um cronômetro ativo (mesmo que pausado), false caso contrário
  static bool isAtivo() => _timer != null && _timer!.isActive;

  /// Inicializa o sistema de notificações
  /// 
  /// Deve ser chamado uma vez no início do app para configurar
  /// as notificações locais. Configura canal de notificação para Android
  /// e solicita permissões necessárias.
  /// 
  /// @return true se inicialização foi bem-sucedida, false caso contrário
  static Future<bool> inicializarNotificacoes() async {
    if (_isInitialized) {
      return true;
    }

    try {
      // Configuração para Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuração para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Callback quando usuário toca na notificação
          // Por enquanto não fazemos nada, mas poderia navegar para tela de treino
        },
      );

      if (initialized == true) {
        // Criar canal de notificação para Android
        const androidChannel = AndroidNotificationChannel(
          'rest_timer_channel',
          'Cronômetro de Descanso',
          description: 'Notificações do cronômetro de descanso entre séries',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);

        _isInitialized = true;
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erro ao inicializar notificações: $e');
      return false;
    }
  }

  /// Solicita permissões de notificação (necessário para Android 13+)
  /// 
  /// @return true se permissão foi concedida, false caso contrário
  static Future<bool> solicitarPermissoes() async {
    try {
      // Para Android 13+ (API 33+)
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      // Para iOS
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: false,
          sound: true,
        );
        return granted ?? false;
      }

      return true; // Para outras plataformas, assumir permissão concedida
    } catch (e) {
      print('Erro ao solicitar permissões: $e');
      return false;
    }
  }

  /// Emite notificação quando tempo alvo é atingido
  /// 
  /// Verifica permissões antes de emitir notificação.
  /// Emite notificação com som e vibração quando o tempo de descanso
  /// alvo é atingido.
  /// 
  /// A notificação é configurada com:
  /// - Som padrão do sistema
  /// - Vibração (se habilitado no dispositivo)
  /// - Prioridade alta para aparecer como heads-up
  static Future<void> notificarTempoAlvo() async {
    try {
      // Inicializar se ainda não foi inicializado
      if (!_isInitialized) {
        final initialized = await inicializarNotificacoes();
        if (!initialized) {
          print('Falha ao inicializar notificações');
          return;
        }
      }

      // Verificar permissões
      final hasPermission = await _verificarPermissoes();
      if (!hasPermission) {
        print('Permissão de notificação não concedida');
        return;
      }

      // Configuração da notificação para Android
      final androidDetails = AndroidNotificationDetails(
        'rest_timer_channel',
        'Cronômetro de Descanso',
        channelDescription: 'Notificações do cronômetro de descanso entre séries',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        // Usar som padrão do sistema
        sound: null, // null usa o som padrão
        vibrationPattern: Int64List.fromList([0, 500, 250, 500]), // Padrão de vibração
        ticker: 'Tempo de descanso atingido',
      );

      // Configuração da notificação para iOS
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
        sound: 'default',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Emitir notificação
      await _notificationsPlugin.show(
        0, // ID da notificação
        'Tempo de Descanso Atingido! ⏰',
        'Seu tempo de descanso terminou. Pronto para a próxima série?',
        notificationDetails,
      );
    } catch (e) {
      print('Erro ao emitir notificação: $e');
    }
  }

  /// Verifica se as permissões de notificação foram concedidas
  /// 
  /// @return true se permissões foram concedidas, false caso contrário
  static Future<bool> _verificarPermissoes() async {
    try {
      // Para Android
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.areNotificationsEnabled();
        return granted ?? false;
      }

      // Para iOS, assumir que permissões foram concedidas se inicialização foi bem-sucedida
      return _isInitialized;
    } catch (e) {
      print('Erro ao verificar permissões: $e');
      return false;
    }
  }
}
