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

  final steps = const ['Your Name', 'OCD Themes', 'ADHD Traits', 'Coaching Style'];

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
      appBar: AppBar(
        leading: IconButton(onPressed: handleBack, icon: const Icon(Icons.arrow_back)),
        title: Text('${step + 1} of ${steps.length}'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (step + 1) / steps.length,
            backgroundColor: AppColors.muted,
            color: AppColors.primary,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStep(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canProceed ? handleNext : null,
                child: Text(step == steps.length - 1 ? 'Create My Companion' : 'Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return Column(
          children: [
            const Text('What should we call you?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Your companion will use this name',
                style: TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                filled: true,
                fillColor: AppColors.muted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
            _Option(ADHDTrait.executiveDysfunction, 'Executive Dysfunction', '🧩'),
            _Option(ADHDTrait.procrastination, 'Procrastination', '⏰'),
            _Option(ADHDTrait.emotionalDysregulation, 'Emotional Dysregulation', '🎭'),
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
            const Text('Coaching Style',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('How would you like your companion to communicate?',
                style: TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 16),
            ...[
              _ToneOption(CoachingTone.gentle, 'Gentle', 'Soft, nurturing approach', '🌸'),
              _ToneOption(CoachingTone.direct, 'Direct', 'Clear, straightforward guidance', '🎯'),
              _ToneOption(CoachingTone.humorous, 'Humorous', 'Light-hearted and playful', '😊'),
              _ToneOption(CoachingTone.calm, 'Calm', 'Peaceful, grounding presence', '🍃'),
            ].map((option) {
              final isSelected = selectedTone == option.tone;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => selectedTone = option.tone),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accentLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(option.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(option.description,
                                  style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.accent),
                      ],
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: AppColors.mutedText)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          physics: const NeverScrollableScrollPhysics(),
          children: options.map((option) {
            final active = isSelected(option.value);
            return InkWell(
              onTap: () => onToggle(option.value),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? AppColors.primary : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    Text(option.label,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const Spacer(),
                    if (active)
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.check, size: 16, color: AppColors.primary),
                      ),
                  ],
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
