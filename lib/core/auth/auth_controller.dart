import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wisdom/api/auth_repository.dart';
import 'package:wisdom/core/auth/auth_claims.dart';
import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/gate.dart';

@immutable
class AuthState {
  const AuthState({
    this.profile,
    this.claims,
    this.isLoading = false,
    this.error,
  });

  final Profile? profile;
  final AuthClaims? claims;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    Profile? profile,
    AuthClaims? claims,
    bool? isLoading,
    String? error,
    bool clearClaims = false,
  }) =>
      AuthState(
        profile: profile ?? this.profile,
        claims: clearClaims ? null : (claims ?? this.claims),
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  bool get isAuthenticated => profile != null || claims != null;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> loadSession() async {
    final token = await _repo.currentToken();
    if (token == null) {
      gate.reset();
      state = const AuthState();
      return;
    }
    final claims = AuthClaims.fromToken(token);
    state = state.copyWith(isLoading: true, error: null, claims: claims);
    try {
      final profile = await _repo.getCurrentProfile();
      state = state.copyWith(profile: profile, isLoading: false);
      gate.allow();
    } catch (err, stackTrace) {
      await _repo.logout();
      gate.reset();
      final failure = AppFailure.from(err, stackTrace);
      state = AuthState(
        profile: null,
        claims: null,
        isLoading: false,
        error: failure.message,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, clearClaims: true);
    try {
      final profile = await _repo.login(email: email, password: password);
      final token = await _repo.currentToken();
      final claims = token != null ? AuthClaims.fromToken(token) : null;
      state = AuthState(profile: profile, claims: claims, isLoading: false);
      gate.allow();
    } catch (err, stackTrace) {
      final failure = AppFailure.from(err, stackTrace);
      state = AuthState(
        profile: null,
        claims: null,
        isLoading: false,
        error: failure.message,
      );
      gate.reset();
      throw failure;
    }
  }

  Future<void> register(
    String email,
    String password, {
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null, clearClaims: true);
    try {
      final profile = await _repo.register(
        email: email,
        password: password,
        displayName: displayName?.trim().isNotEmpty == true
            ? displayName!.trim()
            : email.split('@').first,
      );
      final token = await _repo.currentToken();
      final claims = token != null ? AuthClaims.fromToken(token) : null;
      state = AuthState(profile: profile, claims: claims, isLoading: false);
      gate.allow();
    } catch (err, stackTrace) {
      final failure = AppFailure.from(err, stackTrace);
      state = AuthState(
        profile: null,
        claims: null,
        isLoading: false,
        error: failure.message,
      );
      gate.reset();
      throw failure;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    gate.reset();
    state = const AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repo = ref.watch(authRepositoryProvider);
    final controller = AuthController(repo);
    controller.loadSession();
    return controller;
  },
);
