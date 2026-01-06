import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class JournalingScreen extends StatefulWidget {
  const JournalingScreen({super.key});

  @override
  State<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends State<JournalingScreen> {
  int currentStep = 0;
  bool isComplete = false;

  final patternsController = TextEditingController();
  final anxietyController = TextEditingController();
  final predictionsController = TextEditingController();
  final responsesController = TextEditingController();
  final commitmentController = TextEditingController();

  final steps = const [
    _JournalStep('OCD Patterns', 'Awareness of your OCD patterns this week', [
      'What OCD themes showed up most this week?',
      'Did you notice any new triggers?',
      'What patterns do you see between obsessions and compulsions?',
    ]),
    _JournalStep('Anxiety & Discomfort', 'Observing your experiences', [
      'When was anxiety highest this week?',
      'What physical sensations did you notice?',
      'How long did discomfort typically last?',
    ]),
    _JournalStep('Predictions vs Outcomes', 'Tracking expectancy violations', [
      'What predictions did you make before exposures?',
      'What actually happened?',
      'Which predictions were proven wrong?',
    ]),
    _JournalStep('Your Responses', 'Reflecting on how you responded', [
      'When did you successfully resist compulsions?',
      'When did you give in? What made it harder?',
      'What helped you stay with discomfort?',
    ]),
    _JournalStep('Next Steps', 'Commitment for the coming week', [
      'What is one exposure you will try next week?',
      'What value will you connect it to?',
      'How will you remind yourself to resist compulsions?',
    ]),
  ];

  @override
  void dispose() {
    patternsController.dispose();
    anxietyController.dispose();
    predictionsController.dispose();
    responsesController.dispose();
    commitmentController.dispose();
    super.dispose();
  }

  TextEditingController _currentController() {
    switch (currentStep) {
      case 0:
        return patternsController;
      case 1:
        return anxietyController;
      case 2:
        return predictionsController;
      case 3:
        return responsesController;
      case 4:
      default:
        return commitmentController;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (isComplete) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.book, color: AppColors.primary, size: 80),
                const SizedBox(height: 16),
                const Text('Journal Complete', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Weekly reflection builds lasting insights.',
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

    final step = steps[currentStep];
    final controller = _currentController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentStep == 0) {
              appState.setCurrentView(AppView.home);
            } else {
              setState(() => currentStep -= 1);
            }
          },
        ),
        title: Text('Screen ${currentStep + 1} of ${steps.length}'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / steps.length,
            color: AppColors.primary,
            backgroundColor: AppColors.muted,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(step.description, style: TextStyle(color: AppColors.mutedText)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Consider these questions:',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...step.prompts.map((prompt) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $prompt', style: TextStyle(color: AppColors.mutedText)),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Your reflection:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 6,
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.calmLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Focus on patterns, learning, and growth.'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.text.trim().isEmpty
                    ? null
                    : () {
                        if (currentStep < steps.length - 1) {
                          setState(() => currentStep += 1);
                        } else {
                          appState.addWeeklyJournal(
                            patternsAwareness: patternsController.text.trim(),
                            anxietyObservations: anxietyController.text.trim(),
                            predictionsVsOutcomes: predictionsController.text.trim(),
                            responseReflections: responsesController.text.trim(),
                            commitmentNextSteps: commitmentController.text.trim(),
                          );
                          appState.earnReward(ExerciseType.journaling, 'Completed weekly journal');
                          setState(() => isComplete = true);
                        }
                      },
                child: Text(currentStep == steps.length - 1 ? 'Complete Journal' : 'Next Section'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalStep {
  final String title;
  final String description;
  final List<String> prompts;

  const _JournalStep(this.title, this.description, this.prompts);
}
