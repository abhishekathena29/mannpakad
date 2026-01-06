import 'package:flutter/foundation.dart';

enum AppView {
  welcome,
  onboarding,
  avatarCreation,
  home,
  hierarchy,
  exposure,
  tracker,
  learn,
  rewards,
  settings,
  breathing,
  defusion,
  value,
  journaling,
  simulation,
  reflection,
  quickHelp,
}

enum AgeMode { younger, older }

enum OCDTheme {
  contamination,
  harm,
  checking,
  tabooThoughts,
  symmetry,
  perfectionism,
  relationship,
  health,
  existential,
  scrupulosity,
}

enum ADHDTrait {
  impulsivity,
  attentionIssues,
  executiveDysfunction,
  procrastination,
  emotionalDysregulation,
  timeBlindness,
  hyperfocus,
}

enum CoachingTone { gentle, direct, humorous, calm }

enum AvatarStyle { fox, owl, bear, rabbit, cat }

enum AvatarPersonality { coach, friend, mentor, cheerleader }

enum ExerciseType {
  inVivo,
  breathing,
  cognitiveDefusion,
  valuesClarification,
  journaling,
  simulation,
}

enum ExposureType { imaginal, inVivo, simulation }

enum AnxietyChange { stayedSame, increased, decreased, fluctuated }

enum ValueDomain {
  relationships,
  learning,
  kindness,
  independence,
  health,
  courage,
  creativity,
  authenticity,
}

enum LessonCategory {
  ocdBasics,
  erpBasics,
  inhibitoryLearning,
  distressTolerance,
  familyEducation,
}

enum QuickHelpType {
  urgeToCompulse,
  ruminating,
  overwhelmed,
  cantStart,
  needExposure,
  needGrounding,
}

@immutable
class UserProfile {
  final String id;
  final String name;
  final AgeMode ageMode;
  final List<OCDTheme> ocdThemes;
  final List<ADHDTrait> adhdTraits;
  final List<String> sensitivities;
  final CoachingTone coachingTone;
  final String? parentPin;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.ageMode,
    required this.ocdThemes,
    required this.adhdTraits,
    required this.sensitivities,
    required this.coachingTone,
    required this.createdAt,
    this.parentPin,
  });

  UserProfile copyWith({
    String? name,
    AgeMode? ageMode,
    List<OCDTheme>? ocdThemes,
    List<ADHDTrait>? adhdTraits,
    List<String>? sensitivities,
    CoachingTone? coachingTone,
    String? parentPin,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      ageMode: ageMode ?? this.ageMode,
      ocdThemes: ocdThemes ?? this.ocdThemes,
      adhdTraits: adhdTraits ?? this.adhdTraits,
      sensitivities: sensitivities ?? this.sensitivities,
      coachingTone: coachingTone ?? this.coachingTone,
      parentPin: parentPin ?? this.parentPin,
      createdAt: createdAt,
    );
  }
}

@immutable
class Avatar {
  final String id;
  final String name;
  final AvatarStyle style;
  final AvatarPersonality personality;
  final List<String> accessories;
  final String background;
  final int level;
  final int experience;

  const Avatar({
    required this.id,
    required this.name,
    required this.style,
    required this.personality,
    required this.accessories,
    required this.background,
    required this.level,
    required this.experience,
  });

  Avatar copyWith({
    String? name,
    AvatarStyle? style,
    AvatarPersonality? personality,
    List<String>? accessories,
    String? background,
    int? level,
    int? experience,
  }) {
    return Avatar(
      id: id,
      name: name ?? this.name,
      style: style ?? this.style,
      personality: personality ?? this.personality,
      accessories: accessories ?? this.accessories,
      background: background ?? this.background,
      level: level ?? this.level,
      experience: experience ?? this.experience,
    );
  }
}

@immutable
class FearHierarchyItem {
  final String id;
  final String scenario;
  final int suds;
  final ExposureType exposureType;
  final ExerciseType exerciseType;
  final int hierarchyLevel;
  final List<String> tags;
  final OCDTheme? ocdTheme;
  final bool completed;
  final int completedCount;
  final DateTime? lastCompletedAt;
  final DateTime createdAt;

  const FearHierarchyItem({
    required this.id,
    required this.scenario,
    required this.suds,
    required this.exposureType,
    required this.exerciseType,
    required this.hierarchyLevel,
    required this.tags,
    required this.completed,
    required this.completedCount,
    required this.createdAt,
    this.ocdTheme,
    this.lastCompletedAt,
  });

