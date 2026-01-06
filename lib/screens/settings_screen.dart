import 'package:flutter/material.dart';
import 'package:mannpakad/models.dart';
import '../app_state.dart';
import '../theme.dart';

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
    final avatar = appState.avatar;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.setCurrentView(AppView.home),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(avatar?.style.emoji ?? '🙂'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.userProfile?.name ?? 'Friend',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'with ${avatar?.name ?? 'Companion'}',
                      style: TextStyle(color: AppColors.mutedText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: notifications,
              onChanged: (value) => setState(() => notifications = value),
              title: const Text('Reminders'),
              subtitle: const Text('Daily practice nudges'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Data & Privacy',
            style: TextStyle(fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download for your therapist'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export not implemented in demo.'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Your data stays on your device'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Crisis Resources',
            style: TextStyle(fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'If you are in crisis',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('National Suicide Prevention Lifeline: 988'),
                Text('Crisis Text Line: Text HOME to 741741'),
                Text('IOCDF Therapist Directory: iocdf.org/find-help'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Danger Zone',
            style: TextStyle(fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Reset All Data',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('This cannot be undone'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text(
                        'This will permanently delete all your data.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            appState.resetApp();
                            Navigator.pop(dialogContext);
                          },
                          child: const Text('Delete Everything'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'ERP Companion is designed as a supportive tool for practicing exposure and response prevention. It is not a substitute for professional mental health treatment.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'ERP Companion v1.0.0',
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
