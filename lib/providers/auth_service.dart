import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutriapp/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebase(User? user) {
    return user != null
        ? UserModel(uid: user.uid, displayName: user.displayName ?? '', email: user.email ?? '')
        : null;
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebase(result.user);
    } catch (e) {
      print('SignIn Error: $e');
      return null;
    }
  }

  Future<UserModel?> registerWithEmailPassword(String email, String password) async {
    try {
     
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return _userFromFirebase(result.user);
    } catch (e) {
      print('Register Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
