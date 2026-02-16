import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget  {
  final String texto;

  const TitleWidget({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: Colors.white,
        
      ),
    );
  }
  

}