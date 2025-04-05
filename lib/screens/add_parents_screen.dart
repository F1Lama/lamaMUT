import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map/widgets/file_upload_widget.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AddParentsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String senderEmail = "8ffaay01@gmail.com"; // ✉️ بريد المرسل
  final String senderPassword = "urwn frcb fzug ucyz"; // 🔑 كلمة مرور التطبيق

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "إضافة أولياء الأمور",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FileUploadWidget(
          title: "إضافة أولياء الأمور",
          onConfirm: (fileName, fileData) async {
            if (fileData != null) {
              try {
                for (var row in fileData) {
                  if (row.isNotEmpty && row.length >= 5) {
                    // تعديلنا هنا
                    String id = row[0]; // ID
                    String name = row[1]; // Name
                    String phone = row[2]; // Phone
                    String email = row[3]; // Email
                    String studentName = row[4]; // اسم الطالب

                    bool isDuplicate = await isParentDuplicate(
                      id,
                      email,
                      phone,
                    );
                    if (isDuplicate) {
                      print("⚠️ ولي الأمر $name مسجل مسبقًا، لم يتم إضافته.");
                      continue;
                    }

                    String password = generateRandomPassword();
                    await firestore.collection('parents').add({
                      'id': id,
                      'name': name,
                      'phone': phone,
                      'email': email,
                      'studentName': studentName, // إضافة اسم الطالب
                      'password': password,
                      'createdAt': Timestamp.now(),
                    });

                    await sendEmail(
                      email,
                      name,
                      id,
                      password,
                      studentName,
                    ); // إضافة اسم الطالب في البريد
                    print("✅ تمت إضافة ولي الأمر: $name وتم إرسال البريد.");
                  } else {
                    print("❌ صف غير صالح: $row");
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "تمت إضافة أولياء الأمور وإرسال كلمات المرور بنجاح!",
                    ),
                  ),
                );
              } catch (e) {
                print("❌ خطأ أثناء التخزين: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("حدث خطأ أثناء التخزين: $e")),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("لم يتم اختيار ملف!")),
              );
            }
          },
        ),
      ),
    );
  }

  // ✅ التحقق من تكرار بيانات ولي الأمر
  Future<bool> isParentDuplicate(String id, String email, String phone) async {
    var querySnapshot =
        await firestore.collection('parents').where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) return true;

    querySnapshot =
        await firestore
            .collection('parents')
            .where('email', isEqualTo: email)
            .get();
    if (querySnapshot.docs.isNotEmpty) return true;

    querySnapshot =
        await firestore
            .collection('parents')
            .where('phone', isEqualTo: phone)
            .get();
    if (querySnapshot.docs.isNotEmpty) return true;

    return false;
  }

  // ✅ إرسال البريد الإلكتروني
  Future<void> sendEmail(
    String recipientEmail,
    String name,
    String parentId,
    String password,
    String studentName,
  ) async {
    final smtpServer = getSmtpServer(senderEmail, senderPassword);

    final message =
        Message()
          ..from = Address(senderEmail, "Mutabie App")
          ..recipients.add(recipientEmail)
          ..subject = "تفاصيل حسابك كولي أمر"
          ..text =
              "مرحبًا $name،\n\n"
              "تم تسجيلك بنجاح في تطبيق متابع.\n"
              "بيانات تسجيل الدخول الخاصة بك:\n"
              "رقم ولي الأمر: $parentId\n"
              "اسم الطالب: $studentName\n" // إضافة اسم الطالب في البريد الإلكتروني
              "كلمة المرور: $password\n\n"
              "يرجى تغيير كلمة المرور بعد تسجيل الدخول.\n\n"
              "تحياتنا، فريق متابع.";

    try {
      await send(message, smtpServer);
      print("📩 تم إرسال البريد الإلكتروني بنجاح إلى $recipientEmail");
    } catch (e) {
      print("❌ خطأ في إرسال البريد: $e");
    }
  }

  // ✅ اختيار SMTP بناءً على نوع البريد
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

  // ✅ توليد كلمة مرور عشوائية
  String generateRandomPassword() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
