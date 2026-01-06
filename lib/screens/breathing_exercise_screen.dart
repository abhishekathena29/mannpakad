import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/reflection_form.dart';

enum BreathingPhase { intro, breathing, sensory, reflection, complete }

enum BoxPhase { inhale, hold1, exhale, hold2 }

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
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
          boxPhase = BoxPhase.values[(boxPhase.index + 1) % BoxPhase.values.length];
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

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (phase == BreathingPhase.reflection) {
      return ReflectionForm(
        sessionId: sessionId,
        exerciseType: ExerciseType.breathing,
        onComplete: () {
          appState.earnReward(ExerciseType.breathing, 'Completed breathing exercise');
          setState(() => phase = BreathingPhase.complete);
        },
        onBack: () => setState(() => phase = BreathingPhase.sensory),
      );
    }

    if (phase == BreathingPhase.complete) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.calm, size: 80),
                const SizedBox(height: 16),
                const Text('Breathing Complete', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('You stayed present with discomfort.', style: TextStyle(color: AppColors.mutedText)),
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

    if (phase == BreathingPhase.sensory) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => phase = BreathingPhase.breathing),
          ),
          title: const Text('Sensory Observations'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.calmLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('You do not need to relax for this to work. Just notice.'),
              ),
              const SizedBox(height: 16),
              _textField('Where do you feel anxiety most strongly?', anxietyLocationController),
              _textField('Is it tight, warm, buzzing, heavy?', anxietySensationController),
              _textField('Notice the edges - where does it begin/end?', anxietyEdgesController),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: anxietyLocationController.text.trim().isEmpty
                      ? null
                      : () {
                          sessionId = DateTime.now().millisecondsSinceEpoch.toString();
                          appState.addBreathingSession(
                            hierarchyLevel: hierarchyLevel,
                            duration: totalTime.round(),
                            anxietyLocation: anxietyLocationController.text.trim(),
                            anxietySensation: anxietySensationController.text.trim(),
                            anxietyEdges: anxietyEdgesController.text.trim(),
                            persisted: true,
                          );
                          setState(() => phase = BreathingPhase.reflection);
                        },
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
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => appState.setCurrentView(AppView.home),
          ),
          title: Text('${formatTime(totalTime)} / ${formatTime(hierarchyDurations[hierarchyLevel - 1])}'),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: progress, color: AppColors.calm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.calm,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        instruction(),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Stay present with whatever arises.', style: TextStyle(color: AppColors.mutedText)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => isRunning = !isRunning),
                        child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          totalTime = 0;
                          boxProgress = 0;
                          boxPhase = BoxPhase.inhale;
                        }),
                        child: const Icon(Icons.refresh),
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Breathing Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.calmLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This is not a relaxation tool. It trains you to remain present with anxiety sensations without changing them.',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select difficulty level:'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final level = index + 1;
                final active = level == hierarchyLevel;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () => setState(() => hierarchyLevel = level),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: active ? AppColors.calm : null,
                        foregroundColor: active ? Colors.white : null,
                      ),
                      child: Text(level.toString()),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Level $hierarchyLevel: ${(hierarchyDurations[hierarchyLevel - 1] / 60).round()} minute(s)',
                style: TextStyle(color: AppColors.mutedText),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ethical instruction: You do not need to relax for this to work. Stay present even if nothing improves.',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: startBreathing,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Box Breathing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.muted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
