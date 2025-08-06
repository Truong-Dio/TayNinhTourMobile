import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
    required this.isActive,
    this.createdAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phoneNumber,
    role,
    isActive,
    createdAt,
  ];
}
