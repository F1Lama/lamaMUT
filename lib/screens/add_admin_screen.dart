import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:map/widgets/custom_button_auth.dart';
import 'package:map/widgets/custom_text_field.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddAdminScreen(),
    );
  }
}

class AddAdminScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final String senderEmail = "your-email@example.com"; // ✉️ بريد المشرف
  final String senderPassword = "your-app-password"; // 🔑 كلمة مرور التطبيق

  // دالة التحقق من التكرار
  Future<bool> isAdminDuplicate(String id, String email, String phone) async {
    var querySnapshot =
        await FirebaseFirestore.instance
            .collection('admins')
            .where('id', isEqualTo: id)
            .get();
    if (querySnapshot.docs.isNotEmpty) return true;
    querySnapshot =
        await FirebaseFirestore.instance
            .collection('admins')
            .where('email', isEqualTo: email)
            .get();
    if (querySnapshot.docs.isNotEmpty) return true;
    querySnapshot =
        await FirebaseFirestore.instance
            .collection('admins')
            .where('phone', isEqualTo: phone)
            .get();
    if (querySnapshot.docs.isNotEmpty) return true;
    return false;
  }

  // دالة إضافة الإداري
  Future<void> addAdmin(BuildContext context) async {
    String name = nameController.text.trim();
    String id = idController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty || id.isEmpty || phone.isEmpty || email.isEmpty) {
      showSnackBar(context, "يجب ملء جميع الحقول قبل الإضافة");
      return;
    }

    final phoneRegex = RegExp(r'^05\d{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      showSnackBar(
        context,
        "رقم الجوال غير صحيح. يجب أن يبدأ بـ 05 ويتكون من 10 أرقام",
      );
      return;
    }

    bool isDuplicate = await isAdminDuplicate(id, email, phone);
    if (isDuplicate) {
      showSnackBar(context, "هذا الإداري مسجل مسبقًا، لا يمكن تكرار البيانات.");
      return;
    }

    try {
      String password = generateRandomPassword();
      await FirebaseFirestore.instance.collection('admins').add({
        'name': name,
        'id': id,
        'phone': phone,
        'email': email,
        'password': password,
        'createdAt': Timestamp.now(),
      });
      await sendEmail(email, name, id, password);
      showSnackBar(
        context,
        "تمت إضافة الإداري بنجاح، وتم إرسال كلمة المرور عبر البريد",
      );
      nameController.clear();
      idController.clear();
      phoneController.clear();
      emailController.clear();
    } catch (e) {
      print("Error adding admin: $e");
      showSnackBar(context, "حدث خطأ أثناء الإضافة");
    }
  }

  // دالة إرسال البريد الإلكتروني مع دعم جميع أنواع الإيميلات
  Future<void> sendEmail(
    String recipientEmail,
    String name,
    String adminId,
    String password,
  ) async {
    final smtpServer = getSmtpServer(senderEmail, senderPassword);
    final message =
        Message()
          ..from = Address(senderEmail, "Mutabie App")
          ..recipients.add(recipientEmail)
          ..subject = "تم تسجيلك في تطبيق متابع"
          ..text =
              "مرحبًا $name،\n\n"
              "تم تسجيلك بنجاح في تطبيق متابع.\n"
              "بيانات تسجيل الدخول الخاصة بك:\n"
              "رقم الإداري: $adminId\n"
              "كلمة المرور: $password\n\n"
              "يمكنك الآن تسجيل الدخول إلى التطبيق.\n\n"
              "تحياتنا، فريق متابع.";

    try {
      await send(message, smtpServer);
      print("تم إرسال البريد الإلكتروني بنجاح إلى $recipientEmail");
    } catch (e) {
      print("خطأ في إرسال البريد: $e");
    }
  }

  // دالة اختيار SMTP تلقائيًا بناءً على نوع البريد الإلكتروني
  SmtpServer getSmtpServer(String email, String password) {
    String domain = email.split('@').last.toLowerCase();
    switch (domain) {
      case 'gmail.com':
        return gmail(email, password);
      case 'outlook.com':
      case 'hotmail.com':
      case 'live.com':
        return SmtpServer(
          'smtp.office365.com',
          port: 587,
          username: email,
          password: password,
          ssl: false,
          allowInsecure: true,
        );
      case 'yahoo.com':
        return SmtpServer(
          'smtp.mail.yahoo.com',
          port: 587,
          username: email,
          password: password,
          ssl: false,
          allowInsecure: true,
        );
      case 'icloud.com':
        return SmtpServer(
          'smtp.mail.me.com',
          port: 587,
          username: email,
          password: password,
          ssl: false,
          allowInsecure: true,
        );
      case 'zoho.com':
        return SmtpServer(
          'smtp.zoho.com',
          port: 587,
          username: email,
          password: password,
          ssl: true,
          allowInsecure: false,
        );
      default:
        return SmtpServer(
          'smtp.$domain',
          port: 587,
          username: email,
          password: password,
          ssl: false,
          allowInsecure: true,
        );
    }
  }

  // دالة توليد كلمة مرور عشوائية
  String generateRandomPassword() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // دالة لعرض الرسائل
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("إضافة إداري", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomTextField(
              controller: nameController,
              icon: Icons.person,
              hintText: "اسم الإداري",
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: idController,
              icon: Icons.badge,
              hintText: "رقم الإداري",
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: phoneController,
              icon: Icons.phone,
              hintText: "رقم الهاتف",
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: emailController,
              icon: Icons.email,
              hintText: "البريد الإلكتروني",
            ),
            SizedBox(height: 20),
            CustomButtonAuth(
              title: "إضافة",
              onPressed: () async => await addAdmin(context),
              color: Colors.blue, // إضافة اللون هنا
            ),
          ],
        ),
      ),
    );
  }
}
