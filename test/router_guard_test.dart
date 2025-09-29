import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:wisdom/core/routing/app_router.dart';

Session _fakeSession() {
  return Session.fromJson({
    'access_token': 'token',
    'token_type': 'bearer',
    'user': {
      'id': 'user-1',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'aud': 'authenticated',
      'created_at': DateTime.now().toIso8601String(),
    },
  })!;
}

void main() {
  const guard = AuthGuard({
    '/login',
    '/signup',
    '/landing',
    '/forgot-password',
    '/new-password',
  });

  test('redirects guests to /login for protected routes', () {
    final redirect = guard.redirect(const AuthState(null), '/profile');
    expect(redirect, '/login');
  });

  test('allows authenticated users and redirects away from login', () {
    final authState = AuthState(_fakeSession());
    final loginRedirect = guard.redirect(authState, '/login');
    expect(loginRedirect, '/');

    final feedRedirect = guard.redirect(authState, '/community');
    expect(feedRedirect, isNull);
  });
}
