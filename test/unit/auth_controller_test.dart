import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wisdom/api/auth_repository.dart';
import 'package:wisdom/core/auth/auth_controller.dart';
import 'package:wisdom/core/errors/app_failure.dart';
import 'package:wisdom/data/models/profile.dart';
import 'package:wisdom/gate.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;
  late AuthController controller;

  setUp(() {
    repo = _MockAuthRepository();
    controller = AuthController(repo);
    gate.reset();
  });

  tearDown(() {
    gate.reset();
  });

  test('login success updates state and opens gate', () async {
    final profile = Profile(
      id: 'user-123',
      email: 'user@example.com',
      userRole: UserRole.user,
      isAdmin: false,
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    );

    when(() => repo.currentToken()).thenAnswer((_) async => null);
    when(() => repo.login(
        email: any(named: 'email'),
        password: any(named: 'password'))).thenAnswer((_) async => profile);

    await controller.login('user@example.com', 'secret123');

    expect(controller.state.profile, equals(profile));
    expect(controller.state.error, isNull);
    expect(controller.state.isLoading, isFalse);
    expect(gate.allowed, isTrue);
  });

  test('login failure surfaces localized message and keeps gate closed',
      () async {
    when(() => repo.currentToken()).thenAnswer((_) async => null);
    when(() => repo.login(
        email: any(named: 'email'),
        password: any(named: 'password'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {'detail': 'Invalid credentials'},
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    await expectLater(
      () => controller.login('user@example.com', 'wrong-pass'),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'Fel e-postadress eller lösenord.',
        ),
      ),
    );

    expect(controller.state.profile, isNull);
    expect(controller.state.error, 'Fel e-postadress eller lösenord.');
    expect(controller.state.isLoading, isFalse);
    expect(gate.allowed, isFalse);
  });
}
