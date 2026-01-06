import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/reflection_form.dart';

enum DefusionPhase { input, observe, defuse, mcq, learning, reflection, complete }

class CognitiveDefusionScreen extends StatefulWidget {
  const CognitiveDefusionScreen({super.key});

  @override
  State<CognitiveDefusionScreen> createState() => _CognitiveDefusionScreenState();
}

class _CognitiveDefusionScreenState extends State<CognitiveDefusionScreen> {
  DefusionPhase phase = DefusionPhase.input;
  final thoughtController = TextEditingController();
  int defuseCount = 0;
  String sessionId = '';

  String mcqAnswer = '';
  bool? readExactly;
  bool? didNotNeutralize;
  final coexistingLearningController = TextEditingController();
  final futureResponseController = TextEditingController();

  @override
  void dispose() {
    thoughtController.dispose();
    coexistingLearningController.dispose();
    futureResponseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (phase == DefusionPhase.reflection) {
      return ReflectionForm(
        sessionId: sessionId,
        exerciseType: ExerciseType.cognitiveDefusion,
        onComplete: () {
          appState.earnReward(ExerciseType.cognitiveDefusion, 'Completed cognitive defusion');
          setState(() => phase = DefusionPhase.complete);
        },
        onBack: () => setState(() => phase = DefusionPhase.learning),
      );
    }

    if (phase == DefusionPhase.complete) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.psychology, color: AppColors.clarity, size: 80),
                const SizedBox(height: 16),
                const Text('Defusion Complete', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Thoughts are just mental events, not commands.',
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

    switch (phase) {
      case DefusionPhase.learning:
        return _learningStep(appState);
      case DefusionPhase.mcq:
        return _mcqStep();
      case DefusionPhase.observe:
      case DefusionPhase.defuse:
        return _observeStep();
      case DefusionPhase.input:
      default:
        return _inputStep(appState);
    }
  }

  Widget _inputStep(AppState appState) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Cognitive Defusion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.clarityLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Goal: view thoughts as mental events, not commands. We are not challenging or replacing thoughts.',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Enter an intrusive thought you are experiencing:'),
            const SizedBox(height: 8),
            TextField(
              controller: thoughtController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'I keep thinking that...',
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
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'We will not neutralize, challenge, or replace the thought. We only notice it.',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: thoughtController.text.trim().isEmpty
                    ? null
                    : () => setState(() => phase = DefusionPhase.observe),
                icon: const Icon(Icons.visibility),
                label: const Text('Begin Observation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _observeStep() {
    final thought = thoughtController.text.trim();
    final isObserve = phase == DefusionPhase.observe;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => phase = DefusionPhase.input),
        ),
        title: Text(isObserve ? 'Observe' : 'Defusion ${defuseCount + 1}/3'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text('"$thought"', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Text(
              isObserve
                  ? 'Just notice the thought without judging it.'
                  : 'Say aloud: "I am noticing the thought that ${thought.toLowerCase()}"',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isObserve) {
                    setState(() => phase = DefusionPhase.defuse);
                    return;
                  }
                  if (defuseCount < 2) {
                    setState(() => defuseCount += 1);
                  } else {
                    setState(() => phase = DefusionPhase.mcq);
                  }
                },
                child: Text(isObserve ? 'Begin Defusion Practice' : 'I Said It - Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mcqStep() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => phase = DefusionPhase.observe),
        ),
        title: const Text('Inhibitory Learning'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('While the thought was present, did anything bad happen?'),
            const SizedBox(height: 12),
            ...[
              'No change - nothing bad happened',
              'Anxiety stayed the same',
              'Anxiety increased',
              'I felt an urge to neutralize'
            ].map((option) {
              return RadioListTile<String>(
                value: option,
                groupValue: mcqAnswer,
                onChanged: (value) => setState(() => mcqAnswer = value ?? ''),
                title: Text(option),
              );
            }).toList(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mcqAnswer.isEmpty
                    ? null
                    : () => setState(() => phase = DefusionPhase.learning),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _learningStep(AppState appState) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => phase = DefusionPhase.mcq),
        ),
        title: const Text('Learning Extraction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Did you read the thought exactly as written?'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => readExactly = true),
                    child: const Text('Yes'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => readExactly = false),
                    child: const Text('No'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Did you avoid reassuring, analyzing, or replacing the thought?'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => didNotNeutralize = true),
                    child: const Text('Yes, I did not'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => didNotNeutralize = false),
                    child: const Text('I did some'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('What did you learn about coexisting with the thought?'),
            const SizedBox(height: 8),
            TextField(
              controller: coexistingLearningController,
              maxLines: 3,
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
            const Text('If the thought appears again today, what response can you repeat?'),
            const SizedBox(height: 8),
            TextField(
              controller: futureResponseController,
              maxLines: 3,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: readExactly == null ||
                        didNotNeutralize == null ||
                        coexistingLearningController.text.trim().isEmpty ||
                        futureResponseController.text.trim().isEmpty
                    ? null
                    : () {
                        sessionId = DateTime.now().millisecondsSinceEpoch.toString();
                        appState.addDefusionSession(
                          thought: thoughtController.text.trim(),
                          readExactly: readExactly == true,
                          didNotNeutralize: didNotNeutralize == true,
                          coexistingLearning: coexistingLearningController.text.trim(),
                          futureResponse: futureResponseController.text.trim(),
                        );
                        setState(() => phase = DefusionPhase.reflection);
                      },
                child: const Text('Continue to Reflection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
