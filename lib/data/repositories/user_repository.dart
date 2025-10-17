import '../models/User.dart';
import '../sources/firebase_service.dart';

class UserRepository {
  final FirebaseService _firebaseService;

  UserRepository(this._firebaseService);

  Future<String> registerUser(User user) async {
    final exists = await _firebaseService.checkUserExists(user.username ?? '');
    if (exists) {
      return 'Username already exists';
    }

    await _firebaseService.createUser(user);
    return 'Registration successful';
  }

  Future<User?> getUser(String usernameOrEmail) async {
    return await _firebaseService.getUserByAccount(usernameOrEmail);
  }

  Future<void> updateUser(User user) async {
    await _firebaseService.updateUser(user);
  }

  Future<void> deleteUser(String userId) async {
    await _firebaseService.deleteUser(userId);
  }
}
