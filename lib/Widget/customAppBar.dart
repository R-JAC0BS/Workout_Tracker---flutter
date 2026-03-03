import 'package:flutter/material.dart';
import 'package:workout_tracker/Widget/title.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final bool showBackButton;
  final List<Widget>? actions;

  const AppBarWidget({
    super.key, 
    required this.text,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: TitleWidget(texto: text),
      ),
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const BackButton(color: Colors.white),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      backgroundColor: const Color.fromRGBO(18, 18, 18, 100),
      toolbarHeight: kToolbarHeight + 20,
      actions: actions != null
          ? [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(children: actions!),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
