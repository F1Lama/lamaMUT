import 'package:flutter/material.dart';

class CustomButtonAuth extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomButtonAuth({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 60,
      minWidth: 260,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Color.fromARGB(255, 1, 113, 189),
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text(title, style: TextStyle(fontSize: 20)),
    );
  }
}
