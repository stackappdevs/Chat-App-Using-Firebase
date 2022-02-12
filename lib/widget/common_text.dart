import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final Color? clr;
  final double? fontSize;
  final String? title;
  const CommonText({Key? key,this.clr,this.fontSize, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('$title',style: TextStyle(color: clr,fontSize: fontSize),);
  }
}



class TextData extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? height,fontSize;
  final FontWeight? fontWeight;
  const TextData({Key? key,this.text,this.color,this.fontWeight,this.height,this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('$text',style: TextStyle(color: color,height: height,fontWeight: fontWeight,fontSize: fontSize),);
  }
}