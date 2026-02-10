import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  static const String _rtdbPath = 'config/gemini/api_key';

  GenerativeModel? _model;
  String? _apiKey;
  bool _isInitialized = false;

  /// Initialize service by fetching API key from Firebase Realtime Database
  Future<bool> initialize() async {
    if (_isInitialized && _apiKey != null) {
      return true;
    }

    try {
      final ref = FirebaseDatabase.instance.ref(_rtdbPath);
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        _apiKey = snapshot.value as String?;
        if (_apiKey != null && _apiKey!.isNotEmpty) {
          _isInitialized = true;
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error fetching Gemini API key from RTDB: $e');
      return false;
    }
  }

  /// Check if API key is available
  Future<bool> hasApiKey() async {
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      return true;
    }
    return await initialize();
  }

  /// Get current API key
  String? getApiKey() {
    return _apiKey;
  }

  /// Save API key to RTDB (for admin use)
  Future<void> setApiKey(String apiKey) async {
    try {
      final ref = FirebaseDatabase.instance.ref(_rtdbPath);
      await ref.set(apiKey);

      _apiKey = apiKey;
      _model = null; // Reset model to use new key
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to save API key to RTDB: $e');
    }
  }

  GenerativeModel _getModel() {
    if (_model != null) return _model!;
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception(
        'Gemini API key not configured. Please add the key to RTDB at config/gemini/api_key.',
      );
    }
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
    return _model!;
  }

  Future<List<AIExposureTask>> generateExposureTasks({
    required OCDTheme ocdTheme,
    required int sudsLevel,
    required ExerciseType exerciseType,
    int count = 5,
  }) async {
    // Ensure initialized before generating
    if (!_isInitialized) {
      await initialize();
    }

    final model = _getModel();

    final durationGuidance = _getDurationGuidance(sudsLevel);
    final ocdContext = _getOCDContext(ocdTheme);
    final exerciseContext = _getExerciseContext(exerciseType);

    final prompt =
        '''
You are an ERP (Exposure and Response Prevention) therapy assistant specializing in OCD treatment.

Generate $count exposure tasks for a user with ${ocdTheme.name} OCD at SUDs (Subjective Units of Distress) level $sudsLevel/100.

OCD Context: $ocdContext

Exercise Type: $exerciseContext

Clinical Guidelines for SUDs Level $sudsLevel:
$durationGuidance

CRITICAL ETHICAL RULES:
- Tasks must focus on learning to tolerate uncertainty, NOT proving fears wrong
- Never suggest tasks that could actually cause harm
- Tasks should prevent the compulsion that maintains the fear
- Focus on inhibitory learning (new associations) not habituation

For each task provide a JSON object with:
- "id": unique identifier (use format "task_1", "task_2", etc.)
- "title": Short task name (max 50 chars)
- "description": What the user will do (1-2 sentences)
- "purpose": Why this helps using ERP principles (1 sentence)
- "duration": "${_getDurationLabel(sudsLevel)}"
- "steps": Array of 3-5 step-by-step instructions

Return ONLY a valid JSON array of task objects. No markdown, no explanation.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from Gemini');

      // Clean response - remove markdown code blocks if present
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      final List<dynamic> jsonList = json.decode(cleanedText);
      return jsonList
          .map(
            (item) => AIExposureTask(
              id: item['id'] ?? 'task_${DateTime.now().millisecondsSinceEpoch}',
              title: item['title'] ?? 'Exposure Task',
              description: item['description'] ?? '',
              purpose: item['purpose'] ?? '',
              sudsLevel: sudsLevel,
              exerciseType: exerciseType,
              ocdTheme: ocdTheme,
              duration: item['duration'] ?? 'moderate',
              steps: List<String>.from(item['steps'] ?? []),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to generate tasks: $e');
    }
  }

  Future<List<AIReflectionQuestion>> generateReflectionQuestions({
    required String taskDescription,
    required ExerciseType exerciseType,
  }) async {
    // Ensure initialized before generating
    if (!_isInitialized) {
      await initialize();
    }

    final model = _getModel();

    final prompt =
        '''
You are an ERP therapy assistant generating reflection questions after an exposure task.

The user just completed this task: "$taskDescription"

Generate 6-8 reflection questions following these STRICT clinical guidelines:

CATEGORIES (include at least one from each):
1. TASK_ENGAGEMENT: Verify the user attempted the task (non-accusatory, supportive)
   Example: "Describe what you did during this task, step by step."
   
2. RESPONSE_PREVENTION: Check if user resisted compulsions
   Example: "Did you notice any urges to neutralize, check, or 'fix' the situation?"
   
3. INHIBITORY_LEARNING: Explore expectancy violation (predictions vs reality)
   Example: "What did you expect would happen? What actually happened?"
   
4. HABITUATION: Observe anxiety patterns (without rewarding reduction)
   Example: "How did your anxiety change over time, if at all?"
   
5. LEARNING_CONSOLIDATION: Solidify new learning about tolerance
   Example: "What does this experience suggest about your ability to handle discomfort?"

CRITICAL - NEVER ASK:
- "Do you feel better now?" (encourages reassurance-seeking)
- "Was your fear proven wrong?" (undermines uncertainty tolerance)
- "Are you safe?" (provides reassurance)
- "Did nothing bad happen?" (seeks confirmation)

For each question provide a JSON object with:
- "id": unique identifier (e.g., "q_1")
- "question": The reflection question
- "category": One of "taskEngagement", "responsePrevention", "inhibitoryLearning", "habituation", "learningConsolidation"
- "type": "shortAnswer" or "mcq"
- "isRequired": true or false
- "options": Array of options if type is "mcq", null otherwise

Return ONLY a valid JSON array. No markdown, no explanation.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from Gemini');

      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      final List<dynamic> jsonList = json.decode(cleanedText);
      return jsonList
          .map(
            (item) => AIReflectionQuestion(
              id: item['id'] ?? 'q_${DateTime.now().millisecondsSinceEpoch}',
              question: item['question'] ?? '',
              category: _parseReflectionCategory(item['category']),
              type: item['type'] == 'mcq'
                  ? QuestionType.mcq
                  : QuestionType.shortAnswer,
              isRequired: item['isRequired'] ?? true,
              options: item['options'] != null
                  ? List<String>.from(item['options'])
                  : null,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to generate reflection questions: $e');
    }
  }

  String _getDurationGuidance(int suds) {
    if (suds >= 80) {
      return '''- Very brief exposure (10-30 seconds)
- High intensity, short duration
- Focus on surviving the spike''';
    } else if (suds >= 60) {
      return '''- Short exposure (30 seconds - 2 minutes)
- Moderate-high intensity
- Practice non-engagement with urges''';
    } else if (suds >= 40) {
      return '''- Moderate exposure (2-5 minutes)
- Balanced intensity
- Focus on sitting with uncertainty''';
    } else if (suds >= 20) {
      return '''- Long exposure (5-10 minutes)
- Lower intensity allows longer duration
- Practice mindfulness of mild discomfort''';
    } else {
      return '''- Extended exposure (10+ minutes)
- Low intensity training
- Focus on boredom and habituation''';
    }
  }

  String _getDurationLabel(int suds) {
    if (suds >= 80) return 'very brief';
    if (suds >= 60) return 'short';
    if (suds >= 40) return 'moderate';
    if (suds >= 20) return 'long';
    return 'extended';
  }

  String _getOCDContext(OCDTheme theme) {
    switch (theme) {
      case OCDTheme.contamination:
        return 'Fear of contamination, germs, or illness. Compulsions include excessive washing, cleaning, or avoiding "contaminated" objects.';
      case OCDTheme.harm:
        return 'Intrusive thoughts about causing harm to self or others. Compulsions include checking, seeking reassurance, and mental reviewing.';
      case OCDTheme.checking:
        return 'Excessive doubt about safety (locks, appliances, etc.). Compulsions include repeated checking and reassurance-seeking.';
      case OCDTheme.tabooThoughts:
        return 'Unwanted intrusive thoughts about taboo topics. Compulsions include mental rituals and avoidance.';
      case OCDTheme.symmetry:
        return 'Need for objects to be symmetrical or "just right". Compulsions include arranging and ordering until it feels right.';
      case OCDTheme.perfectionism:
        return 'Fear of making mistakes or not meeting standards. Compulsions include excessive reviewing and redoing tasks.';
      case OCDTheme.relationship:
        return 'Obsessive doubts about relationships and feelings. Compulsions include seeking reassurance and comparing.';
      case OCDTheme.health:
        return 'Excessive worry about illness or bodily symptoms. Compulsions include checking body, researching symptoms, seeking medical reassurance.';
      case OCDTheme.existential:
        return 'Intrusive existential or philosophical questions. Compulsions include mental rumination and seeking answers.';
      case OCDTheme.scrupulosity:
        return 'Excessive concern about moral or religious matters. Compulsions include confessing, praying, and seeking religious reassurance.';
    }
  }

  String _getExerciseContext(ExerciseType type) {
    switch (type) {
      case ExerciseType.inVivo:
        return 'Real-life exposure where user physically confronts feared stimuli.';
      case ExerciseType.breathing:
        return 'Mindfulness-based distress tolerance paired with anxiety exposure.';
      case ExerciseType.cognitiveDefusion:
        return 'ACT-based exercise to observe thoughts without acting on them.';
      case ExerciseType.simulation:
        return 'Imaginal exposure through guided visualization or app simulation.';
      case ExerciseType.valuesClarification:
        return 'Values-based motivation exercise aligned with ERP.';
      case ExerciseType.journaling:
        return 'Structured reflection on OCD patterns and progress.';
    }
  }

  ReflectionCategory _parseReflectionCategory(String? category) {
    switch (category) {
      case 'taskEngagement':
        return ReflectionCategory.taskEngagement;
      case 'responsePrevention':
        return ReflectionCategory.responsePrevention;
      case 'inhibitoryLearning':
        return ReflectionCategory.inhibitoryLearning;
      case 'habituation':
        return ReflectionCategory.habituation;
      case 'learningConsolidation':
        return ReflectionCategory.learningConsolidation;
      default:
        return ReflectionCategory.taskEngagement;
    }
  }
}
