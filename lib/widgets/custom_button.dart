import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const CustomButton({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 60,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: const Color.fromARGB(255, 1, 113, 189),
        textColor: Colors.white,
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
