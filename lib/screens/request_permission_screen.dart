import 'package:flutter/material.dart';

class RequestPermissionScreen extends StatelessWidget {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController fileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('طلب الاستئذان', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50), // مسافة من الأعلى
            CustomLabel(text: 'السبب'),
            CustomTextField(controller: reasonController, hintText: ' '),
            CustomLabel(text: 'التاريخ/اليوم'),
            CustomTextField(controller: dateController, hintText: ''),
            CustomLabel(text: 'الوقت'),
            CustomTextField(controller: timeController, hintText: ''),
            CustomLabel(text: 'إرفاق الملف '),
            CustomTextField(controller: fileController, hintText: ' '),
            SizedBox(height: 40), // مسافة قبل الزر
            SizedBox(
              width: double.infinity,
              child: CustomButtonAuth(title: 'إرسال', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  CustomTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right, // محاذاة النص داخل الحقل إلى اليمين
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class CustomButtonAuth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;

  const CustomButtonAuth({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 50,
      minWidth: 200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: const Color.fromARGB(
        255,
        1,
        113,
        189,
      ), // لون الزر كما هو في الصورة
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text(title, style: TextStyle(fontSize: 20)),
    );
  }
}

// تعديل محاذاة النص ليكون على اليمين
class CustomLabel extends StatelessWidget {
  final String text;

  CustomLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight, // محاذاة النص بالكامل لليمين
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          textAlign: TextAlign.right, // إجبار النص على المحاذاة لليمين
          textDirection: TextDirection.rtl, // توجيه النص من اليمين لليسار
        ),
      ),
    );
  }
}
