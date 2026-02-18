import 'package:flutter/material.dart';

class NabBarWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const NabBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<NabBarWidget> createState() => _NabBarWidgetState();
}

class _NabBarWidgetState extends State<NabBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        
        color: const Color(0xFF1C1C1E),
        border: BorderDirectional(
          top: BorderSide(
            color: Colors.grey.shade800
          )
        )
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1.2),
          
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.calendar_today,
                label: 'Treino',
                index: 0,
                isEnabled: true,
              ),
              _buildNavItem(
                icon: Icons.access_time,
                label: 'Historico',
                index: 1,
                isEnabled: false,
              ),
              _buildNavItem(
                icon: Icons.bar_chart,
                label: 'Status',
                index: 2,
                isEnabled: true,
              ),
              _buildNavItem(
                icon: Icons.account_circle,
                label: 'Eu',
                index: 3,
                isEnabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isEnabled,
  }) {
    final isSelected = widget.currentIndex == index;
    final color = !isEnabled
        ? Colors.grey.shade700
        : isSelected
            ? Colors.red
            : Colors.grey.shade400;

    return GestureDetector(
      onTap: isEnabled ? () => widget.onTap(index) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}