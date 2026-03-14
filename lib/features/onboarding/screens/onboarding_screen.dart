import 'package:flutter/material.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/features/auth/providers/app_auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final nameController = TextEditingController();
  AgeMode selectedAgeMode = AgeMode.older;
  final List<OCDTheme> selectedOcdThemes = [];
  final List<ADHDTrait> selectedAdhdTraits = [];
  final List<String> selectedSensitivities = [];
  CoachingTone selectedTone = CoachingTone.gentle;

  final sensitivityOptions = const [
    'Perfectionism pressure',
    'Family reassurance loops',
    'Health fear spikes',
    'Crowded schedules',
    'Late-night rumination',
    'Decision overload',
  ];

  final steps = const [
    'Name',
    'Age Mode',
    'OCD Themes',
    'ADHD Traits',
    'Sensitivity Notes',
    'Coaching Tone',
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _handleNext(AppAuthProvider auth) async {
    if (step < steps.length - 1) {
      setState(() => step += 1);
      return;
    }

    await auth.saveOnboarding(
      name: nameController.text.trim(),
      ageMode: selectedAgeMode,
      ocdThemes: selectedOcdThemes,
      adhdTraits: selectedAdhdTraits,
      sensitivities: selectedSensitivities,
      coachingTone: selectedTone,
    );
  }

  bool get _canContinue {
    if (step == 0) {
      return nameController.text.trim().isNotEmpty;
    }
    return true;
  }

  void _toggleItem<T>(List<T> source, T value) {
    setState(() {
      if (source.contains(value)) {
        source.remove(value);
      } else {
        source.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppAuthScope.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: step == 0
            ? IconButton(
                onPressed: auth.isSubmitting ? null : () => auth.signOut(),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              )
            : IconButton(
                onPressed: () => setState(() => step -= 1),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
        title: Text('${step + 1} of ${steps.length}'),
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
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (step + 1) / steps.length,
                    minHeight: 8,
                    backgroundColor: Colors.white.withAlpha(18),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStep(),
                ),
              ),
              if (auth.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: Color(0xFFFCA5A5)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !_canContinue || auth.isSubmitting
                        ? null
                        : () => _handleNext(auth),
                    child: Text(
                      auth.isSubmitting
                          ? 'Saving...'
                          : step == steps.length - 1
                          ? 'Save and continue'
                          : 'Continue',
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
        return _IntroCard(
          title: 'What should we call you?',
          subtitle: 'Your companion and reflections will use this name.',
          child: TextField(
            controller: nameController,
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
        );
      case 1:
        return _ChoiceList<AgeMode>(
          title: 'Choose the experience style',
          subtitle: 'This tunes language, pacing, and rewards.',
          options: const [
            _ChoiceItem(
              value: AgeMode.younger,
              title: 'Younger mode',
              subtitle: 'More playful and simple language',
              emoji: '🌱',
            ),
            _ChoiceItem(
              value: AgeMode.older,
              title: 'Older mode',
              subtitle: 'More direct and mature guidance',
              emoji: '🧭',
            ),
          ],
          selected: selectedAgeMode,
          onSelect: (value) => setState(() => selectedAgeMode = value),
        );
      case 2:
        return _SelectableGrid<OCDTheme>(
          title: 'Which OCD themes matter most right now?',
          subtitle: 'Pick any that fit. You can adjust later.',
          options: const [
            _GridItem(
              value: OCDTheme.contamination,
              label: 'Contamination',
              emoji: '🧼',
            ),
            _GridItem(value: OCDTheme.harm, label: 'Harm', emoji: '⚠️'),
            _GridItem(value: OCDTheme.checking, label: 'Checking', emoji: '🔍'),
            _GridItem(
              value: OCDTheme.tabooThoughts,
              label: 'Taboo thoughts',
              emoji: '💭',
            ),
            _GridItem(value: OCDTheme.symmetry, label: 'Symmetry', emoji: '⚖️'),
            _GridItem(
              value: OCDTheme.perfectionism,
              label: 'Perfectionism',
              emoji: '✨',
            ),
            _GridItem(
              value: OCDTheme.relationship,
              label: 'Relationship',
              emoji: '💕',
            ),
            _GridItem(value: OCDTheme.health, label: 'Health', emoji: '🏥'),
          ],
          selectedValues: selectedOcdThemes,
          onToggle: (value) => _toggleItem(selectedOcdThemes, value),
        );
      case 3:
        return _SelectableGrid<ADHDTrait>(
          title: 'Any ADHD traits to account for?',
          subtitle: 'Optional, but useful for pacing and prompts.',
          options: const [
            _GridItem(
              value: ADHDTrait.impulsivity,
              label: 'Impulsivity',
              emoji: '⚡',
            ),
            _GridItem(
              value: ADHDTrait.attentionIssues,
              label: 'Attention',
              emoji: '🎯',
            ),
            _GridItem(
              value: ADHDTrait.executiveDysfunction,
              label: 'Executive',
              emoji: '🧩',
            ),
            _GridItem(
              value: ADHDTrait.procrastination,
              label: 'Procrastination',
              emoji: '⏰',
            ),
            _GridItem(
              value: ADHDTrait.emotionalDysregulation,
              label: 'Emotional swings',
              emoji: '🎭',
            ),
            _GridItem(
              value: ADHDTrait.timeBlindness,
              label: 'Time blindness',
              emoji: '⌛',
            ),
            _GridItem(
              value: ADHDTrait.hyperfocus,
              label: 'Hyperfocus',
              emoji: '🔥',
            ),
          ],
          selectedValues: selectedAdhdTraits,
          onToggle: (value) => _toggleItem(selectedAdhdTraits, value),
        );
      case 4:
        return _SelectableGrid<String>(
          title: 'What tends to make the day harder?',
          subtitle: 'These become useful context in future tasks.',
          options: sensitivityOptions
              .map((item) => _GridItem(value: item, label: item, emoji: '•'))
              .toList(),
          selectedValues: selectedSensitivities,
          onToggle: (value) => _toggleItem(selectedSensitivities, value),
        );
      case 5:
        return _ChoiceList<CoachingTone>(
          title: 'How should your companion talk to you?',
          subtitle: 'Choose the style that feels easiest to trust.',
          options: const [
            _ChoiceItem(
              value: CoachingTone.gentle,
              title: 'Gentle',
              subtitle: 'Warm, steady, and encouraging',
              emoji: '🌙',
            ),
            _ChoiceItem(
              value: CoachingTone.direct,
              title: 'Direct',
              subtitle: 'Clear and straightforward',
              emoji: '🎯',
            ),
            _ChoiceItem(
              value: CoachingTone.humorous,
              title: 'Humorous',
              subtitle: 'Lighter and playful when possible',
              emoji: '🙂',
            ),
            _ChoiceItem(
              value: CoachingTone.calm,
              title: 'Calm',
              subtitle: 'Grounded and unhurried',
              emoji: '🍃',
            ),
          ],
          selected: selectedTone,
          onSelect: (value) => setState(() => selectedTone = value),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(12),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 15),
        ),
        const SizedBox(height: 36),
        child,
      ],
    );
  }
}

class _ChoiceItem<T> {
  const _ChoiceItem({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  final T value;
  final String title;
  final String subtitle;
  final String emoji;
}

class _ChoiceList<T> extends StatelessWidget {
  const _ChoiceList({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final List<_ChoiceItem<T>> options;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 15),
        ),
        const SizedBox(height: 24),
        ...options.map((option) {
          final isSelected = option.value == selected;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              onTap: () => onSelect(option.value),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(42)
                      : Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withAlpha(18),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(option.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.subtitle,
                            style: TextStyle(
                              color: Colors.white.withAlpha(160),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _GridItem<T> {
  const _GridItem({
    required this.value,
    required this.label,
    required this.emoji,
  });

  final T value;
  final String label;
  final String emoji;
}

class _SelectableGrid<T> extends StatelessWidget {
  const _SelectableGrid({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedValues,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final List<_GridItem<T>> options;
  final List<T> selectedValues;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 15),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          itemCount: options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = selectedValues.contains(option.value);
            return InkWell(
              onTap: () => onToggle(option.value),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(42)
                      : Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withAlpha(18),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.emoji, style: const TextStyle(fontSize: 24)),
                    const Spacer(),
                    Text(
                      option.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white.withAlpha(140),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
