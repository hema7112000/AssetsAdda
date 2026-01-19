// data/models/user_model.dart

// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { 
  ROLE_SELLER, 
  ROLE_BUYER, 
  ROLE_AGENT, 
  ROLE_ADMIN,
  ROLE_AGENTPROVIDER 
}

@JsonSerializable()
class User {
  final String id;
  final String fullName;
  final String email;
  final String dialCode;
  final String mobileNumber;
  final String token;
  final UserRole role;
  final String gender;
  final bool isVerified;
  final List<Role> roles;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dialCode,
    required this.mobileNumber,
    required this.token,
    required this.role,
    required this.gender,
    this.isVerified = false,
    this.roles = const [],
  });

factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['userId'].toString(),
    fullName: '',
    email: json['email'] ?? '',
    dialCode: '',
    mobileNumber: '',
    token: json['token'] ?? '',
    role: json['roles'] != null && json['roles'].isNotEmpty
        ? UserRole.values.firstWhere(
            (r) => r.name == json['roles'][0].replaceAll('ROLE_', ''),
            orElse: () => UserRole.ROLE_BUYER,
          )
        : UserRole.ROLE_BUYER,
    gender: '',
    isVerified: json['enabled'] ?? false,
    roles: json['roles'] != null
        ? (json['roles'] as List)
            .map<Role>((r) => Role(id: 0, name: r.toString()))
            .toList()
        : [],
  );
}

  // factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  // For backward compatibility
  String get name => fullName;
  String get phone => '$dialCode$mobileNumber';
}

@JsonSerializable()
class Role {
  final int id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}