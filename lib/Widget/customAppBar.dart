import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/title.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  const AppBarWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: TitleWidget(texto: text),
      ),
      backgroundColor: Colors.grey.shade900,
      toolbarHeight: kToolbarHeight + 20,
      
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
