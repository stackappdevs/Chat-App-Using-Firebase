
import 'package:chat_app/constants/string_constant.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService{


    AuthService authService = AuthService();

   CollectionReference collectionReference = FirebaseFirestore.instance.collection(tableUser);
   CollectionReference collectionReferenceMessage = FirebaseFirestore.instance.collection(tableChat);


  Future<void> insertData({String? name,String? id,String? status,String? email}) async {

    await collectionReference.doc('$id').set({
      "name" : name,
      "email": email,
      "status":status,
      "uid" : authService.auth.currentUser!.uid,
    });
  }


}