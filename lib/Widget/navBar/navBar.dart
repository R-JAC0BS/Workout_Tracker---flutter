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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade800,
              width: 1,
            ),
          
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                  label: 'Histórico',
                  index: 1,
                  isEnabled: true,
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