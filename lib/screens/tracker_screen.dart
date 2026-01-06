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
  final emotions = const ['Anxious', 'Fearful', 'Guilty', 'Disgusted', 'Sad', 'Angry', 'Ashamed'];
  final sensations = const ['Racing heart', 'Sweating', 'Tight chest', 'Nausea', 'Dizziness', 'Trembling'];
  final compulsions = const ['Checking', 'Washing', 'Seeking reassurance', 'Mental rituals', 'Avoidance', 'Counting'];

  void _openAddTrigger(BuildContext context) {
    final appState = AppStateScope.of(context);
    final descriptionController = TextEditingController();
    final notesController = TextEditingController();
    String triggerType = 'internal';
    int suds = 50;
    final selectedEmotions = <String>[];
    final selectedSensations = <String>[];
    final selectedCompulsions = <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Log a Trigger',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Internal'),
                            selected: triggerType == 'internal',
                            onSelected: (_) => setSheetState(() => triggerType = 'internal'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('External'),
                            selected: triggerType == 'external',
                            onSelected: (_) => setSheetState(() => triggerType = 'external'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('What triggered you?'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.muted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SUDSSlider(value: suds, onChanged: (v) => setSheetState(() => suds = v)),
                    const SizedBox(height: 12),
                    _ChipPicker(
                      title: 'Emotions',
                      options: emotions,
                      selected: selectedEmotions,
                      onToggle: (value) => setSheetState(() => _toggle(value, selectedEmotions)),
                    ),
                    _ChipPicker(
                      title: 'Physical Sensations',
                      options: sensations,
                      selected: selectedSensations,
                      onToggle: (value) => setSheetState(() => _toggle(value, selectedSensations)),
                    ),
                    _ChipPicker(
                      title: 'Compulsions/Avoidance',
                      options: compulsions,
                      selected: selectedCompulsions,
                      onToggle: (value) => setSheetState(() => _toggle(value, selectedCompulsions)),
                    ),
                    const Text('Additional Notes'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
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
                                    Navigator.pop(sheetContext);
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
          },
        );
      },
    ).whenComplete(() {
      descriptionController.dispose();
      notesController.dispose();
    });
  }

  void _toggle(String value, List<String> list) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final recentLogs = appState.triggerLogs.take(5).toList();
    final avgSuds = recentLogs.isEmpty
        ? 0
        : (recentLogs.map((e) => e.suds).reduce((a, b) => a + b) ~/ recentLogs.length);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const AppHeader(),
            const TabBar(
              labelColor: AppColors.primary,
              tabs: [
                Tab(text: 'Triggers'),
                Tab(text: 'Expectancy Log'),
              ],
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
                            _StatTile(label: 'Triggers Logged', value: appState.triggerLogs.length.toString()),
                            const SizedBox(width: 12),
                            _StatTile(label: 'Avg. SUDs', value: avgSuds.toString()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openAddTrigger(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Log a Trigger'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (recentLogs.isEmpty)
                          _EmptyState(
                            icon: Icons.track_changes,
                            title: 'Start Tracking',
                            message: 'Log your triggers to discover patterns.',
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recent Logs',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 12),
                              ...recentLogs.map((log) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: log.type == 'internal'
                                          ? AppColors.calmLight
                                          : AppColors.accentLight,
                                      child: Icon(
                                        log.type == 'internal' ? Icons.psychology : Icons.flash_on,
                                        color: log.type == 'internal'
                                            ? AppColors.calm
                                            : AppColors.accent,
                                      ),
                                    ),
                                    title: Text(log.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    subtitle: Text('SUDs ${log.suds} · ${log.emotions.take(2).join(', ')}'),
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.clarityLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Expectancy violations: the gap between prediction and reality is where new learning happens.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (appState.exposureSessions.isEmpty)
                          _EmptyState(
                            icon: Icons.trending_up,
                            title: 'No Sessions Yet',
                            message: 'Complete exposure sessions to track expectancy violations.',
                          )
                        else
                          Column(
                            children: appState.exposureSessions.take(5).map((session) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Predicted: ${session.prediction}'),
                                      const SizedBox(height: 6),
                                      Text('Actual: ${session.outcome}'),
                                      const SizedBox(height: 8),
                                      Text('Pre ${session.preSuds} → Post ${session.postSuds}'),
                                    ],
                                  ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              return FilterChip(
                label: Text(option),
                selected: selected.contains(option),
                onSelected: (_) => onToggle(option),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.clarity),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedText)),
        ],
      ),
    );
  }
}
