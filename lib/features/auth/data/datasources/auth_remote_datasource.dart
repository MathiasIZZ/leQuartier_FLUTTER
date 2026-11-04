import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/user_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRemoteDatasource(this._dio, this._secureStorage);

  Future<void> sendOtp(String phoneNumber) async {
    await _dio.post('/auth/phone-login', data: {'phoneNumber': phoneNumber});
  }

  Future<UserModel> verifyOtp({required String phoneNumber, required String otp}) async {
    final response = await _dio.post('/auth/verify-otp', data: {
      'phoneNumber': phoneNumber,
      'otp': otp,
    });

    final data = response.data;
    final token = data['token'] as String?;
    if (token != null) {
      await _secureStorage.write(key: 'jwt_token', value: token);
    }

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> updateProfile({required String fullName, required String pseudo}) async {
    final response = await _dio.put('/auth/profile', data: {
      'fullName': fullName,
      'pseudo': pseudo,
    });
    return UserModel.fromJson(response.data);
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) return null;

      final response = await _dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _secureStorage.delete(key: 'jwt_token');
  }
}
