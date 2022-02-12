import 'package:chat_app/pages/login/login_page.dart';
import 'package:chat_app/pages/sign_up/sign_up_page.dart';
import 'package:chat_app/pages/user_list/user_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

    runApp(MaterialApp(

        initialRoute: 'chat_login',

        routes: {
          'chat_registration': (context) => const ChatRegistration(),
          'chat_login': (context) => const ChatLogin(),
          'chat_homepage': (context) => const ChatHomePage(),
        },
    ));
}