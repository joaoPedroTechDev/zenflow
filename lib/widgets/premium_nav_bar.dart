import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class PremiumNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const PremiumNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavBarItem(icon: Icons.dashboard_rounded, label: "Início"),
      _NavBarItem(icon: Icons.checklist_rounded, label: "Tarefas"),
      _NavBarItem(icon: Icons.edit_note_rounded, label: "Notas"),
      _NavBarItem(icon: Icons.settings_suggest_rounded, label: "Config"),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: GlassContainer(
          borderRadius: 30,
          opacity: 0.12,
          blur: 20,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          borderColor: Colors.white.withOpacity(0.15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = selectedIndex == index;
              final item = items[index];
              
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 16 : 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.neonPurple.withOpacity(0.2) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected ? AppTheme.neonCyan : AppTheme.textSecondary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem {
  final IconData icon;
  final String label;

  _NavBarItem({required this.icon, required this.label});
}
