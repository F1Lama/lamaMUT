import 'package:firebase_core/firebase_core.dart'; // استيراد Firebase Core
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // استيراد ملف التكوين
import 'package:map/screens/add_admin_screen.dart';
import 'package:map/screens/modifyAdminScreen.dart';
import 'package:map/screens/login_screen.dart';
//import 'package:map/screens/logout.dart';
import 'package:map/screens/welcome_screen.dart';

void main() async {
  // تهيئة Widgets وFirebase
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Firebase باستخدام التكوين من firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // تشغيل التطبيق
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إزالة شعار "Debug"
      title: 'Mutabie App', // اسم التطبيق
      theme: ThemeData(
        primarySwatch: Colors.blue, // لون التطبيق الأساسي
      ),
      initialRoute: '/', // المسار المبدئي للتطبيق
      routes: {
        '/': (context) => const WelcomeScreen(), // شاشة الترحيب
        '/login': (context) => LoginSchoolScreen(), // شاشة تسجيل الدخول
        //'/logout': (context) => LogoutScreen(), // شاشة تسجيل الخروج
        '/AddAdminScreen': (context) => AddAdminScreen(), // شاشة إضافة مشرف
        '/AdminScreen': (context) => AdminListScreen(), // شاشة قائمة المشرفين

        // '/AdminScreen': (context) => AdminListScreen(), // شاشة قائمة المشرفين
      },
    );
  }
}
