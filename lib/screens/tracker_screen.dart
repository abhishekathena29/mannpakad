import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/suds_slider.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final emotions = const [
    'Anxious',
    'Fearful',
    'Guilty',
    'Disgusted',
    'Sad',
    'Angry',
    'Ashamed',
  ];
  final sensations = const [
    'Racing heart',
    'Sweating',
    'Tight chest',
    'Nausea',
    'Dizziness',
    'Trembling',
  ];
  final compulsions = const [
    'Checking',
    'Washing',
    'Seeking reassurance',
    'Mental rituals',
    'Avoidance',
    'Counting',
  ];

  void _openAddTrigger(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddTriggerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final recentLogs = appState.triggerLogs.take(5).toList();
    final avgSuds = recentLogs.isEmpty
        ? 0
        : (recentLogs.map((e) => e.suds).reduce((a, b) => a + b) ~/
              recentLogs.length);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.gradientDark,
            ),
          ),
          child: Column(
            children: [
              const AppHeader(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Triggers'),
                    Tab(text: 'Expectancy Log'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _StatTile(
                                label: 'Triggers Logged',
                                value: appState.triggerLogs.length.toString(),
                              ),
                              const SizedBox(width: 12),
                              _StatTile(
                                label: 'Avg. SUDs',
                                value: avgSuds.toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _openAddTrigger(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Log a Trigger'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (recentLogs.isEmpty)
                            _EmptyState(
                              icon: Icons.track_changes,
                              title: 'Start Tracking',
                              message:
                                  'Log your triggers to discover patterns.',
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recent Logs',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...recentLogs.map((log) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(10),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(10),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: log.type == 'internal'
                                            ? AppColors.calm.withAlpha(50)
                                            : AppColors.accent.withAlpha(50),
                                        child: Icon(
                                          log.type == 'internal'
                                              ? Icons.psychology
                                              : Icons.flash_on,
                                          color: log.type == 'internal'
                                              ? AppColors.calm
                                              : AppColors.accent,
                                        ),
                                      ),
                                      title: Text(
                                        log.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'SUDs ${log.suds} · ${log.emotions.take(2).join(', ')}',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(150),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.clarity.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.clarity.withAlpha(50),
                              ),
                            ),
                            child: const Text(
                              'Expectancy violations: the gap between prediction and reality is where new learning happens.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (appState.exposureSessions.isEmpty)
                            _EmptyState(
                              icon: Icons.trending_up,
                              title: 'No Sessions Yet',
                              message:
                                  'Complete exposure sessions to track expectancy violations.',
                            )
                          else
                            Column(
                              children: appState.exposureSessions.take(5).map((
                                session,
                              ) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(10),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Predicted: ${session.prediction}',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(200),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Actual: ${session.outcome}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pre ${session.preSuds} → Post ${session.postSuds}',
                                        style: TextStyle(
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const BottomNav(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(10)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(150),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipPicker extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _ChipPicker({
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selected.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (_) => onToggle(option),
                selectedColor: AppColors.primary.withAlpha(80),
                backgroundColor: Colors.white.withAlpha(10),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.white.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withAlpha(150)),
          ),
        ],
      ),
    );
  }
}

class _AddTriggerSheet extends StatefulWidget {
  const _AddTriggerSheet();

  @override
  State<_AddTriggerSheet> createState() => _AddTriggerSheetState();
}

class _AddTriggerSheetState extends State<_AddTriggerSheet> {
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();
  String triggerType = 'internal';
  int suds = 50;
  final selectedEmotions = <String>[];
  final selectedSensations = <String>[];
  final selectedCompulsions = <String>[];

  final emotions = const [
    'Anxious',
    'Fearful',
    'Guilty',
    'Disgusted',
    'Sad',
    'Angry',
    'Ashamed',
  ];
  final sensations = const [
    'Racing heart',
    'Sweating',
    'Tight chest',
    'Nausea',
    'Dizziness',
    'Trembling',
  ];
  final compulsions = const [
    'Checking',
    'Washing',
    'Seeking reassurance',
    'Mental rituals',
    'Avoidance',
    'Counting',
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _toggle(String value, List<String> list) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Log a Trigger',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Internal'),
                    selected: triggerType == 'internal',
                    onSelected: (_) => setState(() => triggerType = 'internal'),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white.withAlpha(20),
                    labelStyle: TextStyle(
                      color: triggerType == 'internal'
                          ? Colors.white
                          : Colors.white70,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('External'),
                    selected: triggerType == 'external',
                    onSelected: (_) => setState(() => triggerType = 'external'),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white.withAlpha(20),
                    labelStyle: TextStyle(
                      color: triggerType == 'external'
                          ? Colors.white
                          : Colors.white70,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'What triggered you?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                hintText: 'Describe the situation...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SUDSSlider(value: suds, onChanged: (v) => setState(() => suds = v)),
            const SizedBox(height: 20),
            _ChipPicker(
              title: 'Emotions',
              options: emotions,
              selected: selectedEmotions,
              onToggle: (value) => _toggle(value, selectedEmotions),
            ),
            _ChipPicker(
              title: 'Physical Sensations',
              options: sensations,
              selected: selectedSensations,
              onToggle: (value) => _toggle(value, selectedSensations),
            ),
            _ChipPicker(
              title: 'Compulsions/Avoidance',
              options: compulsions,
              selected: selectedCompulsions,
              onToggle: (value) => _toggle(value, selectedCompulsions),
            ),
            const Text(
              'Additional Notes',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                hintText: 'Any other details?',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withAlpha(100)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: descriptionController.text.trim().isEmpty
                        ? null
                        : () {
                            appState.addTriggerLog(
                              type: triggerType,
                              description: descriptionController.text.trim(),
                              category: '',
                              suds: suds,
                              emotions: [...selectedEmotions],
                              physicalSensations: [...selectedSensations],
                              compulsions: [...selectedCompulsions],
                              notes: notesController.text.trim(),
                            );
                            Navigator.pop(context);
                          },
                    child: const Text('Save Log'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
