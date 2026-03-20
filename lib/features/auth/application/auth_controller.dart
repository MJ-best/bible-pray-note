import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_models.dart';

@immutable
class AuthState {
  const AuthState({
    required this.isLoading,
    required this.user,
    required this.errorMessage,
  });

  const AuthState.signedOut()
    : isLoading = false,
      user = null,
      errorMessage = null;

  const AuthState.signedIn(AppUser this.user)
    : isLoading = false,
      errorMessage = null;

  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    AppUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthController({AuthState? initialState})
    : _state = initialState ?? const AuthState.signedOut();

  factory AuthController.authenticated() {
    return AuthController(
      initialState: const AuthState.signedIn(
        AppUser(
          id: 'user-demo',
          name: 'Demo Operator',
          email: 'demo@example.com',
        ),
      ),
    );
  }

  AuthState _state;

  AuthState get state => _state;

  bool get isAuthenticated => _state.user != null;

  Future<void> signInWithGoogle({bool simulateFailure = false}) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (simulateFailure) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Google OAuth redirect failed. Try again.',
      );
      notifyListeners();
      return;
    }

    _state = const AuthState.signedIn(
      AppUser(
        id: 'user-demo',
        name: 'Demo Operator',
        email: 'demo@example.com',
      ),
    );
    notifyListeners();
  }

  void signOut() {
    _state = const AuthState.signedOut();
    notifyListeners();
  }
}

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(),
);
