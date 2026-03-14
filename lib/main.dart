import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/core/theme/app_theme.dart';
import 'package:mannpakad/features/ai_exposure/screens/ai_exposure_screen.dart';
import 'package:mannpakad/features/auth/providers/app_auth_provider.dart';
import 'package:mannpakad/features/auth/screens/login_screen.dart';
import 'package:mannpakad/features/auth/screens/signup_screen.dart';
import 'package:mannpakad/features/auth/screens/welcome_screen.dart';
import 'package:mannpakad/features/avatar/screens/avatar_creation_screen.dart';
import 'package:mannpakad/features/breathing/screens/breathing_exercise_screen.dart';
import 'package:mannpakad/features/defusion/screens/cognitive_defusion_screen.dart';
import 'package:mannpakad/features/exposure/screens/exposure_session_screen.dart';
import 'package:mannpakad/features/hierarchy/screens/hierarchy_screen.dart';
import 'package:mannpakad/features/home/screens/home_screen.dart';
import 'package:mannpakad/features/journaling/screens/journaling_screen.dart';
import 'package:mannpakad/features/learn/screens/learn_screen.dart';
import 'package:mannpakad/features/onboarding/screens/onboarding_screen.dart';
import 'package:mannpakad/features/rewards/screens/rewards_screen.dart';
import 'package:mannpakad/features/settings/screens/settings_screen.dart';
import 'package:mannpakad/features/simulation/screens/simulation_screen.dart';
import 'package:mannpakad/features/tracker/screens/tracker_screen.dart';
import 'package:mannpakad/features/values/screens/values_screen.dart';
import 'package:mannpakad/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appState = AppState();
  final authProvider = AppAuthProvider(appState: appState);

  runApp(
    AppStateScope(
      notifier: appState,
      child: AppAuthScope(notifier: authProvider, child: const MannPakadApp()),
    ),
  );
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
    final auth = AppAuthScope.of(context);
    final appState = AppStateScope.of(context);

    if (auth.isBootstrapping) {
      return const _SplashScreen();
    }

    if (!auth.isAuthenticated) {
      switch (auth.currentView) {
        case AuthView.login:
          return const LoginScreen();
        case AuthView.signup:
          return const SignupScreen();
        case AuthView.welcome:
          return const WelcomeScreen();
      }
    }

    if (auth.needsOnboarding) {
      return const OnboardingScreen();
    }

    if (auth.needsAvatar) {
      return const AvatarCreationScreen();
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientDark,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
