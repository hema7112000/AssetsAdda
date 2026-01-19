import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/data/models/user_model.dart';
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:real_estate_360/widgets/common/custom_button.dart';
import 'package:real_estate_360/widgets/common//main_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectTo;

  const LoginScreen({super.key, this.redirectTo});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dialCodeController = TextEditingController(text: '+91'); // Default dial code
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  UserRole _selectedRole = UserRole.ROLE_SELLER;
  bool _isResendingOtp = false;

  @override
  void dispose() {
    _dialCodeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      // Simply call the provider with the new parameters
      ref.read(authProvider.notifier).sendOtp(
            _dialCodeController.text,
            _phoneController.text,
            _selectedRole,
          );
    }
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).verifyOtp(
            _dialCodeController.text,
            _phoneController.text,
            _otpController.text,
            _selectedRole,
          );
    }
  }

  void _resendOtp() {
    setState(() {
      _isResendingOtp = true;
    });
    ref.read(authProvider.notifier).sendOtp(
          _dialCodeController.text,
          _phoneController.text,
          _selectedRole,
        );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isResendingOtp = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the auth state for loading and errors
    final authState = ref.watch(authProvider);

    // Watch the UI state for OTP field visibility
    final showOtpField = ref.watch(otpVisibilityProvider);
    print("LOGIN SCREEN PATH: ${GoRouter.of(context).routerDelegate.currentConfiguration.last.matchedLocation}");

    // Update the listener in the build method:
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      // Show error
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
      print('otppppp');
      
      // OTP sent successfully → show OTP field
      if (previous?.isLoading == true &&
          next.isLoading == false &&
          !next.hasError &&
          _otpController.text.isEmpty) {
        ref.read(otpVisibilityProvider.notifier).state = true;
      }

      // OTP VERIFIED successfully → navigate to intended destination
      if (previous?.isLoading == true &&
          next is AsyncData &&
          _otpController.text.isNotEmpty) {
        // Navigate to the intended destination or home if not specified
        final destination = widget.redirectTo ?? '/';
        context.go(destination);
      }
    });

    return MainScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesome.home, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 20),
                Text('Assets Adda', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 40),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Login as'),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _dialCodeController,
                        decoration: const InputDecoration(labelText: 'Code'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        // Use the state from the provider for validation
                        validator: showOtpField ? null : (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid phone number (at least 10 digits)';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                // Use the state from the provider to conditionally show the field
                if (showOtpField) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: 'Enter OTP'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length < 6) {
                        return 'Please enter a valid OTP';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isResendingOtp ? null : _resendOtp,
                        child: _isResendingOtp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Resend OTP'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                authState.isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        // Use the state from the provider for button text and action
                        text: showOtpField ? 'Verify OTP' : 'Send OTP',
                        onPressed: showOtpField ? _verifyOtp : _sendOtp,
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Reset the OTP visibility when navigating away
                    ref.read(otpVisibilityProvider.notifier).state = false;
                    context.push('/signup');
                  },
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}