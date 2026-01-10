import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/reflection_form.dart';

enum BreathingPhase {
  intro,
  triggerPrompt,
  breathing,
  sensory,
  reflection,
  complete,
}

enum BoxPhase { inhale, hold1, exhale, hold2 }

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  BreathingPhase phase = BreathingPhase.intro;
  int hierarchyLevel = 1;
  bool isRunning = false;
  BoxPhase boxPhase = BoxPhase.inhale;
  double boxProgress = 0;
  double totalTime = 0;
  Timer? timer;
  String sessionId = '';

  final anxietyLocationController = TextEditingController();
  final anxietySensationController = TextEditingController();
  final anxietyEdgesController = TextEditingController();

  static const breathDuration = 4.0;
  static const hierarchyDurations = [60.0, 120.0, 180.0, 240.0, 300.0];

  final _triggers = [
    'Imagine touching a public doorknob.',
    'Think about a time you forgot to check the stove.',
    'Visualize shaking hands with a stranger.',
    'Recall a moment of uncertainty about a decision.',
    'Imagine leaving the house without your phone.',
    'Think about an unwashed surface in your home.',
    'Visualize stepping on a crack in the pavement.',
  ];
  String currentTrigger = '';

  @override
  void initState() {
    super.initState();
    currentTrigger = (_triggers..shuffle()).first;
  }

  @override
  void dispose() {
    timer?.cancel();
    anxietyLocationController.dispose();
    anxietySensationController.dispose();
    anxietyEdgesController.dispose();
    super.dispose();
  }

  void startBreathing() {
    setState(() {
      phase = BreathingPhase.breathing;
      isRunning = true;
      totalTime = 0;
      boxProgress = 0;
      boxPhase = BoxPhase.inhale;
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!isRunning || phase != BreathingPhase.breathing) return;
      setState(() {
        boxProgress += 0.1;
        if (boxProgress >= breathDuration) {
          boxProgress = 0;
          boxPhase =
              BoxPhase.values[(boxPhase.index + 1) % BoxPhase.values.length];
        }
        totalTime += 0.1;
        if (totalTime >= hierarchyDurations[hierarchyLevel - 1]) {
          isRunning = false;
          phase = BreathingPhase.sensory;
        }
      });
    });
  }

  String instruction() {
    switch (boxPhase) {
      case BoxPhase.inhale:
        return 'Breathe In';
      case BoxPhase.hold1:
        return 'Hold';
      case BoxPhase.exhale:
        return 'Breathe Out';
      case BoxPhase.hold2:
        return 'Hold';
    }
  }

  String formatTime(double seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).floor();
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

    if (phase == BreathingPhase.reflection) {
      return ReflectionForm(
        sessionId: sessionId,
        exerciseType: ExerciseType.breathing,
        onComplete: () {
          appState.earnReward(
            ExerciseType.breathing,
            'Completed breathing exercise',
          );
          setState(() => phase = BreathingPhase.complete);
        },
        onBack: () => setState(() => phase = BreathingPhase.sensory),
      );
    }

    if (phase == BreathingPhase.triggerPrompt) {
      return buildGradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => setState(() => phase = BreathingPhase.intro),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error.withAlpha(50)),
                ),
                child: const Icon(
                  Icons.psychology_alt,
                  color: AppColors.error,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Bring this to mind:',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                currentTrigger,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        currentTrigger = (_triggers..shuffle()).first;
                      }),
                      child: const Text(
                        'New Prompt',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Hold this thought. Notice the anxiety. Do not push it away.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: startBreathing,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.error.withAlpha(200),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Breathe Through It'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (phase == BreathingPhase.complete) {
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
                    color: AppColors.calm.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.calm.withAlpha(50)),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.calm,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Breathing Complete',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You stayed present with discomfort.',
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

    if (phase == BreathingPhase.sensory) {
      return buildGradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => setState(() => phase = BreathingPhase.breathing),
          ),
          title: const Text(
            'Sensory Observations',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.calm.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.calm.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: AppColors.calmLight),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        'You do not need to relax for this to work. Just notice.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _textField(
                'Where do you feel anxiety most strongly?',
                anxietyLocationController,
              ),
              _textField(
                'Is it tight, warm, buzzing, heavy?',
                anxietySensationController,
              ),
              _textField(
                'Notice the edges - where does it begin/end?',
                anxietyEdgesController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: anxietyLocationController.text.trim().isEmpty
                      ? null
                      : () {
                          sessionId = DateTime.now().millisecondsSinceEpoch
                              .toString();
                          appState.addBreathingSession(
                            hierarchyLevel: hierarchyLevel,
                            duration: totalTime.round(),
                            anxietyLocation: anxietyLocationController.text
                                .trim(),
                            anxietySensation: anxietySensationController.text
                                .trim(),
                            anxietyEdges: anxietyEdgesController.text.trim(),
                            persisted: true,
                          );
                          setState(() => phase = BreathingPhase.reflection);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue to Reflection'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (phase == BreathingPhase.breathing) {
      final progress = totalTime / hierarchyDurations[hierarchyLevel - 1];
      return buildGradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => appState.setCurrentView(AppView.home),
          ),
          title: Text(
            '${formatTime(totalTime)} / ${formatTime(hierarchyDurations[hierarchyLevel - 1])}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  color: AppColors.calm,
                  backgroundColor: Colors.white.withAlpha(30),
                  minHeight: 8,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.calm.withAlpha(
                        boxPhase == BoxPhase.inhale ||
                                boxPhase == BoxPhase.hold1
                            ? 100
                            : 30,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.calm.withAlpha(150),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.calm.withAlpha(50),
                          blurRadius: 40,
                          spreadRadius: boxPhase == BoxPhase.inhale ? 20 : 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        instruction(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Stay present with whatever arises.',
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setState(() => isRunning = !isRunning),
                        icon: Icon(
                          isRunning
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () => setState(() {
                          totalTime = 0;
                          boxProgress = 0;
                          boxPhase = BoxPhase.inhale;
                        }),
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text(
          'Breathing Exercise',
          style: TextStyle(color: Colors.white),
        ),
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
                color: AppColors.calm.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.calm.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.air, color: AppColors.calmLight, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: const Text(
                      'This is not a relaxation tool. It trains you to remain present with anxiety sensations without changing them.',
                      style: TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select difficulty level:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (index) {
                final level = index + 1;
                final active = level == hierarchyLevel;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => hierarchyLevel = level),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.calm
                              : Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active
                                ? AppColors.calm
                                : Colors.white.withAlpha(20),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            level.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Level $hierarchyLevel: ${(hierarchyDurations[hierarchyLevel - 1] / 60).round()} minute(s)',
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(10)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Ethical instruction: You do not need to relax for this to work. Stay present even if nothing improves.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    setState(() => phase = BreathingPhase.triggerPrompt),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Box Breathing'),
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

  Widget _textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withAlpha(20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
