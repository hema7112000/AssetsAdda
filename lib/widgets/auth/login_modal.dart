// lib/widgets/auth/login_modal.dart

import 'dart:ui'; // <-- Import this for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:real_estate_360/data/models/user_model.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart'; 
import 'package:real_estate_360/scaffold_messenger.dart';


class LoginModal extends ConsumerStatefulWidget {
  final String? redirectTo;
  
  const LoginModal({
    Key? key,
    this.redirectTo,
  }) : super(key: key);

  @override
  ConsumerState<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends ConsumerState<LoginModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
    if (_tabController.indexIsChanging) {
      ref.read(authProvider.notifier).clearError();
    }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final maxHeightFactor = (_tabController.index == 0) ? 0.6 : 0.8;
  final maxHeight = screenHeight * maxHeightFactor;

    return Dialog(
      // Set the background of the dialog itself to transparent to see the blur
      backgroundColor: Colors.transparent,
      // Add some padding from the screen edges
      insetPadding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          // This creates the blur effect
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            // This is the translucent "glass" background
          decoration: BoxDecoration(
            color: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.20)
                : Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.30)
                  : Colors.black.withOpacity(0.15),
            ),
          ),

            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            child: Column(
              // Use MainAxisSize.min to make the column size to its children
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.9), // Slightly transparent header
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome to Assets Adda',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                // Tab bar for Login/Signup
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),
                
                // Content area
                // Use Flexible instead of Expanded to prevent taking up all available space
                Flexible(
                  fit: FlexFit.loose,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Login tab
                      // Wrap with SingleChildScrollView to prevent overflow
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LoginContent(redirectTo: widget.redirectTo),
                        ),
                      ),
                      
                      // Signup tab
                      // Wrap with SingleChildScrollView to prevent overflow
                      const SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SignupContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- LoginContent and SignupContent widgets remain the same ---
// No changes needed below this line

class LoginContent extends ConsumerStatefulWidget {
  final String? redirectTo;
  
  const LoginContent({Key? key, this.redirectTo}) : super(key: key);

  @override
  ConsumerState<LoginContent> createState() => _LoginContentState();
}

// class _LoginContentState extends ConsumerState<LoginContent> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _otpController = TextEditingController();
//   UserRole _selectedRole = UserRole.seller;
//   bool _isResendingOtp = false;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }

//   void _sendOtp() {
//     if (_formKey.currentState!.validate()) {
//       ref.read(authProvider.notifier).sendOtp(
//             _phoneController.text,
//             _selectedRole,
//           );
//     }
//   }

//   void _verifyOtp() {
//     if (_formKey.currentState!.validate()) {
//       ref.read(authProvider.notifier).verifyOtp(
//             _phoneController.text,
//             _otpController.text,
//             _selectedRole,
//           );
//     }
//   }

//   void _resendOtp() {
//     setState(() {
//       _isResendingOtp = true;
//     });
//     ref.read(authProvider.notifier).sendOtp(
//           _phoneController.text,
//           _selectedRole,
//         );
//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted) {
//         setState(() {
//           _isResendingOtp = false;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     final showOtpField = ref.watch(otpVisibilityProvider);

//     ref.listen<AsyncValue>(authProvider, (previous, next) {
//       if (next.hasError) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${next.error}')),
//         );
//       }

//       if (previous?.isLoading == true &&
//           next.isLoading == false &&
//           !next.hasError &&
//           _otpController.text.isEmpty) {
//         ref.read(otpVisibilityProvider.notifier).state = true;
//       }

//       if (previous?.isLoading == true &&
//           next is AsyncData &&
//           _otpController.text.isNotEmpty) {
//         // Close the modal and navigate to the intended destination
//         Navigator.of(context).pop();
//         final destination = widget.redirectTo ?? '/';
//         context.go(destination);
//       }
//     });

//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           DropdownButtonFormField<UserRole>(
//             value: _selectedRole,
//             decoration: const InputDecoration(labelText: 'Login as'),
//             items: UserRole.values.map((role) {
//               return DropdownMenuItem(
//                 value: role,
//                 child: Text(role.name.toUpperCase()),
//               );
//             }).toList(),
//             onChanged: (value) => setState(() => _selectedRole = value!),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _phoneController,
//             decoration: const InputDecoration(labelText: 'Phone Number'),
//             keyboardType: TextInputType.phone,
//             validator: showOtpField ? null : (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your phone number';
//               }
//               if (value.length < 10) {
//                 return 'Please enter a valid phone number (at least 10 digits)';
//               }
//               return null;
//             },
//           ),
//           if (showOtpField) ...[
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _otpController,
//               decoration: const InputDecoration(labelText: 'Enter OTP'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the OTP';
//                 }
//                 if (value.length < 6) {
//                   return 'Please enter a valid OTP';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: _isResendingOtp ? null : _resendOtp,
//                   child: _isResendingOtp
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Resend OTP'),
//                 ),
//               ],
//             ),
//           ],
//           const SizedBox(height: 24),
//           authState.isLoading
//               ? const CircularProgressIndicator()
//               : SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: showOtpField ? _verifyOtp : _sendOtp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: Text(
//                       showOtpField ? 'Verify OTP' : 'Send OTP',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
// }

