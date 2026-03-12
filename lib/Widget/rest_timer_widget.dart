import 'package:flutter/material.dart';
import 'package:workout_tracker/service/rest_timer_service.dart';

/// Widget flutuante de cronômetro de descanso entre séries.
/// 
/// Este widget exibe um cronômetro flutuante na parte inferior da tela
/// durante o período de descanso entre séries. Características:
/// 
/// - Posicionado no bottom da tela
/// - Exibe tempo decorrido / tempo alvo (ex: "1:30 / 2:00")
/// - Botões de pausa/retomar e fechar
/// - Indicador visual quando tempo alvo é atingido (mudança de cor)
/// - Animação suave de entrada/saída
/// 
/// Requisitos: US-3.1, US-3.2
class RestTimerWidget extends StatefulWidget {
  /// Tempo alvo em segundos para o descanso
  final int tempoAlvoSegundos;
  
  /// Callback chamado quando o widget é fechado, retorna o tempo decorrido
  final Function(int tempoDecorrido) onClose;
  
  /// Callback opcional chamado quando o tempo alvo é atingido
  final VoidCallback? onTempoAlvoAtingido;

  const RestTimerWidget({
    super.key,
    required this.tempoAlvoSegundos,
    required this.onClose,
    this.onTempoAlvoAtingido,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget>
    with SingleTickerProviderStateMixin {
  int _segundosDecorridos = 0;
  bool _isPaused = false;
  bool _tempoAlvoAtingido = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animação de entrada/saída
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Começa fora da tela (embaixo)
      end: Offset.zero, // Termina na posição normal
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Iniciar cronômetro
    _iniciarCronometro();
    
    // Animar entrada
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _iniciarCronometro() {
    RestTimerService.iniciarCronometro(
      tempoAlvoSegundos: widget.tempoAlvoSegundos,
      onTick: (segundos) {
        if (mounted) {
          setState(() {
            _segundosDecorridos = segundos;
            
            // Verificar se tempo alvo foi atingido
            if (segundos >= widget.tempoAlvoSegundos && !_tempoAlvoAtingido) {
              _tempoAlvoAtingido = true;
              widget.onTempoAlvoAtingido?.call();
              
              // Fechar cronômetro automaticamente após 3 segundos
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  _fechar();
                }
              });
            }
          });
        }
      },
      onComplete: () {
        // onComplete é chamado quando tempo alvo é atingido
        // Já tratado no onTick acima
      },
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        RestTimerService.pausarCronometro();
      } else {
        RestTimerService.retomarCronometro();
      }
    });
  }

  void _fechar() async {
    // Animar saída
    await _animationController.reverse();
    
    // Parar cronômetro
    RestTimerService.pararCronometro();
    
    // Chamar callback de fechamento com o tempo decorrido
    widget.onClose(_segundosDecorridos);
  }

  /// Formata segundos para string MM:SS
  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(1, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Determinar cor baseado no estado
    Color backgroundColor;
    Color textColor;
    
    if (_tempoAlvoAtingido) {
      // Verde quando tempo alvo é atingido
      backgroundColor = Colors.green.shade700;
      textColor = Colors.white;
    } else {
      // Cor padrão (cinza escuro)
      backgroundColor = const Color.fromRGBO(30, 30, 30, 1);
      textColor = Colors.white;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ícone de cronômetro
            Icon(
              _tempoAlvoAtingido ? Icons.check_circle : Icons.timer,
              color: textColor,
              size: 28,
            ),
            
            const SizedBox(width: 12),
            
            // Tempo decorrido / tempo alvo
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tempoAlvoAtingido ? 'Tempo Atingido!' : 'Descanso',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatarTempo(_segundosDecorridos)} / ${_formatarTempo(widget.tempoAlvoSegundos)}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Botão de pausa/retomar
            IconButton(
              onPressed: _togglePause,
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: textColor,
                size: 28,
              ),
              tooltip: _isPaused ? 'Retomar' : 'Pausar',
            ),
            
            // Botão de fechar
            IconButton(
              onPressed: _fechar,
              icon: Icon(
                Icons.close,
                color: textColor,
                size: 24,
              ),
              tooltip: 'Fechar',
            ),
          ],
        ),
      ),
    );
  }
}
