import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/feature_card.dart';
import '../widgets/avatar_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _motivationalMessage() {
    const messages = [
      'You can handle uncertainty.',
      'Courage is doing it scared.',
      'Every exposure is a victory.',
      'You are stronger than your anxiety.',
      'Progress, not perfection.',
    ];
    return messages[DateTime.now().second % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final today = DateTime.now();
    final todaysExposures = appState.exposureSessions.where((session) {
      final date = session.completedAt;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;

    final nextExposure = appState.fearHierarchy
        .where((item) => !item.completed && item.suds <= 50)
        .cast<FearHierarchyItem?>()
        .firstWhere((item) => item != null, orElse: () => null);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        AvatarDisplay(
                          avatar: appState.avatar,
                          size: 56,
                          showLevel: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_greeting()}, ${appState.userProfile?.name ?? ''}!',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${appState.avatar?.name ?? 'Companion'} says:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"${_motivationalMessage()}"',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatTile(
                        label: 'Total',
                        value: appState.progress.totalExposures.toString(),
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        label: 'Resisted',
                        value: appState.progress.compulsionsResisted.toString(),
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        label: 'Today',
                        value: todaysExposures.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (nextExposure != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => appState.setCurrentView(AppView.exposure),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.flash_on,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ready for a Challenge?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    nextExposure.scenario,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Exercises',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  FeatureCard(
                    leading: const Icon(Icons.layers, color: AppColors.primary),
                    title: 'Fear Ladder',
                    description: 'Build and manage your exposure hierarchy',
                    badge: appState.fearHierarchy.isNotEmpty
                        ? '${appState.fearHierarchy.length} items'
                        : null,
                    onTap: () => appState.setCurrentView(AppView.hierarchy),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    leading: const Icon(
                      Icons.track_changes,
                      color: AppColors.accent,
                    ),
                    title: 'In Vivo Exposure',
                    description: 'Real-world exposure with reflection',
                    onTap: () => appState.setCurrentView(AppView.exposure),
                    accentColor: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    leading: const Icon(Icons.air, color: AppColors.calm),
                    title: 'Breathing',
                    description: 'Mindfulness distress tolerance',
                    onTap: () => appState.setCurrentView(AppView.breathing),
                    accentColor: AppColors.calm,
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    leading: const Icon(
                      Icons.psychology,
                      color: AppColors.clarity,
                    ),
                    title: 'Cognitive Defusion',
                    description: 'ACT-based thought observation',
                    onTap: () => appState.setCurrentView(AppView.defusion),
                    accentColor: AppColors.clarity,
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    leading: const Icon(
                      Icons.edit_note,
                      color: AppColors.primary,
                    ),
                    title: 'Values & Journaling',
                    description: 'Weekly reflection and motivation',
                    onTap: () => appState.setCurrentView(AppView.value),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    leading: const Icon(
                      Icons.sports_esports,
                      color: AppColors.accent,
                    ),
                    title: 'Simulations',
                    description: 'Gamified imaginal exposure',
                    onTap: () => appState.setCurrentView(AppView.simulation),
                    accentColor: AppColors.accent,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.calmLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.calm.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.calm.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.calm,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Inhibitory Learning Tip',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Vary your exposures to strengthen new learning.',
                                style: TextStyle(color: AppColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
