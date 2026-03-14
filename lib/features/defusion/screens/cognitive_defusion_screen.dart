import 'package:flutter/material.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/shared/widgets/reflection_form.dart';

enum DefusionPhase {
  input,
  observe,
  defuse,
  mcq,
  learning,
  reflection,
  complete,
}

class CognitiveDefusionScreen extends StatefulWidget {
  const CognitiveDefusionScreen({super.key});

  @override
  State<CognitiveDefusionScreen> createState() =>
      _CognitiveDefusionScreenState();
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

    if (phase == DefusionPhase.reflection) {
      return ReflectionForm(
        sessionId: sessionId,
        exerciseType: ExerciseType.cognitiveDefusion,
        onComplete: () {
          appState.earnReward(
            ExerciseType.cognitiveDefusion,
            'Completed cognitive defusion',
          );
          setState(() => phase = DefusionPhase.complete);
        },
        onBack: () => setState(() => phase = DefusionPhase.learning),
      );
    }

    if (phase == DefusionPhase.complete) {
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
                    color: AppColors.clarity.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.clarity.withAlpha(50)),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: AppColors.clarity,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Defusion Complete',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thoughts are just mental events, not commands.',
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
    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text(
          'Cognitive Defusion',
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
                color: AppColors.clarity.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.clarity.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.clarityLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Goal: view thoughts as mental events, not commands. We are not challenging or replacing thoughts.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter an intrusive thought you are experiencing:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: thoughtController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'I keep thinking that...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'We will not neutralize, challenge, or replace the thought. We only notice it.',
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
                onPressed: thoughtController.text.trim().isEmpty
                    ? null
                    : () => setState(() => phase = DefusionPhase.observe),
                icon: const Icon(Icons.visibility),
                label: const Text('Begin Observation'),
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

  Widget _observeStep() {
    final thought = thoughtController.text.trim();
    final isObserve = phase == DefusionPhase.observe;
    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => phase = DefusionPhase.input),
        ),
        title: Text(
          isObserve ? 'Observe' : 'Defusion ${defuseCount + 1}/3',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(isObserve ? 20 : 10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withAlpha(isObserve ? 50 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Text(
                '"$thought"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isObserve
                  ? 'Just notice the thought without judging it.'
                  : 'Say aloud: "I am noticing the thought that ${thought.toLowerCase()}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isObserve ? 'Begin Defusion Practice' : 'I Said It - Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mcqStep() {
    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => phase = DefusionPhase.observe),
        ),
        title: const Text(
          'Inhibitory Learning',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'While the thought was present, did anything bad happen?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...[
              'No change - nothing bad happened',
              'Anxiety stayed the same',
              'Anxiety increased',
              'I felt an urge to neutralize',
            ].map((option) {
              final selected = mcqAnswer == option;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => mcqAnswer = option),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.clarity.withAlpha(50)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.clarity
                            : Colors.white.withAlpha(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected ? AppColors.clarity : Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mcqAnswer.isEmpty
                    ? null
                    : () => setState(() => phase = DefusionPhase.learning),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _learningStep(AppState appState) {
    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => phase = DefusionPhase.mcq),
        ),
        title: const Text(
          'Learning Extraction',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Did you read the thought exactly as written?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _optionButton(
                    'Yes',
                    readExactly == true,
                    () => setState(() => readExactly = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _optionButton(
                    'No',
                    readExactly == false,
                    () => setState(() => readExactly = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Did you avoid reassuring, analyzing, or replacing the thought?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _optionButton(
                    'Yes, I did not',
                    didNotNeutralize == true,
                    () => setState(() => didNotNeutralize = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _optionButton(
                    'I did some',
                    didNotNeutralize == false,
                    () => setState(() => didNotNeutralize = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'What did you learn about coexisting with the thought?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: coexistingLearningController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'If the thought appears again today, what response can you repeat?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: futureResponseController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    readExactly == null ||
                        didNotNeutralize == null ||
                        coexistingLearningController.text.trim().isEmpty ||
                        futureResponseController.text.trim().isEmpty
                    ? null
                    : () {
                        sessionId = DateTime.now().millisecondsSinceEpoch
                            .toString();
                        appState.addDefusionSession(
                          thought: thoughtController.text.trim(),
                          readExactly: readExactly == true,
                          didNotNeutralize: didNotNeutralize == true,
                          coexistingLearning: coexistingLearningController.text
                              .trim(),
                          futureResponse: futureResponseController.text.trim(),
                        );
                        setState(() => phase = DefusionPhase.reflection);
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

  Widget _optionButton(String label, bool isSelected, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.clarity.withAlpha(50)
            : Colors.transparent,
        side: BorderSide(
          color: isSelected ? AppColors.clarity : Colors.white.withAlpha(50),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      ),
    );
  }
}
