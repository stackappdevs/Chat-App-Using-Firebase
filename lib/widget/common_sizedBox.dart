import 'package:flutter/material.dart';


class CommonSizedBox extends StatelessWidget {
  const CommonSizedBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return  SizedBox(
      height: height * 0.02,
    );
  }
}
