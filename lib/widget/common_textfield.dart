import 'package:flutter/material.dart';



class TextFormFieldData extends StatelessWidget {
  final TextEditingController? controller;
  final bool obscureText;
  final FormFieldValidator<String>? validate;
  final TextInputAction? textInputAction;
  final TextInputType?  keyBordType;
  final Icon? icon;
  final String? title;


      TextFormFieldData({Key? key,this.controller,this.validate,this.title,this.obscureText=false,this.icon,this.textInputAction,this.keyBordType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validate,
      textInputAction: textInputAction,
      keyboardType: keyBordType,
      decoration: InputDecoration(
          prefixIcon: icon,
          hintText: title,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
      ),
    );
  }
}



class ChatTextField extends StatelessWidget {
  final String? title;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final TextInputType?  keyBordType;
  final ValueChanged<String>? onChanged;
      ChatTextField({Key? key,this.title,this.keyBordType,this.prefixIcon,this.suffixIcon,this.controller,this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          hintText: title,
          border:  InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
      ),
      controller: controller,
      keyboardType: keyBordType,
      minLines: 1,
      maxLines: 5,
      onChanged: onChanged,
    );
  }
}

