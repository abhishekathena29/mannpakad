import 'package:flutter/material.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/features/auth/providers/app_auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final auth = AppAuthScope.of(context);
    final avatar = appState.avatar;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(50),
                      child: Text(
                        avatar?.style.emoji ?? '🙂',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.userProfile?.name ?? 'Friend',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'with ${avatar?.name ?? 'Companion'}',
                          style: TextStyle(color: Colors.white.withAlpha(150)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  value: notifications,
                  onChanged: (value) => setState(() => notifications = value),
                  title: const Text(
                    'Reminders',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Daily practice nudges',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withAlpha(50),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DATA & PRIVACY',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.download,
                        color: Colors.white70,
                      ),
                      title: const Text(
                        'Export Data',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Download for your therapist',
                        style: TextStyle(color: Colors.white.withAlpha(150)),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export not implemented in demo.'),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: Colors.white.withAlpha(10)),
                    ListTile(
                      leading: const Icon(Icons.shield, color: Colors.white70),
                      title: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Your data stays on your device',
                        style: TextStyle(color: Colors.white.withAlpha(150)),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CRISIS RESOURCES',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withAlpha(50),
                      AppColors.accent.withAlpha(20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'If you are in crisis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentLight,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'National Suicide Prevention Lifeline: 988',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Crisis Text Line: Text HOME to 741741',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'IOCDF Therapist Directory: iocdf.org/find-help',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Return to login and sign up screens',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  onTap: auth.signOut,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DANGER ZONE',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withAlpha(50)),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    'Reset All Data',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'This cannot be undone',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF1a1a2e),
                          title: const Text(
                            'Are you sure?',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'This will permanently delete all your data.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await auth.deleteStoredProfile();
                                if (!dialogContext.mounted) {
                                  return;
                                }
                                Navigator.pop(dialogContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Delete Everything'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ERP Companion is designed as a supportive tool for practicing exposure and response prevention. It is not a substitute for professional mental health treatment.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(120),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'ERP Companion v1.0.0',
                  style: TextStyle(
                    color: Colors.white.withAlpha(80),
                    fontSize: 12,
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
