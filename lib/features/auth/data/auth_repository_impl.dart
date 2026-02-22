import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../domain/user_entity.dart';
import 'user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUserData();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore, if not create as 'user' role
        final doc = await _firestore.collection(AppConstants.usersPath).doc(user.uid).get();
        if (!doc.exists) {
          final newUser = UserModel(uid: user.uid, email: user.email!, role: 'user');
          await _firestore.collection(AppConstants.usersPath).doc(user.uid).set(newUser.toMap());
          return newUser;
        }
        return UserModel.fromMap(doc.data()!, user.uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection(AppConstants.usersPath).doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, user.uid);
      }
    }
    return null;
  }
}
