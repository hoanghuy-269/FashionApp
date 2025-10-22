import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/User.dart' as model;

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = fb_auth.FirebaseAuth.instance;
  final _collection = 'users';

  /// 🟢 Thêm user vào Firestore
  Future<void> addUser(model.User user) async {
    await _firestore
        .collection(_collection)
        .doc(user.id)
        .set(user.toFirestore());
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
      password: password,
      avatar: user.avatar,
      phoneNumbers: user.phoneNumbers,
      addresses: user.addresses,
      loginMethodId: 'local',
      roleId: 'customer',
    );

    await addUser(newUser);
  }

  /// 🔐 Đăng nhập bằng email & mật khẩu
  Future<model.User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final user = await getUserById(uid);
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("⚠️ Lỗi đăng nhập Firebase Auth: ${e.message}");
      rethrow;
    } catch (e) {
      print("⚠️ Lỗi không xác định khi đăng nhập: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Đăng nhập Google
  Future<model.User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) return null;

    // 🔹 Kiểm tra xem user có tồn tại trong Firestore chưa
    final userDoc =
        await _firestore.collection(_collection).doc(firebaseUser.uid).get();
    if (!userDoc.exists) {
      final newUser = model.User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName,
        email: firebaseUser.email ?? '',
        password: '',
        avatar: firebaseUser.photoURL,
        phoneNumbers: [firebaseUser.phoneNumber ?? ''],
        addresses: [],
        loginMethodId: 'google',
        roleId: 'customer',
      );
      await addUser(newUser);
    }

    // ✅ Dùng fromMap thay vì fromFirestore
    return model.User.fromMap({
      'id': firebaseUser.uid,
      'name': firebaseUser.displayName,
      'email': firebaseUser.email,
      'avatar': firebaseUser.photoURL,
      'loginMethodId': 'google',
      'phoneNumbers': [firebaseUser.phoneNumber ?? ''],
      'addresses': [],
      'roleId': 'customer',
    });
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

      final userDoc =
          await _firestore.collection(_collection).doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        final newUser = model.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName,
          email: firebaseUser.email ?? '',
          password: '',
          avatar: firebaseUser.photoURL,
          phoneNumbers: [firebaseUser.phoneNumber ?? ''],
          addresses: [],
          loginMethodId: 'facebook',
          roleId: 'customer',
        );
        await addUser(newUser);
      }

      // 🔹 Trả về user từ dữ liệu Auth (Map)
      return model.User.fromMap({
        'id': firebaseUser.uid,
        'name': firebaseUser.displayName,
        'email': firebaseUser.email,
        'avatar': firebaseUser.photoURL,
        'loginMethodId': 'facebook',
        'phoneNumbers': [firebaseUser.phoneNumber ?? ''],
        'addresses': [],
        'roleId': 'customer',
      });
    } else {
      throw Exception('Facebook login failed: ${result.status}');
    }
  }

  /// 🚪 Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
