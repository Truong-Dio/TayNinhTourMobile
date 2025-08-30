import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phoneNumber,
    required super.role,
    required super.isActive,
    super.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt,
    );
  }
  
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
