import 'package:flutter/material.dart';

class AuthorizationScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('التوكيل', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40), // يبعد الحقول عن بداية الصفحة
            CustomTextField(
              controller: nameController,
              icon: Icons.person,
              hintText: 'اسم الموكل',
            ),
            CustomTextField(
              controller: idController,
              icon: Icons.badge,
              hintText: 'رقم الموكل',
            ),
            CustomTextField(
              controller: passwordController,
              icon: Icons.lock,
              hintText: 'كلمة المرور',
              obscureText: true,
            ),
            SizedBox(height: 40), // يبعد الزر عن الحقول
            Center(
              child: SizedBox(
                width: 200, // جعل الزر بالوسط
                child: CustomButtonAuth(
                  title: 'تسجيل',
                  onPressed: () {
                    // تنفيذ العملية عند الضغط على الزر
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;

  CustomTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12), // مسافة بين الحقول
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.indigo),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200], // خلفية رمادية للحقل فقط
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
    return SizedBox(
      width: 170, // عرض الزر
      child: MaterialButton(
        height: 45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: const Color.fromARGB(255, 1, 113, 189),
        textColor: Colors.white,
        onPressed: onPressed,
        child: Text(title, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
