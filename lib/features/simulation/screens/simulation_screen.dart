import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/shared/widgets/reflection_form.dart';

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
    final hierarchyItem = appState.fearHierarchy.firstWhere(
      (item) => item.suds == selectedScenario?.levels[selectedLevel - 1].suds,
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
            ),
    );
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

  Widget buildGradientScaffold({
    required Widget body,
    PreferredSizeWidget? appBar,
  }) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientDark,
          ),
        ),
        child: SafeArea(child: body),
      ),
    );
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
      return buildGradientScaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Simulation Complete',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Imaginal exposure prepares you for real-world practice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withAlpha(180)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => appState.setCurrentView(AppView.home),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (phase == SimulationPhase.simulation && selectedScenario != null) {
      final progress = elapsedTime / targetDuration;
      return buildGradientScaffold(
        appBar: AppBar(
          title: Text(
            'Level $selectedLevel',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  formatTime(elapsedTime),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  color: AppColors.primary,
                  backgroundColor: Colors.white.withAlpha(30),
                  minHeight: 8,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withAlpha(20)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            selectedScenario!.icon,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedScenario!.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedScenario!.levels[selectedLevel - 1].task,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _choiceButton(
                          'avoid',
                          Icons.warning_amber_rounded,
                          Colors.red.withAlpha(200),
                          () => addChoice('avoid'),
                        ),
                        _choiceButton(
                          'engage',
                          Icons.pan_tool_rounded,
                          AppColors.calm,
                          () => addChoice('touch'),
                        ),
                        _choiceButton(
                          'delay',
                          Icons.timer_outlined,
                          Colors.orange.withAlpha(200),
                          () => addChoice('delay-compulsion'),
                        ),
                        _choiceButton(
                          'resist',
                          Icons.shield_outlined,
                          AppColors.primary,
                          () => addChoice('resist'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (choices.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: choices.take(5).map((choice) {
                          return Chip(
                            label: Text(
                              choice.action,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.white.withAlpha(15),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        isRunning = false;
                        _completeSimulation();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withAlpha(50)),
                      ),
                      child: const Text(
                        'End Simulation Early',
                        style: TextStyle(color: Colors.white),
                      ),
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
      return buildGradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => setState(() => phase = SimulationPhase.select),
          ),
          title: Text(
            selectedScenario!.title,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accentLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedScenario!.description,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedScenario!.levels.length,
                  itemBuilder: (context, index) {
                    final level = selectedScenario!.levels[index];
                    final active = selectedLevel == level.level;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () =>
                            setState(() => selectedLevel = level.level),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary.withAlpha(50)
                                : Colors.white.withAlpha(10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : Colors.white.withAlpha(10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${level.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.task,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'SUDs ${level.suds}',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(150),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (active)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Simulations', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.videogame_asset,
                    color: AppColors.primaryLight,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: const Text(
                      'Avatar-based simulations for imaginal exposure. Practice facing fears before real-world exposures.',
                      style: TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: scenarios.length,
                itemBuilder: (context, index) {
                  final scenario = scenarios[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => setState(() {
                        selectedScenario = scenario;
                        phase = SimulationPhase.scenario;
                      }),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(10)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              scenario.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scenario.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    scenario.description,
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(150),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                          ],
                        ),
                      ),
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

  Widget _choiceButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(80),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withAlpha(100)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
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
