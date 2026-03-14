import 'package:flutter/material.dart';
import 'package:mannpakad/core/models/app_models.dart';

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

class AppState extends ChangeNotifier {
  bool isOnboarded = false;
  UserProfile? userProfile;
  Avatar? avatar;
  List<FearHierarchyItem> fearHierarchy = [];
  List<TriggerLog> triggerLogs = [];
  List<ExposureSession> exposureSessions = [];
  List<AIExposureSession> aiExposureSessions = [];
  List<ReflectionLog> reflectionLogs = [];
  List<BreathingSession> breathingSessions = [];
  List<DefusionSession> defusionSessions = [];
  List<ValuesEntry> valuesEntries = [];
  List<WeeklyJournal> weeklyJournals = [];
  List<SimulationSession> simulationSessions = [];
  UserProgress progress = const UserProgress(
    totalCoins: 0,
    currentStreak: 0,
    longestStreak: 0,
    totalExposures: 0,
    compulsionsResisted: 0,
    reflectionsCompleted: 0,
    breathingSessions: 0,
    defusionSessions: 0,
    journalEntries: 0,
    milestones: [],
    unlockedItems: [],
  );
  AppView currentView = AppView.welcome;
  ExerciseType? activeExercise;

  void setCurrentView(AppView view) {
    currentView = view;
    notifyListeners();
  }

  void setActiveExercise(ExerciseType? exercise) {
    activeExercise = exercise;
    notifyListeners();
  }

  void completeOnboarding({
    required String name,
    required AgeMode ageMode,
    required List<OCDTheme> ocdThemes,
    required List<ADHDTrait> adhdTraits,
    required List<String> sensitivities,
    required CoachingTone coachingTone,
    String? id,
    DateTime? createdAt,
  }) {
    userProfile = UserProfile(
      id: id ?? _newId(),
      name: name.isEmpty ? 'Friend' : name,
      ageMode: ageMode,
      ocdThemes: ocdThemes,
      adhdTraits: adhdTraits,
      sensitivities: sensitivities,
      coachingTone: coachingTone,
      createdAt: createdAt ?? DateTime.now(),
    );
    currentView = AppView.avatarCreation;
    notifyListeners();
  }

  void setAvatar({
    required String name,
    required AvatarStyle style,
    required AvatarPersonality personality,
    required String background,
    String? id,
    int level = 1,
    int experience = 0,
  }) {
    avatar = Avatar(
      id: id ?? _newId(),
      name: name.isEmpty ? 'Buddy' : name,
      style: style,
      personality: personality,
      accessories: const [],
      background: background,
      level: level,
      experience: experience,
    );
    isOnboarded = true;
    currentView = AppView.home;
    notifyListeners();
  }

  void hydrateSession({required UserProfile profile, Avatar? avatar}) {
    userProfile = profile;
    this.avatar = avatar;
    isOnboarded = avatar != null;
    currentView = avatar == null ? AppView.avatarCreation : AppView.home;
    notifyListeners();
  }

  void addFearItem({
    required String scenario,
    required int suds,
    required ExposureType exposureType,
    required ExerciseType exerciseType,
    required int hierarchyLevel,
  }) {
    final item = FearHierarchyItem(
      id: _newId(),
      scenario: scenario,
      suds: suds,
      exposureType: exposureType,
      exerciseType: exerciseType,
      hierarchyLevel: hierarchyLevel,
      tags: const [],
      completed: false,
      completedCount: 0,
      createdAt: DateTime.now(),
    );
    fearHierarchy = [...fearHierarchy, item]
      ..sort((a, b) => a.suds.compareTo(b.suds));
    notifyListeners();
  }

  void updateFearItem(String id, FearHierarchyItem item) {
    fearHierarchy =
        fearHierarchy.map((entry) => entry.id == id ? item : entry).toList()
          ..sort((a, b) => a.suds.compareTo(b.suds));
    notifyListeners();
  }

  void toggleFearItemCompletion(String id) {
    fearHierarchy = fearHierarchy
        .map(
          (entry) => entry.id == id
              ? entry.copyWith(
                  completed: !entry.completed,
                  lastCompletedAt: entry.completed
                      ? entry.lastCompletedAt
                      : DateTime.now(),
                )
              : entry,
        )
        .toList();
    notifyListeners();
  }

