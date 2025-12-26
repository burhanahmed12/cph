import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth Auth = FirebaseAuth.instance;

  User? get authuser => Auth.currentUser;


  Future<User?> login(String email, String password) async {
    final result = await Auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
    return result.user;
  }

  Future<void> logout() async {
    await Auth.signOut();
  }

}