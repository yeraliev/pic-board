import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  //sign in
  Future<UserCredential> signIn({required String email, required String password}) async {
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  //sign up
  Future<UserCredential> signUp({required String email, required String password}) async {
    return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  //change name
  Future<void> changeName({required String name}) async {
    return await currentUser?.updateDisplayName(name);
  }

  //log out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  //reset password method
  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  //delete account
  Future<void> deleteAccount({required String email, required String password}) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  //change password
  Future<void> changePassword({required String email, required String password, required String newPassword}) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  //set avatar or update avatar
  Future<void> changeAvatar({required String avatarPath}) async {
    await currentUser?.updatePhotoURL(avatarPath);
  }
}