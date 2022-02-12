
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  FirebaseAuth auth = FirebaseAuth.instance;


  Future<UserCredential> createAccount(String email,String password) async {
    return  await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> loginAccount(String email,String password) async {
    return  await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut()async{
    await  auth.signOut();
  }
}
