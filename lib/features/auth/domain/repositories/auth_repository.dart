import '../models/user_model.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp({required String phoneNumber, required String otp});
  Future<UserModel> updateProfile({required String fullName, required String pseudo});
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
}
