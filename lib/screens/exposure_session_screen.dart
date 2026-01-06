import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/suds_slider.dart';

enum SessionPhase { select, pre, during, post, complete }

class ExposureSessionScreen extends StatefulWidget {
  const ExposureSessionScreen({super.key});

  @override
  State<ExposureSessionScreen> createState() => _ExposureSessionScreenState();
}

class _ExposureSessionScreenState extends State<ExposureSessionScreen> {
  SessionPhase phase = SessionPhase.select;
  String? selectedTaskId;
  final predictionController = TextEditingController();
  int preSuds = 50;
  int currentSuds = 50;
  final List<SUDSReading> readings = [];
  int postSuds = 50;
  final outcomeController = TextEditingController();
  final learningsController = TextEditingController();
  bool compulsionResisted = false;
  bool isTimerRunning = false;
  int elapsedTime = 0;
  Timer? timer;

  void resetSessionState({bool keepSelection = false}) {
    predictionController.clear();
    outcomeController.clear();
    learningsController.clear();
    preSuds = 50;
    currentSuds = 50;
    postSuds = 50;
    readings.clear();
    compulsionResisted = false;
    isTimerRunning = false;
    elapsedTime = 0;
    timer?.cancel();
    if (!keepSelection) {
      selectedTaskId = null;
    }
  }

  @override
  void dispose() {
    predictionController.dispose();
    outcomeController.dispose();
    learningsController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isTimerRunning || phase != SessionPhase.during) return;
      setState(() => elapsedTime += 1);
    });
  }

  FearHierarchyItem? _resolveSelectedTask(AppState appState) {
    if (selectedTaskId == null) return null;
    for (final item in appState.fearHierarchy) {
      if (item.id == selectedTaskId) {
        return item;
      }
    }
    return null;
  }

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString()}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final selectedTask = _resolveSelectedTask(appState);
    final task = selectedTask ??
        (appState.fearHierarchy.isNotEmpty
            ? appState.fearHierarchy.first
            : FearHierarchyItem(
                id: '',
                scenario: '',
                suds: 50,
                exposureType: ExposureType.inVivo,
                exerciseType: ExerciseType.inVivo,
                hierarchyLevel: 1,
                tags: const [],
                completed: false,
                completedCount: 0,
                createdAt: DateTime.now(),
              ));

    switch (phase) {
      case SessionPhase.select:
        return _buildSelect(appState, selectedTask);
      case SessionPhase.pre:
        return _buildPre(task);
      case SessionPhase.during:
        return _buildDuring(task);
      case SessionPhase.post:
        return _buildPost(task, appState);
      case SessionPhase.complete:
        return _buildComplete(appState);
    }
  }

  Widget _buildSelect(AppState appState, FearHierarchyItem? selectedTask) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Start Exposure'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Choose an exposure task to practice',
                style: TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 16),
            Expanded(
              child: appState.fearHierarchy.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No exposure tasks yet.',
                              style: TextStyle(color: AppColors.mutedText)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => appState.setCurrentView(AppView.hierarchy),
                            child: const Text('Create Your First Task'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: appState.fearHierarchy.length,
                      itemBuilder: (context, index) {
                        final item = appState.fearHierarchy[index];
                        final selected = selectedTaskId == item.id;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => setState(() => selectedTaskId = item.id),
                            title: Text(item.scenario),
                            subtitle: Text(
                              'Level ${item.hierarchyLevel} · SUDs ${item.suds} · ${item.exposureType.name} · ${item.completedCount}x',
                            ),
                            trailing: selected
                                ? const Icon(Icons.check_circle, color: AppColors.primary)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            if (selectedTask != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      resetSessionState(keepSelection: true);
                      phase = SessionPhase.pre;
                      preSuds = selectedTask.suds;
                      currentSuds = selectedTask.suds;
                    });
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Session'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPre(FearHierarchyItem task) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => phase = SessionPhase.select),
        ),
        title: const Text('Pre-Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(task.scenario),
            ),
            const SizedBox(height: 16),
            const Text('What do you predict will happen?'),
            const SizedBox(height: 8),
            TextField(
              controller: predictionController,
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
            SUDSSlider(value: preSuds, onChanged: (v) => setState(() => preSuds = v)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.calmLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Remember: the goal is learning, not feeling less anxious.',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: predictionController.text.trim().isEmpty
                    ? null
                    : () {
                        setState(() {
                          phase = SessionPhase.during;
                          isTimerRunning = true;
                          currentSuds = preSuds;
                          readings.add(SUDSReading(timestamp: DateTime.now(), value: preSuds));
                        });
                        startTimer();
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Begin Exposure'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuring(FearHierarchyItem task) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('During Exposure'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: Text(formatTime(elapsedTime))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(task.scenario, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SUDSSlider(value: currentSuds, onChanged: (v) => setState(() => currentSuds = v)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => readings.add(
                  SUDSReading(timestamp: DateTime.now(), value: currentSuds))),
              child: Text('Log SUDs (${readings.length})'),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: compulsionResisted,
              onChanged: (value) => setState(() => compulsionResisted = value ?? false),
              title: const Text('I resisted a compulsion'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => isTimerRunning = !isTimerRunning),
                    icon: Icon(isTimerRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(isTimerRunning ? 'Pause' : 'Resume'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isTimerRunning = false;
                        phase = SessionPhase.post;
                        postSuds = currentSuds;
                      });
                    },
                    child: const Text('End Exposure'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPost(FearHierarchyItem task, AppState appState) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post-Session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Session Complete!', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatTime(elapsedTime)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('What actually happened?'),
            const SizedBox(height: 8),
            TextField(
              controller: outcomeController,
              maxLines: 3,
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
            SUDSSlider(value: postSuds, onChanged: (v) => setState(() => postSuds = v)),
            const SizedBox(height: 16),
            const Text('What did you learn about uncertainty?'),
            const SizedBox(height: 8),
            TextField(
              controller: learningsController,
              maxLines: 3,
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
              child: ElevatedButton.icon(
                onPressed: () {
                  appState.addExposureSession(
                    hierarchyItemId: task.id,
                    exerciseType: task.exerciseType,
                    prediction: predictionController.text,
                    preSuds: preSuds,
                    duringReadings: readings,
                    postSuds: postSuds,
                    outcome: outcomeController.text,
                    learnings: learningsController.text,
                    compulsionResisted: compulsionResisted,
                    duration: elapsedTime,
                  );
                  appState.earnReward(ExerciseType.inVivo, 'Completed an exposure');
                  if (compulsionResisted) {
                    appState.earnReward(ExerciseType.inVivo, 'Resisted a compulsion', bonusAmount: 10);
                  }
                  appState.incrementStreak();
                  setState(() => phase = SessionPhase.complete);
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete & Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete(AppState appState) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Amazing Work!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'You faced your fear and learned something new.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mutedText),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => resetSessionState());
                  appState.setCurrentView(AppView.home);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
