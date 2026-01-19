// providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_360/data/models/user_model.dart';
import 'package:real_estate_360/data/services/auth_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.data(null));

  // Future<void> sendOtp(String dialCode, String phoneNumber, UserRole role) async {
  //   state = const AsyncValue.loading();
  //   try {
  //     await _authService.sendOtp(dialCode, phoneNumber, role);
  //     state = const AsyncValue.data(null);
  //   } catch (e, stack) {
  //     state = AsyncValue.error(e, stack);
  //   }
  // }
  Future<void> sendOtp(String dialCode, String phoneNumber, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.sendOtp(dialCode, phoneNumber, role);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  void clearError() {
  if (state.hasError) {
    state = const AsyncValue.data(null);
  }
}


  Future<void> verifyOtp(String dialCode, String phoneNumber, String otp, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.verifyOtp(dialCode, phoneNumber, otp, role);
      // Update the currentUserProvider after successful verification
      _ref.read(currentUserProvider.notifier).state = user;
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> signup(
    String name, 
    String email, 
    String dialCode,
    String phoneNumber,
    String password,
    UserRole role,
    String gender,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signup(
        name, 
        email, 
        dialCode,
        phoneNumber,
        password,
        role,
        gender,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void logout() {
    _authService.logout();
    // Update the currentUserProvider after logout
    _ref.read(currentUserProvider.notifier).state = null;
    _ref.read(otpVisibilityProvider.notifier).state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});

// Provider to expose the current user
final currentUserProvider = StateProvider<User?>((ref) {
  return null; // Initial value is null
});

final otpVisibilityProvider = StateProvider<bool>((ref) => false);

// Provider to initialize auth on app startup
// Modified to not modify other providers
final authInitializerProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);
  await authService.init();
  // Don't modify other providers here
  // The user state will be handled separately
});


final isAuthInitializedProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isInitialized;
});

// Provider to initialize auth (returns a Future that completes when done)
final initializeAuthProvider = FutureProvider<void>((ref) async {
  final authService = ref.read(authServiceProvider);
  if (!authService.isInitialized) {
    await authService.init();
  }
});
// Separate provider to get the current user from the auth service
final currentUserFromServiceProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});
