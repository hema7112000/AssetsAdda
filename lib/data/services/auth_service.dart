// data/services/auth_service.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate_360/data/models/user_model.dart';
import 'dart:async'; 
import 'dart:io';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  User? _currentUser;
  bool _isInitialized = false;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Replace with your actual API base URL
  final String baseUrl = 'http://72.61.236.54:9898/api/assetsadda-service';

  User? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  // Initialize the service and check for existing session
  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    
    if (token != null && userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
      } catch (e) {
        // If there's an error parsing the user data, clear the session
        await clearSession();
      }
    }
     _isInitialized = true;
  }

// Future<void> sendOtp(
//   String dialCode,
//   String phoneNumber,
//   UserRole role,
// ) async {
//   try {
//     final response = await http
//         .post(
//           Uri.parse('$baseUrl/auth/send-otp'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'dialCode': dialCode,
//             'mobileNumber': phoneNumber,
//             'role': role.name,
//           }),
//         )
//         .timeout(const Duration(seconds: 10));

//     if (response.statusCode != 200) {
//       final errorData = jsonDecode(response.body);
//       print(errorData);
//       throw AuthException(
//         errorData['message'] ?? 'Failed to send OTP',
//       );
//     }
//   } 
//   on AuthException {
//   rethrow;
//   } 
//   on TimeoutException {
//     throw AuthException(
//       'Request timed out. Please check your internet connection.',
//     );
//   } on SocketException {
//     throw AuthException(
//       'No internet connection. Please check your network.',
//     );
//   } catch (e) {
//     throw AuthException(
//       'Failed to send OTP. Please try again.',
//     );
//   }
// }

  Future<Map<String, dynamic>> sendOtp(
    String dialCode,
    String phoneNumber,
    UserRole role,
  ) async {
    // Simulate API call success without calling real API
    await Future.delayed(const Duration(milliseconds: 500));

    // Return the values as a result
    return {
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
Future<User> verifyOtp(
  String dialCode,
  String phoneNumber,
  String otp,
  UserRole role,
) async {
  try {
    final response = await http
        .post(
          Uri.parse('$baseUrl/signin/otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'dialCode': dialCode,
            'mobileNum': phoneNumber,
            'otp': otp,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final responseData = jsonDecode(response.body);
    print(responseData);
    if (response.statusCode == 200) {
      final user = User.fromJson(responseData);
      await saveSession(user);
      _currentUser = user;
      return user;
    } else {
      final errorData = jsonDecode(response.body);
      throw AuthException(
        errorData['message'] ?? 'Invalid OTP or login failed',
      );
    }
  } on AuthException {
    rethrow;
  } on TimeoutException {
    throw AuthException(
      'Request timed out. Please check your internet connection and try again.',
    );
  } on SocketException {
    throw AuthException(
      'No internet connection. Please check your network.',
    );
  } on FormatException {
    throw AuthException(
      'Invalid server response.',
    );
  } catch (e) {
    throw AuthException(
      'Login failed. Please try again.',
    );
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
  try {
    final response = await http
        .post(
          Uri.parse('$baseUrl/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'dialCode': dialCode,
            'mobileNumber': phoneNumber,
            'password': password,
            'enabled': true,
            'fullName': name,
            'gender': gender,
            'email': email,
            'roles': [
              {
                'id': _getRoleId(role),
                'name': role.name,
              }
            ],
          }),
        )
        .timeout(const Duration(seconds: 10)); 

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      print(errorData);
      throw AuthException(
        errorData['message'] ?? 'Failed to create account',
      );
    }
  } 
  on AuthException {
  rethrow;
  }
on TimeoutException {
    throw AuthException(
      'Request timed out. Please check your internet connection and try again.',
    );
  } on SocketException {
    throw AuthException(
      'No internet connection. Please check your network.',
    );
  } on FormatException {
    throw AuthException(
      'Invalid server response.',
    );
  } catch (e) {
    throw AuthException(
      'Failed to create account. Please try again.',
    );
  }
}


  Future<void> logout() async {
    try {
      // If you have a logout endpoint, call it here
      // final token = await getAuthToken();
      // if (token != null) {
      //   await http.post(
      //     Uri.parse('$baseUrl/auth/logout'),
      //     headers: {
      //       'Content-Type': 'application/json',
      //       'Authorization': 'Bearer $token',
      //     },
      //   );
      // }
      
      await clearSession();
      _currentUser = null;
    } catch (e) {
      // Even if the API call fails, clear local session
      await clearSession();
      _currentUser = null;
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Helper method to get role ID based on UserRole enum
  int _getRoleId(UserRole role) {
    switch (role) {
      case UserRole.ROLE_SELLER:
        return 1;
      case UserRole.ROLE_BUYER:
        return 2;
      case UserRole.ROLE_AGENT:
        return 3;
      case UserRole.ROLE_ADMIN:
        return 4;
      default:
        return 1;
    }
  }
}

// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());