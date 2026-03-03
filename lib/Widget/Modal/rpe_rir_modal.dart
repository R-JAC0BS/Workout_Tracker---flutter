import 'package:flutter/material.dart';
import 'package:workout_tracker/service/intensity_service.dart';

/// Modal para seleção rápida de RPE ou RIR após completar uma série
/// 
/// Permite ao usuário escolher entre:
/// - RPE (Rate of Perceived Exertion): escala 6-10
/// - RIR (Reps in Reserve): escala 0-4
/// 
/// Mostra conversão automática em tempo real entre RPE e RIR
class RPERIRModal extends StatefulWidget {
  final Function(int? rpe, int? rir) onSave;
  
  const RPERIRModal({
    super.key,
    required this.onSave,
  });

  @override
  State<RPERIRModal> createState() => _RPERIRModalState();
}

class _RPERIRModalState extends State<RPERIRModal> {
  int? _selectedRPE;
  int? _selectedRIR;
  bool _isRPEMode = true; // true = RPE, false = RIR

  void _selectRPE(int rpe) {
    setState(() {
      _selectedRPE = rpe;
      _selectedRIR = IntensityService.converterRPEparaRIR(rpe);
    });
  }

  void _selectRIR(int rir) {
    setState(() {
      _selectedRIR = rir;
      _selectedRPE = IntensityService.converterRIRparaRPE(rir);
    });
  }

  void _save() {
    widget.onSave(_selectedRPE, _selectedRIR);
    Navigator.of(context).pop();
  }

  void _skip() {
    widget.onSave(null, null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'Como foi a série?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione a intensidade percebida',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Toggle RPE/RIR
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(20, 20, 20, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isRPEMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isRPEMode 
                            ? const Color.fromARGB(255, 255, 0, 0)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'RPE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: _isRPEMode ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (_isRPEMode) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Esforço percebido',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isRPEMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isRPEMode 
                            ? const Color.fromARGB(255, 255, 0, 0)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'RIR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: !_isRPEMode ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (!_isRPEMode) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Reps em reserva',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botões de seleção
            if (_isRPEMode) ...[
              // RPE 6-10
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int rpe = 6; rpe <= 10; rpe++)
                    _buildSelectionButton(
                      value: rpe,
                      isSelected: _selectedRPE == rpe,
                      onTap: () => _selectRPE(rpe),
                      color: _getRPEColor(rpe),
                    ),
                ],
              ),
            ] else ...[
              // RIR 0-4
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int rir = 0; rir <= 4; rir++)
                    _buildSelectionButton(
                      value: rir,
                      isSelected: _selectedRIR == rir,
                      onTap: () => _selectRIR(rir),
                      color: _getRIRColor(rir),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            
            // Conversão automática
            if (_selectedRPE != null && _selectedRIR != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(20, 20, 20, 1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromRGBO(50, 50, 50, 1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'RPE $_selectedRPE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.swap_horiz,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'RIR $_selectedRIR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pular',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedRPE != null ? _save : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                      disabledBackgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        color: _selectedRPE != null ? Colors.white : Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton({
    required int value,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color : const Color.fromRGBO(50, 50, 50, 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color.fromRGBO(70, 70, 70, 1),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getRPEColor(int rpe) {
    if (rpe >= 9) return const Color.fromARGB(255, 255, 0, 0); // Vermelho - muito alto
    if (rpe >= 8) return Colors.orange; // Laranja - alto
    if (rpe >= 7) return Colors.yellow.shade700; // Amarelo - moderado
    return Colors.green; // Verde - baixo
  }

  Color _getRIRColor(int rir) {
    if (rir == 0) return const Color.fromARGB(255, 255, 0, 0); // Vermelho - falha
    if (rir == 1) return Colors.orange; // Laranja - muito próximo da falha
    if (rir == 2) return Colors.yellow.shade700; // Amarelo - moderado
    return Colors.green; // Verde - confortável
  }
}
