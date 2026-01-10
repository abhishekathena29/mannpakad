import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

enum ValuesPhase { select, explore, connect, complete }

class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  ValuesPhase phase = ValuesPhase.select;
  final List<ValueDomain> selectedDomains = [];
  int currentDomainIndex = 0;
  final Map<ValueDomain, TextEditingController> ocdFreeActions = {};
  final Map<ValueDomain, TextEditingController> toleranceReasons = {};

  final domains = const [
    _ValueDomain(
      ValueDomain.relationships,
      'Relationships',
      '💕',
      'Connection with others',
    ),
    _ValueDomain(
      ValueDomain.learning,
      'Learning',
      '📚',
      'Growth and knowledge',
    ),
    _ValueDomain(
      ValueDomain.kindness,
      'Kindness',
      '🤝',
      'Compassion and helping',
    ),
    _ValueDomain(
      ValueDomain.independence,
      'Independence',
      '🦅',
      'Autonomy and freedom',
    ),
    _ValueDomain(
      ValueDomain.health,
      'Health',
      '💪',
      'Physical and mental wellness',
    ),
    _ValueDomain(
      ValueDomain.courage,
      'Courage',
      '🦁',
      'Bravery and facing fears',
    ),
    _ValueDomain(
      ValueDomain.creativity,
      'Creativity',
      '🎨',
      'Expression and innovation',
    ),
    _ValueDomain(
      ValueDomain.authenticity,
      'Authenticity',
      '✨',
      'Being true to yourself',
    ),
  ];

  @override
  void dispose() {
    for (final controller in ocdFreeActions.values) {
      controller.dispose();
    }
    for (final controller in toleranceReasons.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withAlpha(20),
      hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(16),
    );

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

    final appState = AppStateScope.of(context);

    if (phase == ValuesPhase.complete) {
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
                    color: AppColors.accent.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.accent,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Values Clarified',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your values guide your recovery journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => appState.setCurrentView(AppView.home),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (phase == ValuesPhase.connect) {
      return buildGradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => setState(() => phase = ValuesPhase.explore),
          ),
          title: const Text(
            'Connect to ERP',
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.gradientAccent),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(50),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Values',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: selectedDomains.map((domain) {
                        final data = domains.firstWhere((d) => d.id == domain);
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            data.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Complete this sentence for each value:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ...selectedDomains.map((domain) {
                final data = domains.firstWhere((d) => d.id == domain);
                final controller = toleranceReasons.putIfAbsent(
                  domain,
                  () => TextEditingController(),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(data.icon, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            data.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (_) => setState(() {}),
                        decoration: inputDecoration(
                          'I tolerate uncertainty because...',
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      selectedDomains.any(
                        (domain) =>
                            toleranceReasons[domain]?.text.trim().isEmpty ??
                            true,
                      )
                      ? null
                      : () {
                          for (final domain in selectedDomains) {
                            appState.addValuesEntry(
                              domain: domain,
                              ocdFreeActions:
                                  ocdFreeActions[domain]?.text.trim() ?? '',
                              toleranceReason:
                                  toleranceReasons[domain]?.text.trim() ?? '',
                            );
                          }
                          appState.earnReward(
                            ExerciseType.valuesClarification,
                            'Completed values clarification',
                          );
                          setState(() => phase = ValuesPhase.complete);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Complete Values Exercise'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (phase == ValuesPhase.explore) {
      final domain = selectedDomains[currentDomainIndex];
      final data = domains.firstWhere((d) => d.id == domain);
      final controller = ocdFreeActions.putIfAbsent(
        domain,
        () => TextEditingController(),
      );
      return buildGradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (currentDomainIndex > 0) {
                setState(() => currentDomainIndex -= 1);
              } else {
                setState(() => phase = ValuesPhase.select);
              }
            },
          ),
          title: Text(
            '${currentDomainIndex + 1} of ${selectedDomains.length}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Text(data.icon, style: const TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 16),
              Text(
                data.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.description,
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => setState(() {}),
                decoration: inputDecoration(
                  'If OCD was not in charge, I would...',
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.text.trim().isEmpty
                      ? null
                      : () {
                          if (currentDomainIndex < selectedDomains.length - 1) {
                            setState(() => currentDomainIndex += 1);
                          } else {
                            setState(() => phase = ValuesPhase.connect);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    currentDomainIndex < selectedDomains.length - 1
                        ? 'Next Value'
                        : 'Connect to ERP',
                  ),
                ),
              ),
            ],
          ),
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
          'Values Clarification',
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
                color: AppColors.accent.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accentLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Connecting to your values keeps motivation strong while progressing up the fear hierarchy.',
                      style: TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose 2 value domains to explore:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: domains.map((domain) {
                  final active = selectedDomains.contains(domain.id);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (active) {
                          selectedDomains.remove(domain.id);
                        } else if (selectedDomains.length < 2) {
                          selectedDomains.add(domain.id);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.accent.withAlpha(50)
                            : Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppColors.accent
                              : Colors.white.withAlpha(10),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            domain.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            domain.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (active) ...[
                            const SizedBox(height: 8),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Center(
              child: Text(
                '${selectedDomains.length}/2 selected',
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedDomains.isEmpty
                    ? null
                    : () => setState(() {
                        phase = ValuesPhase.explore;
                        currentDomainIndex = 0;
                      }),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Explore Values'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueDomain {
  final ValueDomain id;
  final String label;
  final String icon;
  final String description;

  const _ValueDomain(this.id, this.label, this.icon, this.description);
}
