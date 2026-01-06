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

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Create Your Companion',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    'Meet your supportive guide, ${appState.userProfile?.name ?? ''}!',
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _AvatarPreview(
                      style: selectedStyle,
                      name: nameController.text,
                      background: selectedBackground,
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Choose a Style',
                      child: SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: AvatarStyle.values.map((style) {
                            final active = selectedStyle == style;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onTap: () => setState(() => selectedStyle = style),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 88,
                                  decoration: BoxDecoration(
                                    color: active ? AppColors.primaryLight : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: active ? AppColors.primary : const Color(0xFFE2E8F0),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(style.emoji, style: const TextStyle(fontSize: 28)),
                                      const SizedBox(height: 6),
                                      Text(
                                        style.name,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                        decoration: InputDecoration(
                          hintText: 'e.g., Luna, Buddy, Sage...',
                          filled: true,
                          fillColor: AppColors.muted,
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
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: AvatarPersonality.values.map((personality) {
                          final active = selectedPersonality == personality;
                          return InkWell(
                            onTap: () => setState(() => selectedPersonality = personality),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: active ? AppColors.calmLight : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: active ? AppColors.calm : const Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_personalityLabel(personality),
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(
                                    _personalityDescription(personality),
                                    style: TextStyle(fontSize: 11, color: AppColors.mutedText),
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
                              onTap: () => setState(() => selectedBackground = bg),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: _backgroundGradient(bg),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: active ? AppColors.accent : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
                ),
              ),
            ),
          ],
        ),
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
        return const LinearGradient(colors: [AppColors.accentLight, AppColors.calmLight]);
      case 'ocean':
        return const LinearGradient(colors: [AppColors.clarityLight, AppColors.calmLight]);
      case 'forest':
        return const LinearGradient(colors: [AppColors.primaryLight, AppColors.calmLight]);
      case 'stars':
        return const LinearGradient(colors: [AppColors.calmLight, AppColors.accentLight]);
      default:
        return const LinearGradient(colors: [AppColors.primaryLight, AppColors.calmLight]);
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _backgroundGradient(background),
          ),
          child: Center(
            child: Text(style.emoji, style: const TextStyle(fontSize: 64)),
          ),
        ),
        if (name.isNotEmpty)
          Positioned(
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  LinearGradient _backgroundGradient(String bg) {
    switch (bg) {
      case 'sunset':
        return const LinearGradient(colors: [AppColors.accentLight, AppColors.calmLight]);
      case 'ocean':
        return const LinearGradient(colors: [AppColors.clarityLight, AppColors.calmLight]);
      case 'forest':
        return const LinearGradient(colors: [AppColors.primaryLight, AppColors.calmLight]);
      case 'stars':
        return const LinearGradient(colors: [AppColors.calmLight, AppColors.accentLight]);
      default:
        return const LinearGradient(colors: [AppColors.primaryLight, AppColors.calmLight]);
    }
  }
}
