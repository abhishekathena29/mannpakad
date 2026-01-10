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
      _NavItem(AppView.home, Icons.home_rounded, 'Home'),
      _NavItem(AppView.hierarchy, Icons.view_agenda_rounded, 'Ladder'),
      _NavItem(AppView.tracker, Icons.insights_rounded, 'Track'),
      _NavItem(AppView.learn, Icons.school_rounded, 'Learn'),
      _NavItem(AppView.rewards, Icons.emoji_events_rounded, 'Rewards'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1a1a2e,
        ).withAlpha(240), // Semi-transparent dark bg
        border: Border(top: BorderSide(color: Colors.white.withAlpha(20))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = appState.currentView == item.view;
          return GestureDetector(
            onTap: () => appState.setCurrentView(item.view),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(50),
                          AppColors.primary.withAlpha(20),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                border: isActive
                    ? Border.all(color: AppColors.primary.withAlpha(80))
                    : Border.all(color: Colors.transparent),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      item.icon,
                      size: isActive ? 26 : 24,
                      color: isActive
                          ? AppColors.primary
                          : Colors.white.withAlpha(100),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withAlpha(100),
                      letterSpacing: isActive ? 0.3 : 0,
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
