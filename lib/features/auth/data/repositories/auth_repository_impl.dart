import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import 'package:le_quartier/core/network/dio_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthMockDatasource? _mockDatasource;
  final AuthRemoteDatasource? _remoteDatasource;
  final bool _useMock;

  const AuthRepositoryImpl({
    AuthMockDatasource? mockDatasource,
    AuthRemoteDatasource? remoteDatasource,
    bool useMock = true,
  })  : _mockDatasource = mockDatasource,
        _remoteDatasource = remoteDatasource,
        _useMock = useMock;

  @override
  Future<void> sendOtp(String phoneNumber) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.sendOtp(phoneNumber);
    }
    return _remoteDatasource!.sendOtp(phoneNumber);
  }

  @override
  Future<UserModel> verifyOtp({required String phoneNumber, required String otp}) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.verifyOtp(phoneNumber: phoneNumber, otp: otp);
    }
    return _remoteDatasource!.verifyOtp(phoneNumber: phoneNumber, otp: otp);
  }

  @override
  Future<UserModel> updateProfile({required String fullName, required String pseudo}) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.updateProfile(fullName: fullName, pseudo: pseudo);
    }
    return _remoteDatasource!.updateProfile(fullName: fullName, pseudo: pseudo);
  }

  @override
  Future<UserModel?> getCurrentUser() {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.getCurrentUser();
    }
    return _remoteDatasource!.getCurrentUser();
  }

  @override
  Future<void> signOut() {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.signOut();
    }
    return _remoteDatasource!.signOut();
  }
}

final authMockDatasourceProvider = Provider<AuthMockDatasource>((ref) {
  return AuthMockDatasource();
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRemoteDatasource(dio, secureStorage);
});

// Set to false when connecting to the real Spring Boot API
const bool kUseMockAuth = true;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    mockDatasource: ref.watch(authMockDatasourceProvider),
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    useMock: kUseMockAuth,
  );
});
