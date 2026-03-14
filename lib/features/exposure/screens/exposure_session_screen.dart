import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/shared/widgets/suds_slider.dart';

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
    final selectedTask = _resolveSelectedTask(appState);
    final task =
        selectedTask ??
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
    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text(
          'Start Exposure',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Choose an exposure task to practice',
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: appState.fearHierarchy.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No exposure tasks yet.',
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                appState.setCurrentView(AppView.hierarchy),
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
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withAlpha(50)
                                : Colors.white.withAlpha(10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white.withAlpha(10),
                            ),
                          ),
                          child: ListTile(
                            onTap: () =>
                                setState(() => selectedTaskId = item.id),
                            title: Text(
                              item.scenario,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Level ${item.hierarchyLevel} · SUDs ${item.suds} · ${item.exposureType.name} · ${item.completedCount}x',
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                              ),
                            ),
                            trailing: selected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  )
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

  Widget _buildPre(FearHierarchyItem task) {
    return buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => phase = SessionPhase.select),
        ),
        title: const Text('Pre-Session', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.primaryLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.scenario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What do you predict will happen?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: predictionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                hintText: 'My anxiety will explode and...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SUDSSlider(
              value: preSuds,
              onChanged: (v) => setState(() => preSuds = v),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.calm.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Remember: the goal is learning, not feeling less anxious.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
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
                          readings.add(
                            SUDSReading(
                              timestamp: DateTime.now(),
                              value: preSuds,
                            ),
                          );
                        });
                        startTimer();
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Begin Exposure'),
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

  Widget _buildDuring(FearHierarchyItem task) {
    return buildGradientScaffold(
      appBar: AppBar(
        title: const Text(
          'During Exposure',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              formatTime(elapsedTime),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              task.scenario,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            SUDSSlider(
              value: currentSuds,
              onChanged: (v) => setState(() => currentSuds = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(
                () => readings.add(
                  SUDSReading(timestamp: DateTime.now(), value: currentSuds),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(20),
                foregroundColor: Colors.white,
              ),
              child: Text('Log SUDs (${readings.length})'),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                value: compulsionResisted,
                onChanged: (value) =>
                    setState(() => compulsionResisted = value ?? false),
                title: const Text(
                  'I resisted a compulsion',
                  style: TextStyle(color: Colors.white),
                ),
                checkColor: AppColors.primary,
                activeColor: Colors.white,
                tileColor: Colors.transparent,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => isTimerRunning = !isTimerRunning),
                    icon: Icon(
                      isTimerRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      isTimerRunning ? 'Pause' : 'Resume',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withAlpha(50)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isTimerRunning = false;
                        phase = SessionPhase.post;
                        postSuds = currentSuds;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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
    return buildGradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Post-Session',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Session Complete!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    formatTime(elapsedTime),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What actually happened?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: outcomeController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SUDSSlider(
              value: postSuds,
              onChanged: (v) => setState(() => postSuds = v),
            ),
            const SizedBox(height: 24),
            const Text(
              'What did you learn about uncertainty?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: learningsController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
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
                  appState.earnReward(
                    ExerciseType.inVivo,
                    'Completed an exposure',
                  );
                  if (compulsionResisted) {
                    appState.earnReward(
                      ExerciseType.inVivo,
                      'Resisted a compulsion',
                      bonusAmount: 10,
                    );
                  }
                  appState.incrementStreak();
                  setState(() => phase = SessionPhase.complete);
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete & Save'),
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

  Widget _buildComplete(AppState appState) {
    return buildGradientScaffold(
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
              const SizedBox(height: 24),
              const Text(
                'Amazing Work!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You faced your fear and learned something new.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(180)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => resetSessionState());
                    appState.setCurrentView(AppView.home);
                  },
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
}
