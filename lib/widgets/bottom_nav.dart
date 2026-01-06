import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final items = const [
      _NavItem(AppView.home, Icons.home, 'Home'),
      _NavItem(AppView.hierarchy, Icons.layers, 'Ladder'),
      _NavItem(AppView.tracker, Icons.track_changes, 'Track'),
      _NavItem(AppView.learn, Icons.menu_book, 'Learn'),
      _NavItem(AppView.rewards, Icons.card_giftcard, 'Rewards'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = appState.currentView == item.view;
          return InkWell(
            onTap: () => appState.setCurrentView(item.view),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon,
                      color: isActive ? AppColors.primary : AppColors.mutedText),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive ? AppColors.primary : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final AppView view;
  final IconData icon;
  final String label;

  const _NavItem(this.view, this.icon, this.label);
}
