import 'package:firebase_core/firebase_core.dart'; // استيراد Firebase Core
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/providers/TeacherProvider.dart';
import 'package:map/providers/UserProvider.dart';
import 'package:map/screens/change_location_screen.dart';
import 'package:map/screens/map_picker_screen.dart';
import 'package:map/screens/map_screen.dart';
import 'package:provider/provider.dart'; // استيراد Provider
import 'firebase_options.dart'; // استيراد ملف التكوين
import 'screens/add_admin_screen.dart';
import 'screens/modifyAdminScreen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  // تهيئة Widgets وFirebase
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Firebase باستخدام التكوين من firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // تشغيل التطبيق
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/AddAdminScreen': (context) => AddAdminScreen(), // شاشة إضافة مشرف
        '/AdminScreen': (context) => AdminListScreen(), // شاشة قائمة المشرفين
             '/MapScreen': (context) => MapScreen(), // إذا كنت تستخدم شاشة الخريطة
        '/map_picker': (context) => MapPickerScreen(),
      },
    );
  }
}
