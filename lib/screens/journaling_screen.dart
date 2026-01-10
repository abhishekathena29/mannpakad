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

    if (isComplete) {
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
                    Icons.book,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Journal Complete',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Weekly reflection builds lasting insights.',
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

    final step = steps[currentStep];
    final controller = _currentController();

    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (currentStep == 0) {
              appState.setCurrentView(AppView.home);
            } else {
              setState(() => currentStep -= 1);
            }
          },
        ),
        title: Text(
          'Screen ${currentStep + 1} of ${steps.length}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / steps.length,
                color: AppColors.primary,
                backgroundColor: Colors.white.withAlpha(30),
                minHeight: 6,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consider these questions:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...step.prompts.map((prompt) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(150),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    prompt,
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(200),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Your reflection:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 8,
                    style: const TextStyle(color: Colors.white, height: 1.5),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withAlpha(20),
                      hintText: 'Type here...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.calm.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.calm.withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.psychology,
                          color: AppColors.calmLight,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: const Text(
                            'Focus on patterns, learning, and growth.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
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
                            predictionsVsOutcomes: predictionsController.text
                                .trim(),
                            responseReflections: responsesController.text
                                .trim(),
                            commitmentNextSteps: commitmentController.text
                                .trim(),
                          );
                          appState.earnReward(
                            ExerciseType.journaling,
                            'Completed weekly journal',
                          );
                          setState(() => isComplete = true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  currentStep == steps.length - 1
                      ? 'Complete Journal'
                      : 'Next Section',
                ),
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