  void deleteFearItem(String id) {
    fearHierarchy = fearHierarchy.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void addTriggerLog({
    required String type,
    required String description,
    required String category,
    required int suds,
    required List<String> emotions,
    required List<String> physicalSensations,
    required List<String> compulsions,
    required String notes,
  }) {
    final log = TriggerLog(
      id: _newId(),
      type: type,
      description: description,
      category: category,
      suds: suds,
      emotions: emotions,
      physicalSensations: physicalSensations,
      compulsions: compulsions,
      notes: notes,
      timestamp: DateTime.now(),
    );
    triggerLogs = [log, ...triggerLogs];
    notifyListeners();
  }

  void addAIExposureSession({
    required AIExposureTask task,
    required int preSuds,
    required int postSuds,
    required Map<String, String> reflectionResponses,
    required int duration,
  }) {
    final session = AIExposureSession(
      id: _newId(),
      task: task,
      preSuds: preSuds,
      postSuds: postSuds,
      reflectionResponses: reflectionResponses,
      duration: duration,
      completed: true,
      createdAt: DateTime.now(),
    );
    aiExposureSessions = [session, ...aiExposureSessions];
    progress = progress.copyWith(totalExposures: progress.totalExposures + 1);
    notifyListeners();
  }

  void addExposureSession({
    required String hierarchyItemId,
    required ExerciseType exerciseType,
    required String prediction,
    required int preSuds,
    required List<SUDSReading> duringReadings,
    required int postSuds,
    required String outcome,
    required String learnings,
    required bool compulsionResisted,
    required int duration,
  }) {
    final session = ExposureSession(
      id: _newId(),
      hierarchyItemId: hierarchyItemId,
      exerciseType: exerciseType,
      prediction: prediction,
      preSuds: preSuds,
      duringReadings: duringReadings,
      postSuds: postSuds,
      outcome: outcome,
      learnings: learnings,
      compulsionResisted: compulsionResisted,
      duration: duration,
      completedAt: DateTime.now(),
    );
    exposureSessions = [session, ...exposureSessions];
    _recordHierarchyProgress(hierarchyItemId);
    progress = progress.copyWith(
      totalExposures: progress.totalExposures + 1,
      compulsionsResisted: compulsionResisted
          ? progress.compulsionsResisted + 1
          : progress.compulsionsResisted,
    );
    notifyListeners();
  }

  void addReflectionLog({
    required String sessionId,
    required ExerciseType exerciseType,
    required String stepByStepDescription,
    required String hardestPart,
    required String wantedToStop,
    required String urgesNoticed,
    required String discomfortReducingActions,
    required String intentionallyAvoided,
    required String prediction,
    required String worstOutcomeWorried,
    required String actualOutcome,
    required String predictionNotTrue,
    required String surprising,
    required AnxietyChange anxietyChange,
    required String abilityToStay,
    required String discomfortHandling,
    required String urgesLearning,
    required String futureMessage,
  }) {
    final log = ReflectionLog(
      id: _newId(),
      sessionId: sessionId,
      exerciseType: exerciseType,
      stepByStepDescription: stepByStepDescription,
      hardestPart: hardestPart,
      wantedToStop: wantedToStop,
      urgesNoticed: urgesNoticed,
      discomfortReducingActions: discomfortReducingActions,
      intentionallyAvoided: intentionallyAvoided,
      prediction: prediction,
      worstOutcomeWorried: worstOutcomeWorried,
      actualOutcome: actualOutcome,
      predictionNotTrue: predictionNotTrue,
      surprising: surprising,
      anxietyChange: anxietyChange,
      abilityToStay: abilityToStay,
      discomfortHandling: discomfortHandling,
      urgesLearning: urgesLearning,
      futureMessage: futureMessage,
      createdAt: DateTime.now(),
    );
    reflectionLogs = [log, ...reflectionLogs];
    progress = progress.copyWith(
      reflectionsCompleted: progress.reflectionsCompleted + 1,
    );
    notifyListeners();
  }

  void addBreathingSession({
    required int hierarchyLevel,
    required int duration,
    required String anxietyLocation,
    required String anxietySensation,
    required String anxietyEdges,
    required bool persisted,
  }) {
    final session = BreathingSession(
      id: _newId(),
      hierarchyLevel: hierarchyLevel,
      duration: duration,
      anxietyLocation: anxietyLocation,
      anxietySensation: anxietySensation,
      anxietyEdges: anxietyEdges,
      persisted: persisted,
      completedAt: DateTime.now(),
    );
    breathingSessions = [session, ...breathingSessions];
    progress = progress.copyWith(
      breathingSessions: progress.breathingSessions + 1,
    );
    notifyListeners();
  }

  void addDefusionSession({
    required String thought,
    required bool readExactly,
    required bool didNotNeutralize,
    required String coexistingLearning,
    required String futureResponse,
  }) {
    final session = DefusionSession(
      id: _newId(),
      thought: thought,
      readExactly: readExactly,
      didNotNeutralize: didNotNeutralize,
      coexistingLearning: coexistingLearning,
      futureResponse: futureResponse,
      completedAt: DateTime.now(),
    );
    defusionSessions = [session, ...defusionSessions];
    progress = progress.copyWith(
      defusionSessions: progress.defusionSessions + 1,
    );
    notifyListeners();
  }

  void addValuesEntry({
    required ValueDomain domain,
    required String ocdFreeActions,
    required String toleranceReason,
  }) {
    final entry = ValuesEntry(
      id: _newId(),
      domain: domain,
      ocdFreeActions: ocdFreeActions,
      toleranceReason: toleranceReason,
      createdAt: DateTime.now(),
    );
    valuesEntries = [entry, ...valuesEntries];
    notifyListeners();
  }

  void addWeeklyJournal({
    required String patternsAwareness,
    required String anxietyObservations,
    required String predictionsVsOutcomes,
    required String responseReflections,
    required String commitmentNextSteps,
  }) {
    final journal = WeeklyJournal(
      id: _newId(),
      weekOf: DateTime.now(),
      patternsAwareness: patternsAwareness,
      anxietyObservations: anxietyObservations,
      predictionsVsOutcomes: predictionsVsOutcomes,
      responseReflections: responseReflections,
      commitmentNextSteps: commitmentNextSteps,
      createdAt: DateTime.now(),
    );
    weeklyJournals = [journal, ...weeklyJournals];
    progress = progress.copyWith(journalEntries: progress.journalEntries + 1);
    notifyListeners();
  }

  void addSimulationSession({
    required String hierarchyItemId,
    required int hierarchyLevel,
    required List<SimulationChoice> choices,
    required int duration,
  }) {
    final session = SimulationSession(
      id: _newId(),
      hierarchyItemId: hierarchyItemId,
      hierarchyLevel: hierarchyLevel,
      choices: choices,
      duration: duration,
      completedAt: DateTime.now(),
    );
    simulationSessions = [session, ...simulationSessions];
    _recordHierarchyProgress(hierarchyItemId);
    notifyListeners();
  }

  int getRewardAmount(ExerciseType exerciseType) {
    final ageMode = userProfile?.ageMode ?? AgeMode.older;
    return rewardValues[exerciseType]?[ageMode] ?? 0;
  }

  String getRewardLabel() {
    final ageMode = userProfile?.ageMode ?? AgeMode.older;
    return ageMode == AgeMode.younger ? 'coins' : 'credits';
  }

  void earnReward(
    ExerciseType exerciseType,
    String reason, {
    int bonusAmount = 0,
  }) {
    final baseAmount = getRewardAmount(exerciseType);
    progress = progress.copyWith(
      totalCoins: progress.totalCoins + baseAmount + bonusAmount,
    );
    notifyListeners();
  }

  void incrementStreak() {
    final newStreak = progress.currentStreak + 1;
    progress = progress.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > progress.longestStreak
          ? newStreak
          : progress.longestStreak,
    );
    notifyListeners();
  }

