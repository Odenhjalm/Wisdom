import 'package:wisdom/api/api_client.dart';
import 'package:wisdom/core/errors/app_failure.dart';

class AdminRepository {
  AdminRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final response =
          await _client.get<Map<String, dynamic>>('/admin/dashboard');
      return response;
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<void> approveTeacher(String userId) async {
    try {
      await _client.post(
        '/admin/teachers/$userId/approve',
      );
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<void> rejectTeacher(String userId) async {
    try {
      await _client.post(
        '/admin/teachers/$userId/reject',
      );
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }

  Future<void> updateCertificateStatus({
    required String certificateId,
    required String status,
  }) async {
    try {
      await _client.patch(
        '/admin/certificates/$certificateId',
        body: {'status': status},
      );
    } catch (error, stackTrace) {
      throw AppFailure.from(error, stackTrace);
    }
  }
}