  FearHierarchyItem copyWith({
    String? scenario,
    int? suds,
    ExposureType? exposureType,
    ExerciseType? exerciseType,
    int? hierarchyLevel,
    List<String>? tags,
    OCDTheme? ocdTheme,
    bool? completed,
    int? completedCount,
    DateTime? lastCompletedAt,
  }) {
    return FearHierarchyItem(
      id: id,
      scenario: scenario ?? this.scenario,
      suds: suds ?? this.suds,
      exposureType: exposureType ?? this.exposureType,
      exerciseType: exerciseType ?? this.exerciseType,
      hierarchyLevel: hierarchyLevel ?? this.hierarchyLevel,
      tags: tags ?? this.tags,
      ocdTheme: ocdTheme ?? this.ocdTheme,
      completed: completed ?? this.completed,
      completedCount: completedCount ?? this.completedCount,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt,
    );
  }
}

@immutable
class TriggerLog {
  final String id;
  final String type;
  final String description;
  final String category;
  final int suds;
  final List<String> emotions;
  final List<String> physicalSensations;
  final List<String> compulsions;
  final String notes;
  final DateTime timestamp;

  const TriggerLog({
    required this.id,
    required this.type,
    required this.description,
    required this.category,
    required this.suds,
    required this.emotions,
    required this.physicalSensations,
    required this.compulsions,
    required this.notes,
    required this.timestamp,
  });
}

@immutable
class ReflectionLog {
  final String id;
  final String sessionId;
  final ExerciseType exerciseType;
  final String stepByStepDescription;
  final String hardestPart;
  final String wantedToStop;
  final String urgesNoticed;
  final String discomfortReducingActions;
  final String intentionallyAvoided;
  final String prediction;
  final String worstOutcomeWorried;
  final String actualOutcome;
  final String predictionNotTrue;
  final String surprising;
  final AnxietyChange anxietyChange;
  final String abilityToStay;
  final String discomfortHandling;
  final String urgesLearning;
  final String futureMessage;
  final DateTime createdAt;

  const ReflectionLog({
    required this.id,
    required this.sessionId,
    required this.exerciseType,
    required this.stepByStepDescription,
    required this.hardestPart,
    required this.wantedToStop,
    required this.urgesNoticed,
    required this.discomfortReducingActions,
    required this.intentionallyAvoided,
    required this.prediction,
    required this.worstOutcomeWorried,
    required this.actualOutcome,
    required this.predictionNotTrue,
    required this.surprising,
    required this.anxietyChange,
    required this.abilityToStay,
    required this.discomfortHandling,
    required this.urgesLearning,
    required this.futureMessage,
    required this.createdAt,
  });
}

@immutable
class SUDSReading {
  final DateTime timestamp;
  final int value;

  const SUDSReading({required this.timestamp, required this.value});
}

@immutable
class ExposureSession {
  final String id;
  final String hierarchyItemId;
  final ExerciseType exerciseType;
  final String prediction;
  final int preSuds;
  final List<SUDSReading> duringReadings;
  final int postSuds;
  final String outcome;
  final String learnings;
  final bool compulsionResisted;
  final int duration;
  final String? reflectionId;
  final DateTime completedAt;

  const ExposureSession({
    required this.id,
    required this.hierarchyItemId,
    required this.exerciseType,
    required this.prediction,
    required this.preSuds,
    required this.duringReadings,
    required this.postSuds,
    required this.outcome,
    required this.learnings,
    required this.compulsionResisted,
    required this.duration,
    required this.completedAt,
    this.reflectionId,
  });
}

@immutable
class BreathingSession {
  final String id;
  final int hierarchyLevel;
  final int duration;
  final String anxietyLocation;
  final String anxietySensation;
  final String anxietyEdges;
  final bool persisted;
  final String? reflectionId;
  final DateTime completedAt;

  const BreathingSession({
    required this.id,
    required this.hierarchyLevel,
    required this.duration,
    required this.anxietyLocation,
    required this.anxietySensation,
    required this.anxietyEdges,
    required this.persisted,
    required this.completedAt,
    this.reflectionId,
  });
}

@immutable
class DefusionSession {
  final String id;
  final String thought;
  final bool readExactly;
  final bool didNotNeutralize;
  final String coexistingLearning;
  final String futureResponse;
  final String? reflectionId;
  final DateTime completedAt;

  const DefusionSession({
    required this.id,
    required this.thought,
    required this.readExactly,
    required this.didNotNeutralize,
    required this.coexistingLearning,
    required this.futureResponse,
    required this.completedAt,
    this.reflectionId,
  });
}

@immutable
class ValuesEntry {
  final String id;
  final ValueDomain domain;
  final String ocdFreeActions;
  final String toleranceReason;
  final DateTime createdAt;

  const ValuesEntry({
    required this.id,
    required this.domain,
    required this.ocdFreeActions,
    required this.toleranceReason,
    required this.createdAt,
  });
}

