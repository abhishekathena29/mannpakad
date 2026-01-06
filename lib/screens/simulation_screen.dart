import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/reflection_form.dart';

enum SimulationPhase { select, scenario, simulation, reflection, complete }

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  SimulationPhase phase = SimulationPhase.select;
  _Scenario? selectedScenario;
  int selectedLevel = 1;
  bool isRunning = false;
  int elapsedTime = 0;
  final List<SimulationChoice> choices = [];
  Timer? timer;
  String sessionId = '';

  final scenarios = const [
    _Scenario(
      id: 'contamination',
      title: 'Contamination Exposure',
      description: 'Your avatar encounters potentially contaminated surfaces',
      levels: [
        _ScenarioLevel(1, 20, 'Touch a slightly dusty surface'),
        _ScenarioLevel(2, 40, 'Touch multiple public door handles'),
        _ScenarioLevel(3, 60, 'Touch a bathroom counter'),
        _ScenarioLevel(4, 80, 'Touch a public trash can lid'),
        _ScenarioLevel(5, 100, 'Extended contact with items, no washing'),
      ],
    ),
    _Scenario(
      id: 'checking',
      title: 'Checking Resistance',
      description: 'Your avatar practices leaving without checking',
      levels: [
        _ScenarioLevel(1, 20, 'Leave a room without looking back once'),
        _ScenarioLevel(2, 40, 'Lock door once and walk away'),
        _ScenarioLevel(3, 60, 'Leave appliances on trust mode'),
        _ScenarioLevel(4, 80, 'Leave home without final check'),
        _ScenarioLevel(5, 100, 'Extended absence without any checking'),
      ],
    ),
    _Scenario(
      id: 'symmetry',
      title: 'Symmetry Challenge',
      description: 'Your avatar leaves things deliberately misaligned',
      levels: [
        _ScenarioLevel(1, 20, 'Leave one item slightly crooked'),
        _ScenarioLevel(2, 40, 'Misalign multiple objects'),
        _ScenarioLevel(3, 60, 'Create obvious asymmetry'),
        _ScenarioLevel(4, 80, 'Leave a chaotic arrangement'),
        _ScenarioLevel(5, 100, 'Maintain disorder for extended time'),
      ],
    ),
  ];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startSimulation() {
    setState(() {
      phase = SimulationPhase.simulation;
      isRunning = true;
      elapsedTime = 0;
      choices.clear();
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isRunning || phase != SimulationPhase.simulation) return;
      setState(() {
        elapsedTime += 1;
        if (elapsedTime >= targetDuration) {
          isRunning = false;
          _completeSimulation();
        }
      });
    });
  }

  int get targetDuration => 60 + (selectedLevel - 1) * 30;

  void _completeSimulation() {
    final appState = AppStateScope.of(context);
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final hierarchyItem = appState.fearHierarchy
        .firstWhere((item) => item.suds == selectedScenario?.levels[selectedLevel - 1].suds,
            orElse: () => appState.fearHierarchy.isNotEmpty
                ? appState.fearHierarchy.first
                : FearHierarchyItem(
                    id: '',
                    scenario: '',
                    suds: 0,
                    exposureType: ExposureType.simulation,
                    exerciseType: ExerciseType.simulation,
                    hierarchyLevel: 1,
                    tags: const [],
                    completed: false,
                    completedCount: 0,
                    createdAt: DateTime.now(),
                  ));
    appState.addSimulationSession(
      hierarchyItemId: hierarchyItem.id,
      hierarchyLevel: selectedLevel,
      choices: [...choices],
      duration: elapsedTime,
    );
    setState(() => phase = SimulationPhase.reflection);
  }

  void addChoice(String action) {
    setState(() {
      choices.add(SimulationChoice(timestamp: DateTime.now(), action: action));
    });
  }

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString()}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (phase == SimulationPhase.reflection) {
      return ReflectionForm(
        sessionId: sessionId,
        exerciseType: ExerciseType.simulation,
        onComplete: () {
          appState.earnReward(ExerciseType.simulation, 'Completed simulation');
          setState(() => phase = SimulationPhase.complete);
        },
        onBack: () => setState(() => phase = SimulationPhase.simulation),
      );
    }

    if (phase == SimulationPhase.complete) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 80),
                const SizedBox(height: 16),
                const Text('Simulation Complete', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Imaginal exposure prepares you for real-world practice.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedText)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => appState.setCurrentView(AppView.home),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (phase == SimulationPhase.simulation && selectedScenario != null) {
      final progress = elapsedTime / targetDuration;
      return Scaffold(
        appBar: AppBar(
          title: Text('Level $selectedLevel'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(child: Text(formatTime(elapsedTime))),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: progress, color: AppColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(selectedScenario!.icon, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(selectedScenario!.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(selectedScenario!.levels[selectedLevel - 1].task,
                                textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedText)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _choiceButton('avoid', Icons.warning, Colors.red, () => addChoice('avoid')),
                        _choiceButton('engage', Icons.pan_tool, AppColors.calm, () => addChoice('touch')),
                        _choiceButton('delay', Icons.timer, AppColors.mutedText, () => addChoice('delay-compulsion')),
                        _choiceButton('resist', Icons.shield, AppColors.primary, () => addChoice('resist')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (choices.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children: choices.take(5).map((choice) {
                          return Chip(label: Text(choice.action));
                        }).toList(),
                      ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        isRunning = false;
                        _completeSimulation();
                      },
                      child: const Text('End Simulation Early'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (phase == SimulationPhase.scenario && selectedScenario != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => phase = SimulationPhase.select),
          ),
          title: Text(selectedScenario!.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(selectedScenario!.description),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedScenario!.levels.length,
                  itemBuilder: (context, index) {
                    final level = selectedScenario!.levels[index];
                    return Card(
                      child: ListTile(
                        title: Text('Level ${level.level}'),
                        subtitle: Text(level.task),
                        trailing: Text('SUDs ${level.suds}'),
                        selected: selectedLevel == level.level,
                        onTap: () => setState(() => selectedLevel = level.level),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: startSimulation,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Simulation'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Simulations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Avatar-based simulations for imaginal exposure. Practice facing fears before real-world exposures.',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: scenarios.length,
                itemBuilder: (context, index) {
                  final scenario = scenarios[index];
                  return Card(
                    child: ListTile(
                      leading: Text(scenario.icon, style: const TextStyle(fontSize: 24)),
                      title: Text(scenario.title),
                      subtitle: Text(scenario.description),
                      onTap: () => setState(() {
                        selectedScenario = scenario;
                        phase = SimulationPhase.scenario;
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      style: ElevatedButton.styleFrom(backgroundColor: color),
      label: Text(label),
    );
  }
}

class _Scenario {
  final String id;
  final String title;
  final String description;
  final List<_ScenarioLevel> levels;

  const _Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.levels,
  });

  String get icon {
    switch (id) {
      case 'contamination':
        return '🧴';
      case 'checking':
        return '🔐';
      case 'symmetry':
        return '⚖️';
      default:
        return '🎮';
    }
  }
}

class _ScenarioLevel {
  final int level;
  final int suds;
  final String task;

  const _ScenarioLevel(this.level, this.suds, this.task);
}
