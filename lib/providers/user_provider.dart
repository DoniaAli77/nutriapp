import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutriapp/models/user_model.dart';
import 'auth_service.dart';

// Define a provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Define a provider for user state
final userProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.user;
});
