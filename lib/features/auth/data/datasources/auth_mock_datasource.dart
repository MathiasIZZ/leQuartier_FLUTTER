import '../../domain/models/user_model.dart';

class AuthMockDatasource {
  static final Map<String, UserModel> _usersStore = {
    'mock_user_1': UserModel(
      id: 'mock_user_1',
      phoneNumber: '+33612345678',
      fullName: 'Marie Curie',
      pseudo: 'Marie37',
      auraScore: 120,
      createdAt: DateTime.now(),
    ),
    'mock_user_2': UserModel(
      id: 'mock_user_2',
      phoneNumber: '+33698765432',
      fullName: 'Thomas Edison',
      pseudo: 'TomEdison',
      auraScore: 85,
      createdAt: DateTime.now(),
    ),
  };

  UserModel? _currentUser;

  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<UserModel> verifyOtp({required String phoneNumber, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp != '123456') {
      throw Exception('Code OTP invalide. (Indice : 123456)');
    }

    _currentUser = _usersStore.values.firstWhere(
      (u) => u.phoneNumber == phoneNumber,
      orElse: () {
        final isNew = phoneNumber.endsWith('00');
        final newUser = UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          phoneNumber: phoneNumber,
          fullName: isNew ? '' : 'Citoyen Tours',
          pseudo: isNew ? '' : 'Citoyen37',
          auraScore: 100,
          createdAt: DateTime.now(),
        );
        _usersStore[newUser.id] = newUser;
        return newUser;
      },
    );

    return _currentUser!;
  }

  Future<UserModel> updateProfile({required String fullName, required String pseudo}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) {
      throw Exception('Aucun utilisateur connecté');
    }
    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      pseudo: pseudo,
    );
    _usersStore[_currentUser!.id] = _currentUser!;
    return _currentUser!;
  }

  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  static UserModel? getUserById(String userId) {
    return _usersStore[userId];
  }

  static void adjustAura(String userId, int delta) {
    final user = _usersStore[userId];
    if (user != null) {
      final updated = user.copyWith(auraScore: user.auraScore + delta);
      _usersStore[userId] = updated;
    }
  }
}
