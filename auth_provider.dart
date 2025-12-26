import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cph4/model/user_model.dart';
import 'package:cph4/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider extends ChangeNotifier{

  final FirebaseFirestore db= FirebaseFirestore.instance;
  final AuthService authService = AuthService();

  UserModel? user;
  bool isloading = true;
  bool  get isAdmin => user?.role == "admin";




  AuthProvider() {
   checkAuth();
  }

  Future<void> checkAuth()async{
    final firebaseuser = await authService.authuser;
    final doc = await db.collection('users').doc(firebaseuser.uid).get();
    user = UserModel.fromMap(doc.data(), doc.id);
    isloading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password)async{
    final firebaseuser = await authService.login(email, password);
    final doc = await db.collection('users').doc(firebaseuser!.uid).get();
    user = UserModel.fromMap(doc.data(), doc.id);
  }

  Future<void> logout() async{
    final firebaseuser = await authService.logout();
    user = null;
    notifyListeners();
  }
}