import 'package:flutter/material.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/shared/widgets/app_header.dart';
import 'package:mannpakad/shared/widgets/bottom_nav.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  LessonCategory? selectedCategory;
  Lesson? selectedLesson;
  final List<String> completedLessons = [];

  final lessons = const [
    Lesson(
      id: '1',
      title: 'What is OCD?',
      category: LessonCategory.ocdBasics,
      content:
          'OCD is characterized by unwanted, intrusive thoughts (obsessions) that cause distress and repetitive behaviors or mental acts (compulsions) performed to reduce that distress.\n\nKey Points:\n- Obsessions are NOT your values or desires\n- Everyone has intrusive thoughts\n- It is the meaning you attach that matters\n- Compulsions provide temporary relief but strengthen the cycle',
      duration: 5,
      completed: false,
      icon: '🧠',
    ),
    Lesson(
      id: '2',
      title: 'The OCD Cycle',
      category: LessonCategory.ocdBasics,
      content:
          'The OCD cycle keeps you trapped:\n\n1. Trigger -> Something sparks an intrusive thought\n2. Obsession -> The thought feels important/dangerous\n3. Anxiety -> Distress rises\n4. Compulsion -> You do something to reduce anxiety\n5. Relief -> Temporary calm\n6. Return -> The cycle repeats, often stronger\n\nBreaking the cycle means disrupting the compulsion step.',
      duration: 4,
      completed: false,
      icon: '🔄',
    ),
    Lesson(
      id: '3',
      title: 'What is ERP?',
      category: LessonCategory.erpBasics,
      content:
          'Exposure and Response Prevention (ERP) is the gold standard treatment for OCD.\n\nExposure: Deliberately facing feared thoughts, situations, or objects\nResponse Prevention: Choosing not to engage in compulsions\n\nWhy it works:\n- Teaches your brain the feared outcome does not happen\n- Builds distress tolerance\n- Creates new learning that competes with old fears',
      duration: 5,
      completed: false,
      icon: '🎯',
    ),
    Lesson(
      id: '4',
      title: 'Building a Fear Hierarchy',
      category: LessonCategory.erpBasics,
      content:
          'A fear hierarchy (or ladder) ranks your fears from least to most distressing.\n\nSteps:\n1. List all feared situations\n2. Rate each from 0-100 (SUDs)\n3. Order from lowest to highest\n4. Start with lower items to build confidence\n5. Progress up gradually\n\nRemember: It is normal to feel anxious. The goal is not to eliminate anxiety but to learn you can handle it.',
      duration: 6,
      completed: false,
      icon: '📊',
    ),
    Lesson(
      id: '5',
      title: 'Inhibitory Learning',
      category: LessonCategory.inhibitoryLearning,
      content:
          'Modern ERP focuses on inhibitory learning rather than just habituation.\n\nOld View: Anxiety naturally decreases with repeated exposure\nNew View: We create NEW learning that competes with old fears\n\nKey Principles:\n- Expectancy Violation: What you predicted vs. what happened\n- Variability: Practice in different contexts\n- Deepened Extinction: Combine multiple fears\n- Remove Safety Signals: No reassurance-seeking',
      duration: 7,
      completed: false,
      icon: '💡',
    ),
    Lesson(
      id: '6',
      title: 'Expectancy Violation',
      category: LessonCategory.inhibitoryLearning,
      content:
          'The most powerful learning happens when your prediction is WRONG.\n\nBefore Exposure:\n"What do I predict will happen?"\n"How likely is it (0-100%)?"\n\nAfter Exposure:\n"What actually happened?"\n"What does this teach me?"\n\nExample:\nPrediction: "If I do not check the stove, my house will burn down"\nReality: "The stove was off. Nothing bad happened."\nLearning: "I can handle uncertainty about the stove."',
      duration: 5,
      completed: false,
      icon: '🎲',
    ),
    Lesson(
      id: '7',
      title: 'Removing Reassurance',
      category: LessonCategory.inhibitoryLearning,
      content:
          'Reassurance is a compulsion that keeps OCD alive.\n\nForms of Reassurance:\n- Asking others "Is this okay?"\n- Googling symptoms\n- Reviewing memories\n- Mental checking\n\nWhy Remove It:\n- Blocks learning\n- Teaches you cannot handle uncertainty\n- Provides only temporary relief\n\nInstead, Say:\n"I can handle not knowing."\n"Maybe, maybe not."\n"I will find out."',
      duration: 5,
      completed: false,
      icon: '🚫',
    ),
    Lesson(
      id: '8',
      title: 'Distress Tolerance',
      category: LessonCategory.distressTolerance,
      content:
          'You are stronger than you think. Distress is uncomfortable but not dangerous.\n\nSkills:\n- Urge Surfing: Ride the wave without acting\n- Grounding: Use senses to stay present\n- Breathing: Slow, deliberate breaths\n- Self-Compassion: Treat yourself kindly\n\nRemember:\nAnxiety peaks and passes. You do not need to make it go away, just let it be there.',
      duration: 6,
      completed: false,
      icon: '🌊',
    ),
    Lesson(
      id: '9',
      title: 'Embracing Uncertainty',
      category: LessonCategory.distressTolerance,
      content:
          'OCD craves certainty. Recovery means befriending uncertainty.\n\nCertainty Paradox:\nThe more you seek certainty, the more uncertain you feel.\n\nPractice Phrases:\n- "I do not know, and that is okay."\n- "Maybe, maybe not."\n- "I am willing to take that risk."\n- "I can handle not knowing."\n\nLiving with uncertainty is freedom.',
      duration: 4,
      completed: false,
      icon: '🌌',
    ),
    Lesson(
      id: '10',
      title: 'Supporting a Loved One',
      category: LessonCategory.familyEducation,
      content:
          'If someone you love has OCD:\n\nDo:\n- Learn about OCD\n- Encourage professional help\n- Support ERP practice\n- Be patient\n- Celebrate effort, not outcomes\n\nDo not:\n- Provide reassurance\n- Participate in rituals\n- Dismiss their feelings\n- Expect quick fixes\n\nYour role: Be a cheerleader for their courage, not a solver of their anxiety.',
      duration: 5,
      completed: false,
      icon: '💕',
    ),
  ];

  final categories = const [
    _CategoryInfo(
      LessonCategory.ocdBasics,
      'OCD Basics',
      Icons.psychology,
      AppColors.calm,
    ),
    _CategoryInfo(
      LessonCategory.erpBasics,
      'ERP Basics',
      Icons.menu_book,
      AppColors.primary,
    ),
    _CategoryInfo(
      LessonCategory.inhibitoryLearning,
      'Inhibitory Learning',
      Icons.lightbulb,
      AppColors.clarity,
    ),
    _CategoryInfo(
      LessonCategory.distressTolerance,
      'Distress Tolerance',
      Icons.favorite,
      AppColors.accent,
    ),
    _CategoryInfo(
      LessonCategory.familyEducation,
      'Family Guide',
      Icons.people,
      AppColors.calm,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (selectedLesson != null) {
      return _LessonDetail(
        lesson: selectedLesson!,
        isCompleted: completedLessons.contains(selectedLesson!.id),
        onBack: () => setState(() => selectedLesson = null),
        onComplete: () {
          setState(() {
            if (!completedLessons.contains(selectedLesson!.id)) {
              completedLessons.add(selectedLesson!.id);
            }
            selectedLesson = null;
          });
        },
      );
    }

    if (selectedCategory != null) {
      final filtered = lessons
          .where((lesson) => lesson.category == selectedCategory)
          .toList();
      final categoryInfo = categories.firstWhere(
        (c) => c.id == selectedCategory,
      );
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => setState(() => selectedCategory = null),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            categoryInfo.label,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.gradientDark,
            ),
          ),
          child: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final lesson = filtered[index];
                final completed = completedLessons.contains(lesson.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: ListTile(
                    leading: Text(
                      lesson.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${lesson.duration} min read',
                      style: TextStyle(color: Colors.white.withAlpha(150)),
                    ),
                    trailing: completed
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                    onTap: () => setState(() => selectedLesson = lesson),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    final completedCount = completedLessons.length;
    return Scaffold(
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Learn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Understanding is the first step to freedom',
                      style: TextStyle(color: Colors.white.withAlpha(150)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.gradientPrimary,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Progress',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$completedCount/${lessons.length} lessons',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: lessons.isEmpty
                                  ? 0
                                  : completedCount / lessons.length,
                              color: Colors.white,
                              backgroundColor: Colors.white.withAlpha(50),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: categories.map((category) {
                        final categoryLessons = lessons
                            .where((lesson) => lesson.category == category.id)
                            .toList();
                        final categoryCompleted = categoryLessons
                            .where(
                              (lesson) => completedLessons.contains(lesson.id),
                            )
                            .length;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withAlpha(15),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(
                                () => selectedCategory = category.id,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: category.color.withAlpha(40),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        category.icon,
                                        color: category.color,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$categoryCompleted/${categoryLessons.length} complete',
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(
                                                150,
                                              ),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _LessonDetail extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const _LessonDetail({
    required this.lesson,
    required this.isCompleted,
    required this.onBack,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = lesson.content.split('\n\n');
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(lesson.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientDark,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          lesson.icon,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...paragraphs.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          p,
                          style: TextStyle(
                            height: 1.6,
                            fontSize: 16,
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isCompleted ? 'Completed!' : 'Mark as Complete',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryInfo {
  final LessonCategory id;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryInfo(this.id, this.label, this.icon, this.color);
}