class _LoginContentState extends ConsumerState<LoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _dialCodeController = TextEditingController(text: '+91'); // Default value
  UserRole _selectedRole = UserRole.ROLE_SELLER;
  bool _isResendingOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _dialCodeController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).sendOtp(
            _dialCodeController.text,
            _phoneController.text,
            _selectedRole,
          );
    }
  }


  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      print( _dialCodeController.text);
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
    final authState = ref.watch(authProvider);
    final showOtpField = ref.watch(otpVisibilityProvider);


    ref.listen<AsyncValue>(authProvider, (previous, next) {
      if (next.hasError) {
        // scaffoldMessengerKey.currentState?.showSnackBar(
        //   SnackBar(content: Text('Error: ${next.error}')),
        // );
              debugPrint(next.error.toString());

      }

      if (previous?.isLoading == true &&
          next.isLoading == false &&
          !next.hasError &&
          _otpController.text.isEmpty) {
        ref.read(otpVisibilityProvider.notifier).state = true;
      }

      if (previous?.isLoading == true &&
          next is AsyncData &&
          _otpController.text.isNotEmpty) {
        // Close the modal and navigate to the intended destination
        Navigator.of(context).pop();
        final destination = widget.redirectTo ?? '/';
        context.go(destination);
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
       
    if (authState.hasError)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          authState.error.toString(),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ),
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
          const SizedBox(height: 24),
          authState.isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: showOtpField ? _verifyOtp : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      showOtpField ? 'Verify OTP' : 'Send OTP',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class SignupContent extends ConsumerStatefulWidget {
  const SignupContent({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupContent> createState() => _SignupContentState();
}

// class _SignupContentState extends ConsumerState<SignupContent> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   UserRole _selectedRole = UserRole.seller;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       ref.read(authProvider.notifier).signup(
//             _nameController.text,
//             _emailController.text,
//             _phoneController.text,
//             _selectedRole,
//           );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);

//     ref.listen<AsyncValue>(authProvider, (_, state) {
//       if (!state.isLoading && !state.hasError) {
//         // If signup was successful, close the modal
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Account created successfully! Please login.')),
//         );
//       } else if (!state.isLoading && state.hasError) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${state.error}')),
//         );
//       }
//     });

//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           DropdownButtonFormField<UserRole>(
//             value: _selectedRole,
//             decoration: const InputDecoration(labelText: 'Sign up as'),
//             items: UserRole.values.map((role) {
//               return DropdownMenuItem(
//                 value: role,
//                 child: Text(role.name.toUpperCase()),
//               );
//             }).toList(),
//             onChanged: (value) => setState(() => _selectedRole = value!),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _nameController,
//             decoration: const InputDecoration(labelText: 'Name'),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your name';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _emailController,
//             decoration: const InputDecoration(labelText: 'Email'),
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               }
//               if (!value.contains('@')) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _phoneController,
//             decoration: const InputDecoration(labelText: 'Phone Number'),
//             keyboardType: TextInputType.phone,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your phone number';
//               }
//               if (value.length < 10) {
//                 return 'Please enter a valid phone number';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 24),
//           authState.isLoading
//               ? const CircularProgressIndicator()
//               : SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _submit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: const Text(
//                       'Sign Up',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
// }

// In your SignupContent widget, add these fields and update the _submit method:
class _SignupContentState extends ConsumerState<SignupContent> {
final _formKey = GlobalKey<FormState>();
final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _phoneController = TextEditingController();
final _dialCodeController = TextEditingController(text: '+91'); // Default value
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();
String _selectedGender = 'Female'; // Default value
UserRole _selectedRole = UserRole.ROLE_SELLER;

@override
void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _dialCodeController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  super.dispose();
}

void _submit() {
  if (_formKey.currentState!.validate()) {
    if (_passwordController.text != _confirmPasswordController.text) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    
    ref.read(authProvider.notifier).signup(
          _nameController.text,
          _emailController.text,
          _dialCodeController.text,
          _phoneController.text,
          _passwordController.text,
          _selectedRole,
          _selectedGender,
        );
  }
}

// And update the build method to include the new fields:
@override
Widget build(BuildContext context) {
  final authState = ref.watch(authProvider);

 ref.listen<AsyncValue>(authProvider, (_, state) {
  state.whenOrNull(
    data: (_) {
      Navigator.of(context).pop();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please login.'),
        ),
      );
    },
    error: (error, _) {
      debugPrint(error.toString());
    },
  );
});


  return Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (authState.hasError)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          authState.error.toString(),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ),
        DropdownButtonFormField<UserRole>(
          value: _selectedRole,
          decoration: const InputDecoration(labelText: 'Sign up as'),
          items: UserRole.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedRole = value!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: ['Male', 'Female', 'Other'].map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedGender = value!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        authState.isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
      ],
    ),
  );
}}
