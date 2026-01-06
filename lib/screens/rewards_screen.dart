import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/avatar_display.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final milestones = _milestones;
    final earnedMilestones = milestones.where((m) => m.isEarned(appState)).toList();

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
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.calmLight, AppColors.accentLight],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        AvatarDisplay(avatar: appState.avatar, size: 72, showLevel: true),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _RewardStat(icon: Icons.monetization_on, label: 'Coins', value: appState.progress.totalCoins.toString()),
                            _RewardStat(icon: Icons.local_fire_department, label: 'Streak', value: appState.progress.currentStreak.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Milestones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${earnedMilestones.length}/${milestones.length} earned'),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: earned ? AppColors.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(milestone.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 8),
                            Text(milestone.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 6),
                            Text(milestone.description, style: TextStyle(color: AppColors.mutedText, fontSize: 11), textAlign: TextAlign.center),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(earned ? Icons.check_circle : Icons.lock, size: 14, color: earned ? AppColors.primary : AppColors.mutedText),
                                const SizedBox(width: 4),
                                Text('+${milestone.coins}', style: TextStyle(fontSize: 11, color: earned ? AppColors.primary : AppColors.mutedText)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Avatar Shop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: _shopItems.map((item) {
                      final canAfford = appState.progress.totalCoins >= item.price;
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 6),
                            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: canAfford ? () {} : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                ),
                                child: Text('${item.price}', style: const TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.calmLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How to Earn Coins', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
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
    );
  }

  Widget _earnRow(String amount, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(amount, style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: AppColors.mutedText)),
        ],
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RewardStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
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
  _ShopItem(id: 1, name: 'Starry Hat', type: 'accessory', price: 50, emoji: '🎩'),
  _ShopItem(id: 2, name: 'Rainbow Scarf', type: 'accessory', price: 75, emoji: '🧣'),
  _ShopItem(id: 3, name: 'Sunset Background', type: 'background', price: 100, emoji: '🌅'),
  _ShopItem(id: 4, name: 'Galaxy Background', type: 'background', price: 150, emoji: '🌌'),
  _ShopItem(id: 5, name: 'Golden Crown', type: 'cosmetic', price: 200, emoji: '👑'),
  _ShopItem(id: 6, name: 'Sparkle Effect', type: 'cosmetic', price: 125, emoji: '✨'),
];
