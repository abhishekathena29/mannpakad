import 'package:flutter/material.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/shared/widgets/app_header.dart';
import 'package:mannpakad/shared/widgets/bottom_nav.dart';
import 'package:mannpakad/shared/widgets/avatar_display.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final milestones = _milestones;
    final earnedMilestones = milestones
        .where((m) => m.isEarned(appState))
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withAlpha(150),
                            AppColors.accent.withAlpha(150),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withAlpha(50)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(50),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: AvatarDisplay(
                              avatar: appState.avatar,
                              size: 80,
                              showLevel: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _RewardStat(
                                icon: Icons.monetization_on_rounded,
                                label: 'Coins',
                                value: appState.progress.totalCoins.toString(),
                                color: const Color(0xFFFFD700),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24,
                              ),
                              _RewardStat(
                                icon: Icons.local_fire_department_rounded,
                                label: 'Streak',
                                value: appState.progress.currentStreak
                                    .toString(),
                                color: const Color(0xFFFF4500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Milestones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${earnedMilestones.length}/${milestones.length} earned',
                          style: TextStyle(color: Colors.white.withAlpha(150)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: milestones.map((milestone) {
                        final earned = milestone.isEarned(appState);
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: earned
                                ? AppColors.primary.withAlpha(40)
                                : Colors.white.withAlpha(10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: earned
                                  ? AppColors.primary.withAlpha(100)
                                  : Colors.white.withAlpha(10),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                milestone.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                milestone.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                milestone.description,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(150),
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    earned ? Icons.check_circle : Icons.lock,
                                    size: 14,
                                    color: earned
                                        ? AppColors.success
                                        : Colors.white38,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${milestone.coins}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: earned
                                          ? AppColors.success
                                          : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Avatar Shop',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                      children: _shopItems.map((item) {
                        final canAfford =
                            appState.progress.totalCoins >= item.price;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withAlpha(10),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Spacer(),
                              Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: canAfford ? () {} : null,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    side: BorderSide(
                                      color: canAfford
                                          ? AppColors.accent
                                          : Colors.white24,
                                    ),
                                    foregroundColor: canAfford
                                        ? AppColors.accent
                                        : Colors.white24,
                                  ),
                                  child: Text(
                                    '${item.price} 🟡',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.calm.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.calm.withAlpha(50)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates,
                                color: AppColors.calmLight,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'How to Earn Coins',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.calmLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _earnRow('+5', 'Complete an exposure'),
                          _earnRow('+10', 'Resist a compulsion'),
                          _earnRow('+3', 'Log a trigger'),
                          _earnRow('+5', 'Complete a lesson'),
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
      ),
    );
  }

  Widget _earnRow(String amount, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white.withAlpha(200))),
        ],
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardStat({
    required this.icon,
    required this.label,
    required this.value,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Milestone {
  final int id;
  final String name;
  final String description;
  final int coins;
  final String icon;
  final int threshold;
  final String type;

  const _Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.coins,
    required this.icon,
    required this.threshold,
    required this.type,
  });

  bool isEarned(AppState appState) {
    switch (type) {
      case 'exposures':
        return appState.progress.totalExposures >= threshold;
      case 'compulsions':
        return appState.progress.compulsionsResisted >= threshold;
      case 'streak':
        return appState.progress.longestStreak >= threshold;
      default:
        return false;
    }
  }
}

class _ShopItem {
  final int id;
  final String name;
  final String type;
  final int price;
  final String emoji;

  const _ShopItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.emoji,
  });
}

const _milestones = [
  _Milestone(
    id: 1,
    name: 'First Steps',
    description: 'Complete your first exposure',
    coins: 10,
    icon: '🌱',
    threshold: 1,
    type: 'exposures',
  ),
  _Milestone(
    id: 2,
    name: 'Getting Brave',
    description: 'Complete 5 exposures',
    coins: 25,
    icon: '💪',
    threshold: 5,
    type: 'exposures',
  ),
  _Milestone(
    id: 3,
    name: 'Uncertainty Friend',
    description: 'Resist 10 compulsions',
    coins: 50,
    icon: '🌊',
    threshold: 10,
    type: 'compulsions',
  ),
  _Milestone(
    id: 4,
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    coins: 75,
    icon: '🔥',
    threshold: 7,
    type: 'streak',
  ),
  _Milestone(
    id: 5,
    name: 'Courage Champion',
    description: 'Complete 25 exposures',
    coins: 100,
    icon: '🏆',
    threshold: 25,
    type: 'exposures',
  ),
  _Milestone(
    id: 6,
    name: 'Discomfort Master',
    description: 'Stay with high SUDs',
    coins: 50,
    icon: '⚡',
    threshold: 1,
    type: 'exposures',
  ),
];

const _shopItems = [
  _ShopItem(
    id: 1,
    name: 'Starry Hat',
    type: 'accessory',
    price: 50,
    emoji: '🎩',
  ),
  _ShopItem(
    id: 2,
    name: 'Rainbow Scarf',
    type: 'accessory',
    price: 75,
    emoji: '🧣',
  ),
  _ShopItem(
    id: 3,
    name: 'Sunset Background',
    type: 'background',
    price: 100,
    emoji: '🌅',
  ),
  _ShopItem(
    id: 4,
    name: 'Galaxy Background',
    type: 'background',
    price: 150,
    emoji: '🌌',
  ),
  _ShopItem(
    id: 5,
    name: 'Golden Crown',
    type: 'cosmetic',
    price: 200,
    emoji: '👑',
  ),
  _ShopItem(
    id: 6,
    name: 'Sparkle Effect',
    type: 'cosmetic',
    price: 125,
    emoji: '✨',
  ),
];
