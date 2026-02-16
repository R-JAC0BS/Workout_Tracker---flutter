import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:workout_tracker/data/database.dart';

class ModalDayWidget extends StatelessWidget {
  const ModalDayWidget({super.key, required this.groupId});
  final int groupId;


  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: Colors.grey.shade900,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color.fromARGB(255, 70, 70, 70),
            width: 1.2,
          ),
        ),

        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Grupo muscular", style: TextStyle(color: Colors.white)),
        ),

        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // 👈 tudo à esquerda
            children: [
              TextField(
                controller: controller,

                decoration: InputDecoration(
                  labelText: 'ex : costas, biceps...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 255, 0, 0),
                      width: 2,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 255, 0, 0),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Adicione o grupo muscular',
                style: TextStyle(color: Color.fromARGB(255, 121, 118, 118)),
              ),
            ],
          ),
        ),

        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  print(controller.text);
                  final nome = controller.text.trim();
                  if (nome.isEmpty) return;
                  await DatabaseService.insertGrupo(diaId: groupId, nome: nome);
                  Navigator.pop(context);
                },
                child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child:  Text('Cancelar',style: TextStyle(
                  color: Colors.white
                ), 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
