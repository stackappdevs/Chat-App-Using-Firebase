import 'package:chat_app/constants/string_constant.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/user_service.dart';
import 'package:chat_app/utills/validator.dart';
import 'package:chat_app/widget/comman_elevated_button.dart';
import 'package:chat_app/widget/common_sizedBox.dart';
import 'package:chat_app/widget/common_text.dart';
import 'package:chat_app/widget/common_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatRegistration extends StatefulWidget {
  const ChatRegistration({Key? key}) : super(key: key);

  @override
  _ChatRegistrationState createState() => _ChatRegistrationState();
}

class _ChatRegistrationState extends State<ChatRegistration> {

  UserService userService = UserService();
  AuthService authService = AuthService();
  Validation validation = Validation();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;



  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: (isLoading) ? Center(child: CircularProgressIndicator(),)  : Container(
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
                    text: signUp,
                  )),
              SizedBox(
                height: height * 0.1,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [

                    nameTextField(),
                    const CommonSizedBox(),

                    emailTextField(),
                    const CommonSizedBox(),

                    passwordTextField(),

                  ],
                ),
              ),
              SizedBox(
                height: height * 0.1,
              ),
              Container(
                height: height*0.08,
                width: width*0.8,
                child: signUpButton(),
              ),
              TextButton(onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil('chat_login', (route) => false);
              }, 
                  child: const TextData(text: 'Login',fontWeight: FontWeight.bold,)),
            ],
          ),
        ),
      ),
    );
  }

  nameTextField(){
      return   TextFormFieldData(
        controller: nameController,
        title: enterName,
        icon: const Icon(Icons.person),
        textInputAction: TextInputAction.next,
        keyBordType: TextInputType.name,
        validate: (val){
          return validation.validateName(val);
        },
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
        return  validation.validateEmail(val);
      },
    );
  }

  passwordTextField(){
    return   TextFormFieldData(
      controller: passwordController,
      validate: (val) {
         return validation.validatePassword(val);
      },
      obscureText: true,
      title: enterPassword,
      icon: Icon(Icons.lock),
      textInputAction: TextInputAction.done,
      keyBordType: TextInputType.number,
    );
  }

  signUpButton(){
    return CommonElevatedButtonChat(
        function: ()async{
          if(formKey.currentState!.validate()){
            setState(() {
              isLoading = true;
            });
            try{
              UserCredential userCredential = await authService.createAccount(emailController.text, passwordController.text);

              userCredential.user!.updateDisplayName(nameController.text);
              if(userCredential.user != null){
                setState(() {
                  isLoading=false;
                });

                userService.insertData(name: nameController.text,email: emailController.text,id: authService.auth.currentUser!.uid,status: ' ');

                Navigator.of(context).pushNamedAndRemoveUntil('chat_homepage', (route) => false);

              }

              nameController.clear();
              emailController.clear();
              passwordController.clear();

            }
            on FirebaseAuthException catch(e){
              if (e.code == 'weak-password') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter strong password.'))
                );
              } else if (e.code == 'email-already-in-use') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(emailExist))
                );
              }
            }
            catch(e){
              print(e);
            }

            FocusScope.of(context).unfocus();
            setState(() {});
          }
        },
        title: 'Create Account',
    );
  }

}
