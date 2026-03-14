import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mannpakad/core/models/app_models.dart';
import 'package:mannpakad/core/state/app_state.dart';
import 'package:mannpakad/features/auth/data/user_profile_repository.dart';

enum AuthView { welcome, login, signup }

class AppAuthProvider extends ChangeNotifier {
  AppAuthProvider({
    required AppState appState,
    FirebaseAuth? firebaseAuth,
    UserProfileRepository? repository,
  }) : _appState = appState,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _repository = repository ?? UserProfileRepository() {
    _authSubscription = _firebaseAuth.authStateChanges().listen(_handleAuth);
  }

  final AppState _appState;
  final FirebaseAuth _firebaseAuth;
  final UserProfileRepository _repository;

  StreamSubscription<User?>? _authSubscription;

  User? currentUser;
  UserProfile? profile;
  Avatar? avatar;
  bool isBootstrapping = true;
  bool isSubmitting = false;
  String? errorMessage;
  AuthView currentView = AuthView.welcome;

  bool get isAuthenticated => currentUser != null;
  bool get needsOnboarding => isAuthenticated && profile == null;
  bool get needsAvatar => isAuthenticated && profile != null && avatar == null;

  void setView(AuthView view) {
    if (currentView == view) {
      return;
    }
    currentView = view;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _wrapSubmission(() async {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await _wrapSubmission(() async {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<void> saveOnboarding({
    required String name,
    required AgeMode ageMode,
    required List<OCDTheme> ocdThemes,
    required List<ADHDTrait> adhdTraits,
    required List<String> sensitivities,
    required CoachingTone coachingTone,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      return;
    }

    final userProfile = UserProfile(
      id: uid,
      name: name.isEmpty ? 'Friend' : name,
      ageMode: ageMode,
      ocdThemes: ocdThemes,
      adhdTraits: adhdTraits,
      sensitivities: sensitivities,
      coachingTone: coachingTone,
      createdAt: profile?.createdAt ?? DateTime.now(),
    );

    await _wrapSubmission(() async {
      profile = await _repository.saveProfile(uid, userProfile);
      _appState.completeOnboarding(
        id: profile!.id,
        createdAt: profile!.createdAt,
        name: profile!.name,
        ageMode: profile!.ageMode,
        ocdThemes: profile!.ocdThemes,
        adhdTraits: profile!.adhdTraits,
        sensitivities: profile!.sensitivities,
        coachingTone: profile!.coachingTone,
      );
    });
  }

  Future<void> saveAvatar({
    required String name,
    required AvatarStyle style,
    required AvatarPersonality personality,
    required String background,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      return;
    }

    final companion = Avatar(
      id: uid,
      name: name.isEmpty ? 'Buddy' : name,
      style: style,
      personality: personality,
      accessories: const [],
      background: background,
      level: avatar?.level ?? 1,
      experience: avatar?.experience ?? 0,
    );

    await _wrapSubmission(() async {
      avatar = await _repository.saveAvatar(uid, companion);
      _appState.setAvatar(
        id: avatar!.id,
        name: avatar!.name,
        style: avatar!.style,
        personality: avatar!.personality,
        background: avatar!.background,
        level: avatar!.level,
        experience: avatar!.experience,
      );
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> deleteStoredProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) {
      return;
    }

    await _wrapSubmission(() async {
      await _repository.deleteSession(uid);
      profile = null;
      avatar = null;
      _appState.resetApp();
    });
  }

  Future<void> _handleAuth(User? user) async {
    currentUser = user;
    errorMessage = null;

    if (user == null) {
      profile = null;
      avatar = null;
      currentView = AuthView.welcome;
      isBootstrapping = false;
      _appState.resetApp();
      notifyListeners();
      return;
    }

    final session = await _repository.fetchSession(user.uid);
    profile = session?.profile;
    avatar = session?.avatar;
    if (profile != null) {
      _appState.hydrateSession(profile: profile!, avatar: avatar);
    }
    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> _wrapSubmission(Future<void> Function() action) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? 'Authentication failed.';
    } on FirebaseException catch (error) {
      errorMessage = error.message ?? 'Something went wrong while saving.';
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

class AppAuthScope extends InheritedNotifier<AppAuthProvider> {
  const AppAuthScope({
    super.key,
    required AppAuthProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppAuthProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppAuthScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('AppAuthScope not found in widget tree');
    }
    return scope.notifier!;
  }
}
