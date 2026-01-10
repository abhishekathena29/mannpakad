import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mannpakad/firebase_options.dart';
import 'app_state.dart';
import 'models.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/avatar_creation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/hierarchy_screen.dart';
import 'screens/exposure_session_screen.dart';
import 'screens/tracker_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/breathing_exercise_screen.dart';
import 'screens/cognitive_defusion_screen.dart';
import 'screens/values_screen.dart';
import 'screens/journaling_screen.dart';
import 'screens/simulation_screen.dart';
import 'screens/ai_exposure_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final appState = AppState();
  runApp(AppStateScope(notifier: appState, child: const MannPakadApp()));
}

class MannPakadApp extends StatelessWidget {
  const MannPakadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mann Pakad',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (!appState.isOnboarded) {
      switch (appState.currentView) {
        case AppView.onboarding:
          return const OnboardingScreen();
        case AppView.avatarCreation:
          return const AvatarCreationScreen();
        default:
          return const WelcomeScreen();
      }
    }

    switch (appState.currentView) {
      case AppView.home:
        return const HomeScreen();
      case AppView.hierarchy:
        return const HierarchyScreen();
      case AppView.exposure:
        return const ExposureSessionScreen();
      case AppView.tracker:
        return const TrackerScreen();
      case AppView.learn:
        return const LearnScreen();
      case AppView.rewards:
        return const RewardsScreen();
      case AppView.settings:
        return const SettingsScreen();
      case AppView.breathing:
        return const BreathingExerciseScreen();
      case AppView.defusion:
        return const CognitiveDefusionScreen();
      case AppView.value:
        return const ValuesScreen();
      case AppView.journaling:
        return const JournalingScreen();
      case AppView.simulation:
        return const SimulationScreen();
      case AppView.aiExposure:
        return const AIExposureScreen();
      default:
        return const HomeScreen();
    }
  }
}
