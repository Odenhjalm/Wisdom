import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_profile_repository.dart';

final authProfileRepositoryProvider = Provider<AuthProfileRepository>((ref) {
  return AuthProfileRepository();
});
