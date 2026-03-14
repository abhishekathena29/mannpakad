import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/features/ai_exposure/services/gemini_service.dart';
import 'package:mannpakad/shared/widgets/suds_slider.dart';

enum AIExposurePhase {
  loading,
  noApiKey,
  distressSelection,
  generating,
  taskList,
  taskExecution,
  reflectionGeneration,
  reflection,
  complete,
}

class AIExposureScreen extends StatefulWidget {
  const AIExposureScreen({super.key});

  @override
  State<AIExposureScreen> createState() => _AIExposureScreenState();
}

class _AIExposureScreenState extends State<AIExposureScreen> {
  AIExposurePhase phase = AIExposurePhase.loading;
  final GeminiService _geminiService = GeminiService();

  // Loading state
  bool isLoading = true;
  String? errorMessage;

  // Distress Selection
  int selectedSuds = 50;
  ExerciseType selectedExerciseType = ExerciseType.inVivo;

  // Generated content
  List<AIExposureTask> generatedTasks = [];
  AIExposureTask? selectedTask;
  List<AIReflectionQuestion> reflectionQuestions = [];

  // Task execution
  int preSuds = 50;
  int elapsedTime = 0;
  Timer? timer;
  bool isTimerRunning = false;

  // Reflection
  Map<String, String> reflectionResponses = {};
  int currentQuestionIndex = 0;
  final reflectionController = TextEditingController();
  String? selectedMcqOption;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    reflectionController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeService() async {
    setState(() {
      isLoading = true;
      phase = AIExposurePhase.loading;
    });

    try {
      final hasKey = await _geminiService.initialize();
      setState(() {
        isLoading = false;
        if (hasKey) {
          phase = AIExposurePhase.distressSelection;
        } else {
          phase = AIExposurePhase.noApiKey;
          errorMessage =
              'Gemini API key not found in Firebase Realtime Database. Please add it to "config/gemini/api_key".';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        phase = AIExposurePhase.noApiKey;
        errorMessage = 'Error initializing AI service: $e';
      });
    }
  }

  Future<void> _generateTasks() async {
    final appState = AppStateScope.of(context);
    setState(() {
      phase = AIExposurePhase.generating;
      errorMessage = null;
    });

    try {
      final ocdTheme = appState.userProfile?.ocdThemes.isNotEmpty == true
          ? appState.userProfile!.ocdThemes.first
          : OCDTheme.contamination;

      final tasks = await _geminiService.generateExposureTasks(
        ocdTheme: ocdTheme,
        sudsLevel: selectedSuds,
        exerciseType: selectedExerciseType,
        count: 5,
      );

      setState(() {
        generatedTasks = tasks;
        phase = AIExposurePhase.taskList;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to generate tasks: $e';
        phase = AIExposurePhase.distressSelection;
      });
    }
  }

  void _startTask(AIExposureTask task) {
    setState(() {
      selectedTask = task;
      preSuds = task.sudsLevel;
      phase = AIExposurePhase.taskExecution;
      elapsedTime = 0;
      isTimerRunning = true;
    });
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isTimerRunning) return;
      setState(() => elapsedTime += 1);
    });
  }

  Future<void> _completeTask() async {
    timer?.cancel();
    setState(() {
      isTimerRunning = false;
      phase = AIExposurePhase.reflectionGeneration;
    });

    try {
      final questions = await _geminiService.generateReflectionQuestions(
        taskDescription: selectedTask!.description,
        exerciseType: selectedTask!.exerciseType,
      );

      setState(() {
        reflectionQuestions = questions;
        currentQuestionIndex = 0;
        phase = AIExposurePhase.reflection;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to generate reflection questions: $e';
        phase = AIExposurePhase.complete;
      });
    }
  }

  void _nextQuestion() {
    final currentQ = reflectionQuestions[currentQuestionIndex];

    // Save current response
    if (currentQ.type == QuestionType.mcq) {
      if (selectedMcqOption != null) {
        reflectionResponses[currentQ.id] = selectedMcqOption!;
      }
    } else {
      if (reflectionController.text.isNotEmpty) {
        reflectionResponses[currentQ.id] = reflectionController.text;
      }
    }

    // Move to next or complete
    if (currentQuestionIndex < reflectionQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        reflectionController.clear();
        selectedMcqOption = null;
      });
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    final appState = AppStateScope.of(context);

    // Award credits
    appState.earnReward(ExerciseType.inVivo, 'Completed AI-guided exposure');
    appState.incrementStreak();

    setState(() {
      phase = AIExposurePhase.complete;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString()}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getSudsColor(int suds) {
    if (suds <= 30) return AppColors.success;
    if (suds <= 50) return AppColors.warning;
    if (suds <= 70) return AppColors.accent;
    return AppColors.error;
  }

  String _getSudsLabel(int suds) {
    if (suds <= 20) return 'Minimal Distress';
    if (suds <= 40) return 'Mild Distress';
    if (suds <= 60) return 'Moderate Distress';
    if (suds <= 80) return 'High Distress';
    return 'Extreme Distress';
  }

  Widget _buildGradientScaffold({
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
    switch (phase) {
      case AIExposurePhase.loading:
        return _buildLoading();
      case AIExposurePhase.noApiKey:
        return _buildNoApiKey();
      case AIExposurePhase.distressSelection:
        return _buildDistressSelection();
      case AIExposurePhase.generating:
        return _buildGenerating();
      case AIExposurePhase.taskList:
        return _buildTaskList();
      case AIExposurePhase.taskExecution:
        return _buildTaskExecution();
      case AIExposurePhase.reflectionGeneration:
        return _buildReflectionGenerating();
      case AIExposurePhase.reflection:
        return _buildReflection();
      case AIExposurePhase.complete:
        return _buildComplete();
    }
  }

  Widget _buildLoading() {
    return _buildGradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientPrimary),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Initializing AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connecting to Gemini...',
              style: TextStyle(color: Colors.white.withAlpha(180)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoApiKey() {
    final appState = AppStateScope.of(context);

    return _buildGradientScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.key_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'API Key Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: Text(
                errorMessage ?? 'Please add Gemini API key to RTDB.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(200)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Setup Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Go to Firebase Console > Realtime Database\n2. Create path: "config/gemini/api_key"\n3. Set value to your Gemini API Key string',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => appState.setCurrentView(AppView.home),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withAlpha(100)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _initializeService,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistressSelection() {
    final appState = AppStateScope.of(context);

    return _buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('AI Exposure', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getSudsColor(selectedSuds).withAlpha(40),
                    _getSudsColor(selectedSuds).withAlpha(10),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getSudsColor(selectedSuds).withAlpha(80),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      selectedSuds.toString(),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: _getSudsColor(selectedSuds),
                      ),
                    ),
                    Text(
                      _getSudsLabel(selectedSuds),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getSudsColor(selectedSuds),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Distress Level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how challenging you want your exposure tasks to be',
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
            const SizedBox(height: 24),
            SUDSSlider(
              value: selectedSuds,
              onChanged: (v) => setState(() => selectedSuds = v),
            ),
            const SizedBox(height: 32),
            const Text(
              'Exercise Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    ExerciseType.inVivo,
                    ExerciseType.cognitiveDefusion,
                    ExerciseType.breathing,
                    ExerciseType.simulation,
                  ].map((type) {
                    final selected = selectedExerciseType == type;
                    return ChoiceChip(
                      label: Text(type.label),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => selectedExerciseType = type),
                      selectedColor: AppColors.primary.withAlpha(200),
                      // disabledColor: AppColors.primary.withAlpha(200),
                      // backgroundColor: Colors.white.withAlpha(20),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateTasks,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Generate Tasks'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return _buildGradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientPrimary),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Creating Your Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI is crafting personalized exposures...',
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return _buildGradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              setState(() => phase = AIExposurePhase.distressSelection),
        ),
        title: const Text(
          'Choose a Task',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getSudsColor(selectedSuds).withAlpha(30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getSudsColor(selectedSuds).withAlpha(50),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, color: _getSudsColor(selectedSuds)),
                const SizedBox(width: 12),
                Text(
                  'SUDs Level: $selectedSuds',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getSudsColor(selectedSuds),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: generatedTasks.length,
              itemBuilder: (context, index) {
                final task = generatedTasks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _startTask(task),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(50),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    task.duration,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withAlpha(200),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              task.description,
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.calm.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    size: 18,
                                    color: AppColors.calm,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      task.purpose,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.calmLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskExecution() {
    final task = selectedTask!;

    return _buildGradientScaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text(task.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  _formatTime(elapsedTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      task.description,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Steps to Follow',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...task.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(10)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.calm.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.calm.withAlpha(50)),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.spa, color: AppColors.calmLight),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Remember',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.calmLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The goal is learning to tolerate uncertainty, not to feel less anxious. Stay with the discomfort.',
                    style: TextStyle(color: Colors.white.withAlpha(200)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => isTimerRunning = !isTimerRunning),
                    icon: Icon(isTimerRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(isTimerRunning ? 'Pause' : 'Resume'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withAlpha(100)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _completeTask,
                    icon: const Icon(Icons.check),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionGenerating() {
    return _buildGradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Preparing Reflection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Creating personalized questions...',
              style: TextStyle(color: Colors.white.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflection() {
    if (reflectionQuestions.isEmpty) {
      return _buildComplete();
    }

    final question = reflectionQuestions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / reflectionQuestions.length;

    return _buildGradientScaffold(
      appBar: AppBar(
        title: const Text('Reflection', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${currentQuestionIndex + 1}/${reflectionQuestions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withAlpha(30),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(50),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withAlpha(100)),
              ),
              child: Text(
                _getCategoryLabel(question.category),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            if (question.type == QuestionType.mcq &&
                question.options != null) ...[
              ...question.options!.map((option) {
                final isSelected = selectedMcqOption == option;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isSelected
                        ? AppColors.primaryLight
                        : Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => setState(() => selectedMcqOption = option),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white54,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              TextField(
                controller: reflectionController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts here...',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  currentQuestionIndex < reflectionQuestions.length - 1
                      ? 'Next Question'
                      : 'Complete Reflection',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(ReflectionCategory category) {
    switch (category) {
      case ReflectionCategory.taskEngagement:
        return 'Task Engagement';
      case ReflectionCategory.responsePrevention:
        return 'Response Prevention';
      case ReflectionCategory.inhibitoryLearning:
        return 'Inhibitory Learning';
      case ReflectionCategory.habituation:
        return 'Habituation';
      case ReflectionCategory.learningConsolidation:
        return 'Learning Consolidation';
    }
  }

  Widget _buildComplete() {
    final appState = AppStateScope.of(context);

    return _buildGradientScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.gradientPrimary),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(100),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 32),
              const Text(
                'Outstanding Work!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You faced your fears and reflected on the experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.calm.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.calm.withAlpha(50)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      size: 40,
                      color: AppColors.calmLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Neuroplasticity in Action',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.calmLight,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every exposure rewires your brain to tolerate uncertainty better.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withAlpha(200)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      phase = AIExposurePhase.distressSelection;
                      generatedTasks = [];
                      selectedTask = null;
                      reflectionQuestions = [];
                      reflectionResponses = {};
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Another Task'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => appState.setCurrentView(AppView.home),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
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
