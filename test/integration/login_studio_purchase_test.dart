import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wisdom/api/api_client.dart';
import 'package:wisdom/api/auth_repository.dart';
import 'package:wisdom/core/auth/token_storage.dart';
import 'package:wisdom/features/payments/data/payments_repository.dart';
import 'package:wisdom/features/studio/data/studio_repository.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('Login → Studio → Purchase flow', () {
    test('completes happy path via repositories', () async {
      final apiClient = _MockApiClient();
      final tokenStorage = _MockTokenStorage();
      final authRepository = AuthRepository(apiClient, tokenStorage);
      final studioRepository = StudioRepository(client: apiClient);
      final paymentsRepository = PaymentsRepository(apiClient);

      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/auth/login',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => {
          'access_token': 'access_123',
          'refresh_token': 'refresh_123',
        },
      );

      when(
        () => apiClient.get<Map<String, dynamic>>('/profiles/me'),
      ).thenAnswer(
        (_) async => {
          'user_id': 'user-1',
          'email': 'teacher@example.com',
          'role_v2': 'teacher',
          'is_admin': false,
          'display_name': 'Teacher',
          'bio': null,
          'photo_url': null,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        },
      );

      final profile = await authRepository.login(
        email: 'teacher@example.com',
        password: 'secret123',
      );

      expect(profile.email, 'teacher@example.com');
      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access_123',
          refreshToken: 'refresh_123',
        ),
      ).called(1);

      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/studio/courses',
          body: any(named: 'body'),
        ),
      ).thenAnswer((invocation) async {
        final payload =
            Map<String, dynamic>.from(invocation.namedArguments[#body] as Map);
        return {
          'id': 'course-1',
          'title': payload['title'],
          'slug': payload['slug'],
          'description': payload['description'],
          'is_free_intro': payload['is_free_intro'],
          'is_published': payload['is_published'],
          'price_cents': payload['price_cents'],
        };
      });

      final createdCourse = await studioRepository.createCourse(
        title: 'Testkurs',
        slug: 'test-kurs',
        description: 'En kurs för test',
        priceCents: 0,
        isFreeIntro: true,
        isPublished: true,
      );

      expect(createdCourse['id'], 'course-1');
      expect(createdCourse['is_free_intro'], true);

      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/payments/orders/course',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => {
          'order': {
            'id': 'order-1',
            'amount_cents': 0,
            'currency': 'sek',
          },
        },
      );

      final order = await paymentsRepository.startCourseOrder(
        courseId: 'course-1',
        amountCents: 0,
      );

      expect(order['id'], 'order-1');

      when(
        () => apiClient.post<Map<String, dynamic>>(
          '/payments/create-checkout-session',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => {
          'url': 'https://checkout.test/session/abc',
          'id': 'sess_abc',
        },
      );

      final checkoutUrl = await paymentsRepository.checkoutUrl(
        orderId: 'order-1',
        successUrl: 'wisdom://success',
        cancelUrl: 'wisdom://cancel',
      );

      expect(checkoutUrl, 'https://checkout.test/session/abc');
      verifyNoMoreInteractions(tokenStorage);
    });
  });
}
