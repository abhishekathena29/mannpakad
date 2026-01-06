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
    _ValueDomain(ValueDomain.relationships, 'Relationships', '💕', 'Connection with others'),
    _ValueDomain(ValueDomain.learning, 'Learning', '📚', 'Growth and knowledge'),
    _ValueDomain(ValueDomain.kindness, 'Kindness', '🤝', 'Compassion and helping'),
    _ValueDomain(ValueDomain.independence, 'Independence', '🦅', 'Autonomy and freedom'),
    _ValueDomain(ValueDomain.health, 'Health', '💪', 'Physical and mental wellness'),
    _ValueDomain(ValueDomain.courage, 'Courage', '🦁', 'Bravery and facing fears'),
    _ValueDomain(ValueDomain.creativity, 'Creativity', '🎨', 'Expression and innovation'),
    _ValueDomain(ValueDomain.authenticity, 'Authenticity', '✨', 'Being true to yourself'),
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
    final appState = AppStateScope.of(context);

    if (phase == ValuesPhase.complete) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: AppColors.accent, size: 80),
                const SizedBox(height: 16),
                const Text('Values Clarified', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Your values guide your recovery journey.',
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

    if (phase == ValuesPhase.connect) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => phase = ValuesPhase.explore),
          ),
          title: const Text('Connect to ERP'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Your Values', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: selectedDomains.map((domain) {
                        final data = domains.firstWhere((d) => d.id == domain);
                        return Text(data.icon, style: const TextStyle(fontSize: 28));
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Complete this sentence for each value:'),
              const SizedBox(height: 8),
              ...selectedDomains.map((domain) {
                final data = domains.firstWhere((d) => d.id == domain);
                final controller = toleranceReasons.putIfAbsent(domain, () => TextEditingController());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data.icon} ${data.label}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller,
                        maxLines: 2,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'I tolerate uncertainty because...',
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
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedDomains.any((domain) =>
                          toleranceReasons[domain]?.text.trim().isEmpty ?? true)
                      ? null
                      : () {
                          for (final domain in selectedDomains) {
                            appState.addValuesEntry(
                              domain: domain,
                              ocdFreeActions: ocdFreeActions[domain]?.text.trim() ?? '',
                              toleranceReason: toleranceReasons[domain]?.text.trim() ?? '',
                            );
                          }
                          appState.earnReward(ExerciseType.valuesClarification,
                              'Completed values clarification');
                          setState(() => phase = ValuesPhase.complete);
                        },
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
      final controller = ocdFreeActions.putIfAbsent(domain, () => TextEditingController());
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (currentDomainIndex > 0) {
                setState(() => currentDomainIndex -= 1);
              } else {
                setState(() => phase = ValuesPhase.select);
              }
            },
          ),
          title: Text('${currentDomainIndex + 1} of ${selectedDomains.length}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(data.icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(data.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text(data.description, style: TextStyle(color: AppColors.mutedText)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'If OCD was not in charge, I would...',
                  filled: true,
                  fillColor: AppColors.muted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
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
                  child: Text(currentDomainIndex < selectedDomains.length - 1
                      ? 'Next Value'
                      : 'Connect to ERP'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Values Clarification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Connecting to your values keeps motivation strong while progressing up the fear hierarchy.',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose 2 value domains to explore:'),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accentLight : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active ? AppColors.accent : const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(domain.icon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 8),
                          Text(domain.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          if (active)
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.check, color: AppColors.accent, size: 16),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Text('${selectedDomains.length}/2 selected', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedDomains.isEmpty
                    ? null
                    : () => setState(() {
                          phase = ValuesPhase.explore;
                          currentDomainIndex = 0;
                        }),
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
