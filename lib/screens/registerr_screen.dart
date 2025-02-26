import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController schoolLocationController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> registerSchool() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final schoolName = schoolNameController.text.trim();
    final schoolLocation = schoolLocationController.text.trim();

    // التحقق من البيانات المدخلة
    if (schoolName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال اسم المدرسة')));
      return;
    }
    if (schoolLocation.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال موقع المدرسة')));
      return;
    }

    // التحقق من شروط كلمة المرور
    String passwordPattern =
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&]).{8,}$';
    RegExp regExp = RegExp(passwordPattern);
    if (password.isEmpty || !regExp.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'كلمة المرور يجب أن تحتوي على أحرف كبيرة وصغيرة وأرقام ورموز، وأن تكون بطول 8 أحرف على الأقل',
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('كلمات المرور غير متطابقة')));
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بريد إلكتروني صالح')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // بدء مؤشر التحميل
    });

    try {
      // إنشاء الحساب باستخدام Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // إضافة بيانات المدرسة إلى Firestore
      await FirebaseFirestore.instance
          .collection('schools')
          .doc(userCredential.user!.uid)
          .set({
            'schoolName': schoolName,
            'schoolLocation': schoolLocation,
            'email': email,
            'createdAt': DateTime.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب وتخزين البيانات بنجاح!')),
      );

      // العودة إلى صفحة تسجيل الدخول
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء إنشاء الحساب: $e')));
    } finally {
      setState(() {
        _isLoading = false; // إيقاف مؤشر التحميل
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 113, 189),
        title: const Text('تسجيل مدرسة'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://i.postimg.cc/DwnKf079/321e9c9d-4d67-4112-a513-d368fc26b0c0.jpg',
                width: 200,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'تسجيل حساب مدرسة',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // حقل اسم المدرسة
              _buildInputField(
                schoolNameController,
                'اسم المدرسة',
                Icons.school,
                helperText: 'يجب أن يكون اسم المدرسة نصًا صالحًا',
              ),
              const SizedBox(height: 15),
              // حقل موقع المدرسة
              _buildInputField(
                schoolLocationController,
                'موقع المدرسة',
                Icons.location_on,
                helperText: 'يجب أن يكون الموقع نصًا صالحًا',
              ),
              const SizedBox(height: 15),
              // حقل كلمة المرور
              _buildInputField(
                passwordController,
                'كلمة المرور',
                Icons.lock,
                obscureText: true,
                helperText: 'يجب أن تحتوي على أحرف كبيرة وصغيرة وأرقام ورموز',
              ),
              const SizedBox(height: 15),
              // حقل تأكيد كلمة المرور
              _buildInputField(
                confirmPasswordController,
                'تأكيد كلمة المرور',
                Icons.lock_outline,
                obscureText: true,
                helperText: 'يجب أن تكون مطابقة لكلمة المرور',
              ),
              const SizedBox(height: 15),
              // حقل البريد الإلكتروني
              _buildInputField(
                emailController,
                'البريد الإلكتروني',
                Icons.email,
                helperText: 'مثال: example@example.com',
              ),
              const SizedBox(height: 30),
              // زر تسجيل
              _buildActionButton('تسجيل', registerSchool),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لتصميم الحقول
  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 1, 113, 189)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        helperText: helperText,
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // دالة لتصميم الأزرار
  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 1, 113, 189),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : Text(
                  label,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
      ),
    );
  }
}
