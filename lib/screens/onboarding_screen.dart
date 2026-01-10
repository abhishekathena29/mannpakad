import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final nameController = TextEditingController();
  final List<OCDTheme> selectedOcd = [];
  final List<ADHDTrait> selectedAdhd = [];
  CoachingTone selectedTone = CoachingTone.gentle;

  final steps = const [
    'Your Name',
    'OCD Themes',
    'ADHD Traits',
    'Coaching Style',
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void toggleOcd(OCDTheme theme) {
    setState(() {
      if (selectedOcd.contains(theme)) {
        selectedOcd.remove(theme);
      } else {
        selectedOcd.add(theme);
      }
    });
  }

  void toggleAdhd(ADHDTrait trait) {
    setState(() {
      if (selectedAdhd.contains(trait)) {
        selectedAdhd.remove(trait);
      } else {
        selectedAdhd.add(trait);
      }
    });
  }

  void handleNext() {
    final appState = AppStateScope.of(context);
    if (step < steps.length - 1) {
      setState(() => step += 1);
    } else {
      appState.completeOnboarding(
        name: nameController.text.trim(),
        ocdThemes: selectedOcd,
        adhdTraits: selectedAdhd,
        coachingTone: selectedTone,
      );
    }
  }

  void handleBack() {
    final appState = AppStateScope.of(context);
    if (step > 0) {
      setState(() => step -= 1);
    } else {
      appState.setCurrentView(AppView.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = step != 0 || nameController.text.trim().isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: handleBack,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          '${step + 1} of ${steps.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientDark,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (step + 1) / steps.length,
                    backgroundColor: Colors.white.withAlpha(30),
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStep(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canProceed ? handleNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: canProceed
                          ? AppColors.primary
                          : Colors.white.withAlpha(30),
                      disabledBackgroundColor: Colors.white.withAlpha(30),
                    ),
                    child: Text(
                      step == steps.length - 1
                          ? 'Create My Companion'
                          : 'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canProceed ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'What should we call you?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your companion will use this name',
              style: TextStyle(
                color: Colors.white.withAlpha(150),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
      case 1:
        return _OptionGrid<OCDTheme>(
          title: 'OCD Themes',
          subtitle: 'Select any themes you want to work on. Optional.',
          options: const [
            _Option(OCDTheme.contamination, 'Contamination', '🧼'),
            _Option(OCDTheme.harm, 'Harm', '⚠️'),
            _Option(OCDTheme.checking, 'Checking', '🔍'),
            _Option(OCDTheme.tabooThoughts, 'Taboo Thoughts', '💭'),
            _Option(OCDTheme.symmetry, 'Symmetry', '⚖️'),
            _Option(OCDTheme.perfectionism, 'Perfectionism', '✨'),
            _Option(OCDTheme.relationship, 'Relationship', '💕'),
            _Option(OCDTheme.health, 'Health', '🏥'),
            _Option(OCDTheme.existential, 'Existential', '🌌'),
          ],
          isSelected: (value) => selectedOcd.contains(value),
          onToggle: toggleOcd,
        );
      case 2:
        return _OptionGrid<ADHDTrait>(
          title: 'ADHD Traits',
          subtitle: 'This helps us adapt the experience for you. Optional.',
          options: const [
            _Option(ADHDTrait.impulsivity, 'Impulsivity', '⚡'),
            _Option(ADHDTrait.attentionIssues, 'Attention Issues', '🎯'),
            _Option(
              ADHDTrait.executiveDysfunction,
              'Executive Dysfunction',
              '🧩',
            ),
            _Option(ADHDTrait.procrastination, 'Procrastination', '⏰'),
            _Option(
              ADHDTrait.emotionalDysregulation,
              'Emotional Dysregulation',
              '🎭',
            ),
            _Option(ADHDTrait.timeBlindness, 'Time Blindness', '⌛'),
            _Option(ADHDTrait.hyperfocus, 'Hyperfocus', '🔥'),
          ],
          isSelected: (value) => selectedAdhd.contains(value),
          onToggle: toggleAdhd,
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coaching Style',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How would you like your companion to communicate?',
              style: TextStyle(
                color: Colors.white.withAlpha(150),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ...[
              _ToneOption(
                CoachingTone.gentle,
                'Gentle',
                'Soft, nurturing approach',
                '🌸',
              ),
              _ToneOption(
                CoachingTone.direct,
                'Direct',
                'Clear, straightforward guidance',
                '🎯',
              ),
              _ToneOption(
                CoachingTone.humorous,
                'Humorous',
                'Light-hearted and playful',
                '😊',
              ),
              _ToneOption(
                CoachingTone.calm,
                'Calm',
                'Peaceful, grounding presence',
                '🍃',
              ),
            ].map((option) {
              final isSelected = selectedTone == option.tone;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => selectedTone = option.tone),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(50)
                            : Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white.withAlpha(20),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withAlpha(200)
                                  : Colors.white.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                option.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.description,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(150),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Option<T> {
  final T value;
  final String label;
  final String emoji;

  const _Option(this.value, this.label, this.emoji);
}

class _OptionGrid<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_Option<T>> options;
  final bool Function(T) isSelected;
  final ValueChanged<T> onToggle;

  const _OptionGrid({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 16),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          physics: const NeverScrollableScrollPhysics(),
          children: options.map((option) {
            final active = isSelected(option.value);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onToggle(option.value),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary.withAlpha(50)
                        : Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppColors.primary
                          : Colors.white.withAlpha(20),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.emoji, style: const TextStyle(fontSize: 28)),
                      const Spacer(),
                      Text(
                        option.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: active ? Colors.white : Colors.white70,
                        ),
                      ),
                      if (active)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ToneOption {
  final CoachingTone tone;
  final String label;
  final String description;
  final String emoji;

  const _ToneOption(this.tone, this.label, this.description, this.emoji);
}
