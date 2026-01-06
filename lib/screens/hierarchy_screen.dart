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
    final appState = AppStateScope.of(context);
    final scenarioController = TextEditingController();
    int suds = 50;
    ExposureType exposureType = ExposureType.inVivo;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Exposure Task'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Describe the feared situation'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: scenarioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g., Touch a doorknob without washing hands',
                        filled: true,
                        fillColor: AppColors.muted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SUDSSlider(
                      value: suds,
                      onChanged: (value) => setDialogState(() => suds = value),
                      label: 'Expected distress level',
                    ),
                    const SizedBox(height: 16),
                    const Text('Exposure Type'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ExposureType.values.map((type) {
                        final selected = exposureType == type;
                        return ChoiceChip(
                          label: Text(_exposureLabel(type)),
                          selected: selected,
                          onSelected: (_) => setDialogState(() => exposureType = type),
                          selectedColor: AppColors.primaryLight,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: scenarioController.text.trim().isEmpty
                  ? null
                  : () {
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
                      Navigator.pop(dialogContext);
                    },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((_) => scenarioController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final sorted = [...appState.fearHierarchy]
      ..sort((a, b) => a.suds.compareTo(b.suds));

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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fear Ladder',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(
                              '${appState.fearHierarchy.length} exposure${appState.fearHierarchy.length == 1 ? '' : 's'} ready',
                              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openAddDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (sorted.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_upward, size: 40, color: AppColors.primary),
                          const SizedBox(height: 12),
                          const Text('Build Your Ladder',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding feared situations ranked from least to most distressing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.mutedText),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _openAddDialog(context),
                            child: const Text('Add First Exposure'),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: sorted.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    item.suds.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.scenario,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        decoration:
                                            item.completed ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Level ${item.hierarchyLevel} · ${_exposureLabel(item.exposureType)} · ${item.completedCount}x',
                                      style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  item.completed ? Icons.close : Icons.check,
                                  color: item.completed ? AppColors.mutedText : AppColors.primary,
                                ),
                                onPressed: () => appState.toggleFearItemCompletion(item.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.accent),
                                onPressed: () => appState.deleteFearItem(item.id),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  if (sorted.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.calmLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.calm.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Tip: Start with exposures in the 30-40 SUDs range.',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
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