  void resetApp() {
    isOnboarded = false;
    userProfile = null;
    avatar = null;
    fearHierarchy = [];
    triggerLogs = [];
    exposureSessions = [];
    aiExposureSessions = [];
    reflectionLogs = [];
    breathingSessions = [];
    defusionSessions = [];
    valuesEntries = [];
    weeklyJournals = [];
    simulationSessions = [];
    progress = const UserProgress(
      totalCoins: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalExposures: 0,
      compulsionsResisted: 0,
      reflectionsCompleted: 0,
      breathingSessions: 0,
      defusionSessions: 0,
      journalEntries: 0,
      milestones: [],
      unlockedItems: [],
    );
    currentView = AppView.welcome;
    activeExercise = null;
    notifyListeners();
  }

  void _recordHierarchyProgress(String hierarchyItemId) {
    if (hierarchyItemId.isEmpty) {
      return;
    }
    final index = fearHierarchy.indexWhere(
      (item) => item.id == hierarchyItemId,
    );
    if (index == -1) {
      return;
    }
    final item = fearHierarchy[index];
    final updated = item.copyWith(
      completedCount: item.completedCount + 1,
      completed: true,
      lastCompletedAt: DateTime.now(),
    );
    final updatedList = [...fearHierarchy];
    updatedList[index] = updated;
    updatedList.sort((a, b) => a.suds.compareTo(b.suds));
    fearHierarchy = updatedList;
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('AppStateScope not found in widget tree');
    }
    return scope.notifier!;
  }
}
