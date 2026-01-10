import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class AvatarCreationScreen extends StatefulWidget {
  const AvatarCreationScreen({super.key});

  @override
  State<AvatarCreationScreen> createState() => _AvatarCreationScreenState();
}

class _AvatarCreationScreenState extends State<AvatarCreationScreen> {
  AvatarStyle selectedStyle = AvatarStyle.fox;
  AvatarPersonality selectedPersonality = AvatarPersonality.friend;
  String selectedBackground = 'meadow';
  final nameController = TextEditingController();

  final backgrounds = const ['meadow', 'sunset', 'ocean', 'forest', 'stars'];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Widget buildGradientScaffold({required Widget body}) {
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
        child: SafeArea(child: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return buildGradientScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Create Your Companion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Meet your supportive guide, ${appState.userProfile?.name ?? ''}!',
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _AvatarPreview(
                    style: selectedStyle,
                    name: nameController.text,
                    background: selectedBackground,
                  ),
                  const SizedBox(height: 32),
                  _Section(
                    title: 'Choose a Style',
                    child: SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: AvatarStyle.values.map((style) {
                          final active = selectedStyle == style;
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: InkWell(
                              onTap: () =>
                                  setState(() => selectedStyle = style),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 88,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primary.withAlpha(50)
                                      : Colors.white.withAlpha(10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: active
                                        ? AppColors.primary
                                        : Colors.white.withAlpha(20),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      style.emoji,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      style.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: active
                                            ? Colors.white
                                            : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  _Section(
                    title: 'Give Them a Name',
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., Luna, Buddy, Sage...',
                        hintStyle: TextStyle(
                          color: Colors.white.withAlpha(100),
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  _Section(
                    title: 'Personality Type',
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: AvatarPersonality.values.map((personality) {
                        final active = selectedPersonality == personality;
                        return InkWell(
                          onTap: () =>
                              setState(() => selectedPersonality = personality),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.calm.withAlpha(50)
                                  : Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: active
                                    ? AppColors.calm
                                    : Colors.white.withAlpha(20),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _personalityLabel(personality),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _personalityDescription(personality),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _Section(
                    title: 'Background Theme',
                    child: Row(
                      children: backgrounds.map((bg) {
                        final active = selectedBackground == bg;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () =>
                                setState(() => selectedBackground = bg),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: _backgroundGradient(bg),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: active
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withAlpha(100),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  appState.setAvatar(
                    name: nameController.text.trim().isEmpty
                        ? 'Buddy'
                        : nameController.text.trim(),
                    style: selectedStyle,
                    personality: selectedPersonality,
                    background: selectedBackground,
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Let's Begin Together"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _personalityLabel(AvatarPersonality personality) {
    switch (personality) {
      case AvatarPersonality.coach:
        return 'Coach';
      case AvatarPersonality.friend:
        return 'Friend';
      case AvatarPersonality.mentor:
        return 'Mentor';
      case AvatarPersonality.cheerleader:
        return 'Cheerleader';
    }
  }

  String _personalityDescription(AvatarPersonality personality) {
    switch (personality) {
      case AvatarPersonality.coach:
        return 'Motivating and structured';
      case AvatarPersonality.friend:
        return 'Supportive and understanding';
      case AvatarPersonality.mentor:
        return 'Wise and patient';
      case AvatarPersonality.cheerleader:
        return 'Enthusiastic and encouraging';
    }
  }

  LinearGradient _backgroundGradient(String bg) {
    switch (bg) {
      case 'sunset':
        return const LinearGradient(
          colors: [AppColors.accentLight, AppColors.calmLight],
        );
      case 'ocean':
        return const LinearGradient(
          colors: [AppColors.clarityLight, AppColors.calmLight],
        );
      case 'forest':
        return const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.calmLight],
        );
      case 'stars':
        return const LinearGradient(
          colors: [AppColors.calmLight, AppColors.accentLight],
        );
      default:
        return const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.calmLight],
        );
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final AvatarStyle style;
  final String name;
  final String background;

  const _AvatarPreview({
    required this.style,
    required this.name,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _backgroundGradient(background),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(color: Colors.white.withAlpha(50), width: 4),
          ),
          child: Center(
            child: Text(style.emoji, style: const TextStyle(fontSize: 80)),
          ),
        ),
        if (name.isNotEmpty)
          Positioned(
            bottom: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  LinearGradient _backgroundGradient(String bg) {
    switch (bg) {
      case 'sunset':
        return const LinearGradient(
          colors: [AppColors.accentLight, AppColors.calmLight],
        );
      case 'ocean':
        return const LinearGradient(
          colors: [AppColors.clarityLight, AppColors.calmLight],
        );
      case 'forest':
        return const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.calmLight],
        );
      case 'stars':
        return const LinearGradient(
          colors: [AppColors.calmLight, AppColors.accentLight],
        );
      default:
        return const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.calmLight],
        );
    }
  }
}
