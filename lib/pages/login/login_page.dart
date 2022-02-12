import 'package:chat_app/constants/string_constant.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/utills/validator.dart';
import 'package:chat_app/widget/comman_elevated_button.dart';
import 'package:chat_app/widget/common_sizedBox.dart';
import 'package:chat_app/widget/common_text.dart';
import 'package:chat_app/widget/common_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatLogin extends StatefulWidget {
  const ChatLogin({Key? key}) : super(key: key);

  @override
  _ChatLoginState createState() => _ChatLoginState();
}

class _ChatLoginState extends State<ChatLogin> {

  GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  AuthService firebaseHelper = AuthService();
  Validation validation = Validation();


  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: (isLoading) ? Center(child: CircularProgressIndicator(),) : Container(
        margin: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  child: TextData(
                    text: welcomeUser,
                    fontSize: height * 0.04,
                    fontWeight: FontWeight.bold,
                  )),
              Container(
                  alignment: Alignment.centerLeft,
                  child: const TextData(
                    text: login,
                  )),
              SizedBox(
                height: height * 0.1,
              ),
              Form(
                  key: formKey1,
                  child: Column(
                    children: [

                      emailTextField(),
                      const CommonSizedBox(),

                      passwordTextField(),
                    ],
                  )),
              SizedBox(
                height: height * 0.1,
              ),
              SizedBox(
                height: height * 0.08,
                width: width * 0.8,
                child: loginButton(),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        'chat_registration', (route) => false);
                  },
                  child: const TextData(
                    text: 'Create Account',
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
  }
  emailTextField(){
    return    TextFormFieldData(
      controller: emailController,
      title: enterEmail,
      icon: const Icon(Icons.email),
      textInputAction: TextInputAction.next,
      keyBordType: TextInputType.emailAddress,
      validate: (val) {
        return validation.validateEmail(val);
      },
    );
  }

  passwordTextField(){
    return   TextFormFieldData(
      controller: passwordController,
      validate: (val) {
       return  validation.validatePassword(val);
      },
      obscureText: true,
      title: enterPassword,
      icon: const Icon(Icons.lock),
      textInputAction: TextInputAction.done,
      keyBordType: TextInputType.number,
    );
  }

  loginButton(){
    return CommonElevatedButtonChat(
      function: ()async{

        if (formKey1.currentState!.validate()) {
          try {
            setState(() {
              isLoading=true;
            });

            UserCredential userCredential =
                await firebaseHelper.loginAccount(
                emailController.text, passwordController.text);

            if (userCredential.user != null) {
              setState(() {
                isLoading=false;
              });
              emailController.clear();
              passwordController.clear();
              Navigator.of(context).pushNamedAndRemoveUntil('chat_homepage', (route) => false);
            }


          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('No user found for that email.')));
              Navigator.of(context).pushNamedAndRemoveUntil('chat_registration', (route) => false);
            } else if (e.code == 'wrong-password') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(invalidPassword)));
              passwordController.clear();
              Navigator.of(context).pushNamedAndRemoveUntil('chat_login', (route) => false);
            }
          } catch (e) {
            print(e);
          }
        }
      },
      title: 'Login',
    );
  }
}
