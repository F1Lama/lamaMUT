import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AddParentsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String senderEmail = "8ffaay01@gmail.com"; // ✉️ بريد المرسل
  final String senderPassword = "vljn jaxv hukr qbct"; // 🔑 كلمة مرور التطبيق

  // تعريف المتحكمات
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // تعديل الألوان الرئيسية
  final Color _iconColor = const Color(
    0xFF007AFF,
  ); // أزرق مشابه للون iOS الافتراضي
  final Color _buttonColor = const Color(0xFF007AFF); // نفس اللون الأزرق للزر
  final Color _textFieldFillColor =
      Colors.grey[100]!; // رمادي فاتح جدًا للخلفية
  final Color _textColor = Colors.black87; // نص أسود داكن (أكثر وضوحًا)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية بيضاء
      appBar: AppBar(
        backgroundColor: _buttonColor, // لون الشريط العلوي أصبح أزرق
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "إضافة أولياء الأمور",
          style: TextStyle(
            color: Colors.white, // نص أبيض
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // أيقونة الرجوع بيضاء
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTextField(nameController, "اسم ولي الأمر", Icons.person),
              const SizedBox(height: 10),
              _buildTextField(
                idController,
                "رقم الهوية",
                Icons.credit_card,
                isNumber: true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                phoneController,
                "الهاتف",
                Icons.phone,
                isNumber: true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                emailController,
                "البريد الإلكتروني",
                Icons.email,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // يتم أخذ البيانات من الحقول المدخلة
                    String parentName = nameController.text.trim();
                    String parentId = idController.text.trim();
                    String phone = phoneController.text.trim();
                    String email = emailController.text.trim();

                    // التحقق من أن جميع الحقول مملوءة
                    if (parentName.isEmpty ||
                        parentId.isEmpty ||
                        phone.isEmpty ||
                        email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("جميع الحقول مطلوبة لإكمال العملية"),
                        ),
                      );
                      return;
                    }

                    bool isDuplicate = await isParentDuplicate(
                      parentId,
                      email,
                      phone,
                    );

                    if (isDuplicate) {
                      print(
                        "⚠️ ولي الأمر $parentName مسجل مسبقًا، لم يتم إضافته.",
                      );
                      return;
                    }

                    // توليد كلمة مرور عشوائية
                    String password = generateRandomPassword();

                    // إضافة البيانات إلى Firebase
                    await firestore.collection('parents').add({
                      'id': parentId,
                      'name': parentName,
                      'phone': phone,
                      'email': email,
                      'password': password,
                      'createdAt': Timestamp.now(),
                    });

                    // إرسال البريد الإلكتروني
                    await sendEmail(email, parentName, parentId, password);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "تمت إضافة ولي الأمر وتم إرسال البريد بنجاح!",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'إضافة ولي الأمر',
                    style: TextStyle(
                      color: Colors.white, // نص أبيض على الزر
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor, // لون الخلفية الأزرق
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ), // ارتفاع الزر
                    minimumSize: Size(
                      MediaQuery.of(context).size.width / 2,
                      50,
                    ), // عرض الزر نصف الشاشة
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // حواف مستديرة
                    ),
                  ),
                ),
              ),
            ],
          ),
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
  ) async {
    final smtpServer = getSmtpServer(senderEmail, senderPassword);
    final message =
        Message()
          ..from = Address(senderEmail, "Mutabie App")
          ..recipients.add(recipientEmail)
          ..subject = "تفاصيل حسابك كولي أمر"
          ..text =
              "مرحبًا $name،\n"
              "تم تسجيلك بنجاح في تطبيق متابع.\n"
              "بيانات تسجيل الدخول الخاصة بك:\n"
              "رقم ولي الأمر: $parentId\n"
              "كلمة المرور: $password\n"
              "يرجى تغيير كلمة المرور بعد تسجيل الدخول.\n"
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

  // ✅ تصميم الحقول النصية
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black54,
        ), // لون العنوان (أسود باهت)
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon, color: _iconColor), // أيقونة باللون الأزرق
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _iconColor), // حدود عند التركيز
        ),
        hintStyle: const TextStyle(
          color: Colors.grey, // نص تلميح رمادي
        ),
        filled: true,
        fillColor: _textFieldFillColor, // خلفية الحقل (رمادي فاتح)
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(
        color: _textColor, // لون النص الأساسي داخل الحقل (أسود داكن)
      ),
    );
  }
}
