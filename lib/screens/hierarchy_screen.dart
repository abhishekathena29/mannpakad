import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/suds_slider.dart';

class HierarchyScreen extends StatefulWidget {
  const HierarchyScreen({super.key});

  @override
  State<HierarchyScreen> createState() => _HierarchyScreenState();
}

class _HierarchyScreenState extends State<HierarchyScreen> {
  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddExposureDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    // Sort descending: High SUDs at top, Low SUDs at bottom (Ladder climbing up)
    final sorted = [...appState.fearHierarchy]
      ..sort((a, b) => b.suds.compareTo(a.suds));

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
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Fear Ladder',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Climb your way to freedom',
                      style: TextStyle(
                        color: Colors.white.withAlpha(150),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (sorted.isEmpty)
                      _buildEmptyState(context)
                    else
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Central Pole
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          // Steps
                          Column(
                            children: [
                              ...sorted.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return _LadderItem(
                                  item: item,
                                  isLeft: index % 2 == 0,
                                  onToggle: () => appState
                                      .toggleFearItemCompletion(item.id),
                                );
                              }),
                              const SizedBox(height: 24),
                              // Base of the ladder
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(20),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.success.withAlpha(50),
                                  ),
                                ),
                                child: const Text(
                                  'START HERE',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 80), // Fab space
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Step'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.layers_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Build Your Ladder',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding feared situations ranked from least to most distressing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withAlpha(180), height: 1.4),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => _openAddDialog(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withAlpha(150)),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Add First Exposure'),
          ),
        ],
      ),
    );
  }
}

class _LadderItem extends StatelessWidget {
  final FearHierarchyItem item;
  final bool isLeft;
  final VoidCallback onToggle;

  const _LadderItem({
    required this.item,
    required this.isLeft,
    required this.onToggle,
  });

  Color _getSudsColor(int suds) {
    if (suds <= 30) return AppColors.success;
    if (suds <= 50) return AppColors.warning;
    if (suds <= 70) return AppColors.accent;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSudsColor(item.suds);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: isLeft
                  ? _buildCard(context, color)
                  : const SizedBox.shrink(),
            ),
            SizedBox(
              width: 40,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(100),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: !isLeft
                  ? _buildCard(context, color)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Color color) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.completed
              ? Colors.green.withAlpha(10)
              : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.completed
                ? Colors.green.withAlpha(50)
                : color.withAlpha(50),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SUDs ${item.suds}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (item.completed)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.scenario,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                decoration: item.completed ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddExposureDialog extends StatefulWidget {
  const _AddExposureDialog();

  @override
  State<_AddExposureDialog> createState() => _AddExposureDialogState();
}

class _AddExposureDialogState extends State<_AddExposureDialog> {
  final scenarioController = TextEditingController();
  int suds = 50;
  ExposureType exposureType = ExposureType.inVivo;

  @override
  void dispose() {
    scenarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return AlertDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      title: const Text(
        'Add Exposure Task',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Describe feared situation',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: scenarioController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., Touch a doorknob without washing hands',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SUDSSlider(
              value: suds,
              onChanged: (value) => setState(() => suds = value),
              label: 'Expected distress level',
            ),
            const SizedBox(height: 20),
            const Text(
              'Exposure Type',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExposureType.values.map((type) {
                final selected = exposureType == type;
                return FilterChip(
                  label: Text(_exposureLabel(type)),
                  selected: selected,
                  onSelected: (_) => setState(() => exposureType = type),
                  selectedColor: AppColors.primary.withAlpha(80),
                  backgroundColor: Colors.white.withAlpha(20),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (scenarioController.text.trim().isEmpty) return;
            final scenario = scenarioController.text.trim();
            final level = _hierarchyLevel(suds);
            appState.addFearItem(
              scenario: scenario,
              suds: suds,
              exposureType: exposureType,
              exerciseType: exposureType == ExposureType.simulation
                  ? ExerciseType.simulation
                  : ExerciseType.inVivo,
              hierarchyLevel: level,
            );
            Navigator.pop(context);
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }

  String _exposureLabel(ExposureType type) {
    switch (type) {
      case ExposureType.imaginal:
        return 'Imaginal';
      case ExposureType.inVivo:
        return 'In Vivo';
      case ExposureType.simulation:
        return 'Simulation';
    }
  }

  int _hierarchyLevel(int suds) {
    if (suds <= 20) return 1;
    if (suds <= 40) return 2;
    if (suds <= 60) return 3;
    if (suds <= 80) return 4;
    return 5;
  }
}
