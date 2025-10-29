import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/User.dart' as model;

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = fb_auth.FirebaseAuth.instance;
  final _collection = 'users';
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // ---------------------------------------------------------------------------
  /// 🟢 Thêm hoặc cập nhật user vào Firestore (tự đồng bộ)
  Future<void> addOrUpdateUser(model.User user) async {
    final ref = _firestore.collection(_collection).doc(user.id);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.update(user.toFirestore());
    } else {
      await ref.set(user.toFirestore());
    }
  }

  /// 🔵 Lấy tất cả user
  Future<List<model.User>> getAllUsers() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => model.User.fromFirestore(doc)).toList();
  }

  /// 🟡 Lấy user theo ID
  Future<model.User?> getUserById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return model.User.fromFirestore(doc);
  }

  /// 🟠 Cập nhật user
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update(data);
  }

  /// 🔴 Xóa user
  Future<void> deleteUser(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // 🔐 Đăng ký bằng email & mật khẩu
  Future<void> registerUser(model.User user, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: user.email ?? "",
      password: password,
    );

    final firebaseUser = credential.user!;
    final newUser = model.User(
      id: firebaseUser.uid,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      phoneNumbers: user.phoneNumbers,
      addresses: user.addresses,
      loginMethodId: 'local',
      roleId: 'customer',
    );

    // ✅ Lưu thông tin vào Firestore
    await addOrUpdateUser(newUser);
  }

  // ---------------------------------------------------------------------------
  // 🔑 Đăng nhập bằng email & mật khẩu
  Future<model.User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;
      final uid = firebaseUser.uid;

      // 🔄 Đồng bộ lại thông tin mới nhất của Auth vào Firestore
      await addOrUpdateUser(
        model.User(
          id: uid,
          name: firebaseUser.displayName,
          email: firebaseUser.email,
          avatar: firebaseUser.photoURL,
          phoneNumbers: [],
          addresses: [],
          loginMethodId: 'local',
          roleId: 'customer',
        ),
      );

      // ✅ Lấy thông tin người dùng trong Firestore
      return await getUserById(uid);
    } on fb_auth.FirebaseAuthException catch (e) {
      print("⚠️ Lỗi đăng nhập Firebase Auth: ${e.message}");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Đăng nhập Google
  Future<model.User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) return null;

    final newUser = model.User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      avatar: firebaseUser.photoURL,
      phoneNumbers: [firebaseUser.phoneNumber ?? ''],
      addresses: [],
      loginMethodId: 'google',
      roleId: 'customer',
    );

    await addOrUpdateUser(newUser);
    return newUser;
  }

  // ---------------------------------------------------------------------------
  // 🔹 Đăng nhập Facebook
  Future<model.User?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['', 'public_profile'],
    );

    if (result.status == LoginStatus.success) {
      final credential = fb_auth.FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final newUser = model.User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName,
        email: firebaseUser.email ?? '',
        avatar: firebaseUser.photoURL,
        phoneNumbers: [firebaseUser.phoneNumber ?? ''],
        addresses: [],
        loginMethodId: 'facebook',
        roleId: 'customer',
      );

      // 🔄 Đồng bộ Auth → Firestore
      await addOrUpdateUser(newUser);
      return newUser;
    } else {
      throw Exception('Facebook login failed: ${result.status}');
    }
  }

  Future<void> lockAccount(String userId) async {
    await _firestore.collection(_collection).doc(userId).update({
      'status': false,
    });
  }

  // Unlock a user's account
  Future<void> unlockAccount(String userId) async {
    await _firestore.collection(_collection).doc(userId).update({
      'status': true,
    });
  }



  /// 🚪 Đăng xuất
  Future<void> signOut() async {
    try {
      // Đăng xuất Firebase
      await _auth.signOut();

      // Nếu có đăng nhập Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      }

      // Nếu có đăng nhập Facebook
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('⚠️ Lỗi khi đăng xuất: $e');
    }
  }
}