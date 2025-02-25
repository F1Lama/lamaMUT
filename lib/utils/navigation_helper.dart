import 'package:flutter/material.dart';

class NavigationHelper {
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
