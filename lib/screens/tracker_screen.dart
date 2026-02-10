import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
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
                    Tab(text: 'Progress Board'),
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
                    _ProgressBoard(
                      exposureSessions: appState.exposureSessions,
                      aiExposureSessions: appState.aiExposureSessions,
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

class _ProgressBoard extends StatelessWidget {
  final List<ExposureSession> exposureSessions;
  final List<AIExposureSession> aiExposureSessions;

  const _ProgressBoard({
    required this.exposureSessions,
    required this.aiExposureSessions,
  });

  Map<String, List<dynamic>> _groupSessions() {
    // Combine and sort
    final allSessions = [...exposureSessions, ...aiExposureSessions]
      ..sort((a, b) {
        final aDate = a is ExposureSession
            ? a.completedAt
            : (a as AIExposureSession).createdAt;
        final bDate = b is ExposureSession
            ? b.completedAt
            : (b as AIExposureSession).createdAt;
        return bDate.compareTo(aDate);
      });

    final Map<String, List<dynamic>> grouped = {};
    for (var session in allSessions) {
      final date = session is ExposureSession
          ? session.completedAt
          : (session as AIExposureSession).createdAt;
      final now = DateTime.now();
      String key;

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        key = 'Today';
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        key = 'Yesterday';
      } else {
        key = '${_weekday(date.weekday)}, ${date.day}/${date.month}';
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(session);
    }
    return grouped;
  }

  String _weekday(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) return '${minutes}m';
      return '${minutes}m ${remainingSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exposureSessions.isEmpty && aiExposureSessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: _EmptyState(
          icon: Icons.trending_up,
          title: 'No Progress Yet',
          message:
              'Complete exposures to see your progress board here. Higher anxiety tasks require shorter durations.',
        ),
      );
    }

    final grouped = _groupSessions();
    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final day = keys[index];
        final daySessions = grouped[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(
                day,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
            ...daySessions.map((session) {
              final isManual = session is ExposureSession;
              final duration = isManual
                  ? session.duration
                  : (session as AIExposureSession).duration;
              final postSuds = isManual
                  ? session.postSuds
                  : (session as AIExposureSession).postSuds;
              final typeName = isManual
                  ? (session.exerciseType.name == 'inVivo'
                        ? 'In Vivo'
                        : session.exerciseType.name)
                  : 'AI Task';

              String title;
              if (isManual) {
                title = session.outcome.isNotEmpty
                    ? session.outcome
                    : (session.prediction.isNotEmpty
                          ? session.prediction
                          : "Exposure Session");
              } else {
                title = (session as AIExposureSession).task.title;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(10)),
                ),
                child: Row(
                  children: [
                    // Duration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(50),
                        ),
                      ),
                      child: Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SUDs $postSuds · $typeName',
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
