import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class ReflectionForm extends StatefulWidget {
  final String sessionId;
  final ExerciseType exerciseType;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const ReflectionForm({
    super.key,
    required this.sessionId,
    required this.exerciseType,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<ReflectionForm> createState() => _ReflectionFormState();
}

class _ReflectionFormState extends State<ReflectionForm> {
  int currentStep = 0;

  final stepByStepController = TextEditingController();
  final hardestPartController = TextEditingController();
  final wantedToStopController = TextEditingController();

  final urgesController = TextEditingController();
  final discomfortActionsController = TextEditingController();
  final intentionallyAvoidedController = TextEditingController();

  final predictionController = TextEditingController();
  final worstOutcomeController = TextEditingController();
  final actualOutcomeController = TextEditingController();
  final predictionNotTrueController = TextEditingController();
  final surprisingController = TextEditingController();

  AnxietyChange anxietyChange = AnxietyChange.fluctuated;
  final abilityToStayController = TextEditingController();

  final discomfortHandlingController = TextEditingController();
  final urgesLearningController = TextEditingController();
  final futureMessageController = TextEditingController();

  @override
  void dispose() {
    stepByStepController.dispose();
    hardestPartController.dispose();
    wantedToStopController.dispose();
    urgesController.dispose();
    discomfortActionsController.dispose();
    intentionallyAvoidedController.dispose();
    predictionController.dispose();
    worstOutcomeController.dispose();
    actualOutcomeController.dispose();
    predictionNotTrueController.dispose();
    surprisingController.dispose();
    abilityToStayController.dispose();
    discomfortHandlingController.dispose();
    urgesLearningController.dispose();
    futureMessageController.dispose();
    super.dispose();
  }

  void handleNext() {
    if (currentStep < 4) {
      setState(() => currentStep += 1);
      return;
    }
    final appState = AppStateScope.of(context);
    appState.addReflectionLog(
      sessionId: widget.sessionId,
      exerciseType: widget.exerciseType,
      stepByStepDescription: stepByStepController.text,
      hardestPart: hardestPartController.text,
      wantedToStop: wantedToStopController.text,
      urgesNoticed: urgesController.text,
      discomfortReducingActions: discomfortActionsController.text,
      intentionallyAvoided: intentionallyAvoidedController.text,
      prediction: predictionController.text,
      worstOutcomeWorried: worstOutcomeController.text,
      actualOutcome: actualOutcomeController.text,
      predictionNotTrue: predictionNotTrueController.text,
      surprising: surprisingController.text,
      anxietyChange: anxietyChange,
      abilityToStay: abilityToStayController.text,
      discomfortHandling: discomfortHandlingController.text,
      urgesLearning: urgesLearningController.text,
      futureMessage: futureMessageController.text,
    );
    appState.earnReward(widget.exerciseType, 'Completed reflection');
    widget.onComplete();
  }

  void handleBack() {
    if (currentStep == 0) {
      widget.onBack();
    } else {
      setState(() => currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepInfo('Task Engagement', Icons.check_circle),
      _StepInfo('Response Prevention', Icons.shield),
      _StepInfo('Expectancy', Icons.track_changes),
      _StepInfo('Habituation', Icons.trending_up),
      _StepInfo('Consolidate', Icons.psychology),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: handleBack, icon: const Icon(Icons.arrow_back)),
        title: Text('Reflection ${currentStep + 1} of ${steps.length}'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / steps.length,
            backgroundColor: AppColors.muted,
            color: AppColors.primary,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(steps[currentStep]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleNext,
                child: Text(currentStep == steps.length - 1
                    ? 'Complete Reflection'
                    : 'Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(_StepInfo step) {
    switch (currentStep) {
      case 0:
        return _buildEngagement();
      case 1:
        return _buildPrevention();
      case 2:
        return _buildExpectancy();
      case 3:
        return _buildHabituation();
      case 4:
        return _buildConsolidate();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEngagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('Describe what you did step by step', stepByStepController),
        _field('What part was hardest to stay with?', hardestPartController),
        _field('At what point did you most want to stop?', wantedToStopController),
      ],
    );
  }

  Widget _buildPrevention() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('What urges did you notice?', urgesController),
        _field('If you reduced discomfort, how?', discomfortActionsController),
        _field('What did you choose not to do?', intentionallyAvoidedController),
      ],
    );
  }

  Widget _buildExpectancy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('What did you predict would happen?', predictionController),
        _field('What outcome worried you most?', worstOutcomeController),
        _field('What actually happened?', actualOutcomeController),
        _field('Which part did not come true?', predictionNotTrueController),
        _field('Was anything surprising?', surprisingController),
      ],
    );
  }

  Widget _buildHabituation() {
    final options = {
      AnxietyChange.stayedSame: 'Stayed the same',
      AnxietyChange.increased: 'Increased',
      AnxietyChange.decreased: 'Decreased',
      AnxietyChange.fluctuated: 'Fluctuated',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How did your anxiety change?',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...options.entries.map((entry) {
          return RadioListTile<AnxietyChange>(
            value: entry.key,
            groupValue: anxietyChange,
            onChanged: (value) => setState(() => anxietyChange = value!),
            title: Text(entry.value),
          );
        }),
        _field('What did you notice about staying with discomfort?', abilityToStayController),
      ],
    );
  }

  Widget _buildConsolidate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('What does this suggest about your ability to handle discomfort?',
            discomfortHandlingController),
        _field('What did you learn about urges?', urgesLearningController),
        _field('What would you tell your future self?', futureMessageController),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write here...',
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

class _StepInfo {
  final String label;
  final IconData icon;

  const _StepInfo(this.label, this.icon);
}