@immutable
class WeeklyJournal {
  final String id;
  final DateTime weekOf;
  final String patternsAwareness;
  final String anxietyObservations;
  final String predictionsVsOutcomes;
  final String responseReflections;
  final String commitmentNextSteps;
  final DateTime createdAt;

  const WeeklyJournal({
    required this.id,
    required this.weekOf,
    required this.patternsAwareness,
    required this.anxietyObservations,
    required this.predictionsVsOutcomes,
    required this.responseReflections,
    required this.commitmentNextSteps,
    required this.createdAt,
  });
}

@immutable
class SimulationChoice {
  final DateTime timestamp;
  final String action;

  const SimulationChoice({required this.timestamp, required this.action});
}

@immutable
class SimulationSession {
  final String id;
  final String hierarchyItemId;
  final int hierarchyLevel;
  final List<SimulationChoice> choices;
  final int duration;
  final String? reflectionId;
  final DateTime completedAt;

  const SimulationSession({
    required this.id,
    required this.hierarchyItemId,
    required this.hierarchyLevel,
    required this.choices,
    required this.duration,
    required this.completedAt,
    this.reflectionId,
  });
}

@immutable
class UserProgress {
  final int totalCoins;
  final int currentStreak;
  final int longestStreak;
  final int totalExposures;
  final int compulsionsResisted;
  final int reflectionsCompleted;
  final int breathingSessions;
  final int defusionSessions;
  final int journalEntries;
  final List<String> milestones;
  final List<String> unlockedItems;

  const UserProgress({
    required this.totalCoins,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalExposures,
    required this.compulsionsResisted,
    required this.reflectionsCompleted,
    required this.breathingSessions,
    required this.defusionSessions,
    required this.journalEntries,
    required this.milestones,
    required this.unlockedItems,
  });

  UserProgress copyWith({
    int? totalCoins,
    int? currentStreak,
    int? longestStreak,
    int? totalExposures,
    int? compulsionsResisted,
    int? reflectionsCompleted,
    int? breathingSessions,
    int? defusionSessions,
    int? journalEntries,
    List<String>? milestones,
    List<String>? unlockedItems,
  }) {
    return UserProgress(
      totalCoins: totalCoins ?? this.totalCoins,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalExposures: totalExposures ?? this.totalExposures,
      compulsionsResisted: compulsionsResisted ?? this.compulsionsResisted,
      reflectionsCompleted: reflectionsCompleted ?? this.reflectionsCompleted,
      breathingSessions: breathingSessions ?? this.breathingSessions,
      defusionSessions: defusionSessions ?? this.defusionSessions,
      journalEntries: journalEntries ?? this.journalEntries,
      milestones: milestones ?? this.milestones,
      unlockedItems: unlockedItems ?? this.unlockedItems,
    );
  }
}

const Map<ExerciseType, Map<AgeMode, int>> rewardValues = {
  ExerciseType.inVivo: {AgeMode.younger: 30, AgeMode.older: 30},
  ExerciseType.breathing: {AgeMode.younger: 15, AgeMode.older: 15},
  ExerciseType.cognitiveDefusion: {AgeMode.younger: 20, AgeMode.older: 20},
  ExerciseType.valuesClarification: {AgeMode.younger: 10, AgeMode.older: 10},
  ExerciseType.journaling: {AgeMode.younger: 25, AgeMode.older: 25},
  ExerciseType.simulation: {AgeMode.younger: 20, AgeMode.older: 20},
};

@immutable
class Lesson {
  final String id;
  final String title;
  final LessonCategory category;
  final String content;
  final int duration;
  final bool completed;
  final String icon;

  const Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.duration,
    required this.completed,
    required this.icon,
  });
}

extension AvatarStyleEmoji on AvatarStyle {
  String get emoji {
    switch (this) {
      case AvatarStyle.fox:
        return '🦊';
      case AvatarStyle.owl:
        return '🦉';
      case AvatarStyle.bear:
        return '🐻';
      case AvatarStyle.rabbit:
        return '🐰';
      case AvatarStyle.cat:
        return '🐱';
    }
  }
}

extension ExerciseTypeLabel on ExerciseType {
  String get label {
    switch (this) {
      case ExerciseType.inVivo:
        return 'In Vivo';
      case ExerciseType.breathing:
        return 'Breathing';
      case ExerciseType.cognitiveDefusion:
        return 'Cognitive Defusion';
      case ExerciseType.valuesClarification:
        return 'Values';
      case ExerciseType.journaling:
        return 'Journaling';
      case ExerciseType.simulation:
        return 'Simulation';
    }
  }
}
