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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientDark,
          ),
        ),
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motivation Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withAlpha(25),
                            Colors.white.withAlpha(15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: AppColors.gradientPrimary,
                              ),
                            ),
                            child: AvatarDisplay(
                              avatar: appState.avatar,
                              size: 56,
                              showLevel: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${_motivationalMessage()}"',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '— ${appState.avatar?.name ?? 'Companion'}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(150),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      children: [
                        _StatTile(
                          label: 'Total',
                          value: appState.progress.totalExposures.toString(),
                          icon: Icons.grid_view_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        _StatTile(
                          label: 'Resisted',
                          value: appState.progress.compulsionsResisted
                              .toString(),
                          icon: Icons.shield_rounded,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        _StatTile(
                          label: 'Today',
                          value: todaysExposures.toString(),
                          icon: Icons.today_rounded,
                          color: AppColors.calm,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (nextExposure != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(230),
                              AppColors.primaryDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(100),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                appState.setCurrentView(AppView.exposure),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.flash_on_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Ready for a Challenge?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          nextExposure.scenario,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(200),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    const Text(
                      'Exercises',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FeatureCard(
                      leading: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ),
                      title: 'AI Exposure Tasks',
                      description: 'AI-generated personalized tasks',
                      badge: 'NEW',
                      onTap: () => appState.setCurrentView(AppView.aiExposure),
                      accentColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      leading: const Icon(
                        Icons.layers_rounded,
                        color: Colors.white,
                      ),
                      title: 'Fear Ladder',
                      description: 'Build your exposure hierarchy',
                      badge: appState.fearHierarchy.isNotEmpty
                          ? '${appState.fearHierarchy.length}'
                          : null,
                      onTap: () => appState.setCurrentView(AppView.hierarchy),
                      accentColor: AppColors.calm,
                    ),
                    // const SizedBox(height: 12),
                    // FeatureCard(
                    //   leading: const Icon(
                    //     Icons.track_changes_rounded,
                    //     color: Colors.white,
                    //   ),
                    //   title: 'In Vivo Exposure',
                    //   description: 'Real-world exposure with reflection',
                    //   onTap: () => appState.setCurrentView(AppView.exposure),
                    //   accentColor: AppColors.accent,
                    // ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      leading: const Icon(
                        Icons.air_rounded,
                        color: Colors.white,
                      ),
                      title: 'Breathing',
                      description: 'Mindfulness distress tolerance',
                      onTap: () => appState.setCurrentView(AppView.breathing),
                      accentColor: AppColors.clarity,
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      leading: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                      ),
                      title: 'Cognitive Defusion',
                      description: 'ACT-based thought observation',
                      onTap: () => appState.setCurrentView(AppView.defusion),
                      accentColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      leading: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                      ),
                      title: 'Values & Journaling',
                      description: 'Weekly reflection and motivation',
                      onTap: () => appState.setCurrentView(AppView.value),
                      accentColor: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      leading: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                      ),
                      title: 'Simulations',
                      description: 'Gamified imaginal exposure',
                      onTap: () => appState.setCurrentView(AppView.simulation),
                      accentColor: AppColors.calm,
                    ),
                    const SizedBox(height: 24),

                    // Tip Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.calm.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.calm.withAlpha(50)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.calmLight,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inhibitory Learning Tip',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.calmLight,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Vary your exposures to strengthen new learning.',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(150),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
