import 'package:flutter/material.dart';


class CommonElevatedButton extends StatelessWidget {
  
  final String? title;
  final Widget icon;
  final VoidCallback? function;
  
  
  CommonElevatedButton({Key? key,this.title,required this.icon,this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: function,
        icon: icon,
        label: Text('$title')
    );
  }
}



class CommonElevatedButtonChat extends StatelessWidget {

  final String? title;
  final VoidCallback? function;

  const CommonElevatedButtonChat({Key? key,this.title,this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: function,
      child: Text("$title"),
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(fontSize: height*0.025),
      ),
    );
  }
}


