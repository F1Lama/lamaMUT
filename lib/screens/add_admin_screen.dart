import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase
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

  Future<void> addAdmin(BuildContext context) async {
    String name = nameController.text.trim(); // تنظيف الاسم
    String id = idController.text.trim(); // تنظيف الرقم الوظيفي
    String phone = phoneController.text.trim(); // تنظيف رقم الجوال

    // 1. التحقق من أن جميع الحقول ممتلئة
    if (name.isEmpty || id.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يجب ملء جميع الحقول قبل الإضافة")),
      );
      return; // إيقاف التنفيذ إذا كانت هناك بيانات مفقودة
    }

    // 2. التحقق من أن الاسم ثلاثي أو أكثر
    final nameParts = name.split(' '); // تقسيم الاسم باستخدام المسافات
    if (nameParts.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("الاسم يجب أن يكون ثلاثيًا أو أكثر")),
      );
      return; // إيقاف التنفيذ إذا كان الاسم غير صحيح
    }

    // 3. التحقق من أن الرقم الوظيفي يتكون من 6 أرقام على الأقل
    final idRegex = RegExp(r'^\d{6,}$'); // التعبير النمطي لرقم الوظيفي
    if (!idRegex.hasMatch(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("الرقم الوظيفي يجب أن يكون 6 أرقام على الأقل")),
      );
      return; // إيقاف التنفيذ إذا كان الرقم الوظيفي غير صحيح
    }

    // 4. التحقق من أن رقم الجوال يبدأ بـ "05"
    final phoneRegex = RegExp(r'^05\d{8}$'); // التعبير النمطي لرقم الجوال
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("رقم الجوال غير صحيح. يجب أن يبدأ بـ 05")),
      );
      return; // إيقاف التنفيذ إذا كان رقم الجوال غير صحيح
    }

    try {
      // 5. التحقق مما إذا كان الرقم الوظيفي مسجلًا بالفعل
      var existingAdminById =
          await FirebaseFirestore.instance
              .collection('admins')
              .where('id', isEqualTo: id)
              .get();
      if (existingAdminById.docs.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("المستخدم مسجل بالفعل")));
        return; // إيقاف التنفيذ إذا كان الرقم الوظيفي موجودًا
      }

      // 6. إضافة البيانات إلى Firestore
      await FirebaseFirestore.instance.collection('admins').add({
        'name': name, // الاسم (ثلاثي أو رباعي)
        'id': id, // رقم الوظيفي
        'phone': phone, // رقم الجوال
        'createdAt': Timestamp.now(), // تسجيل وقت الإضافة
      });

      // 7. عرض رسالة نجاح
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("تمت إضافة الإداري بنجاح")));

      // 8. مسح الحقول بعد الإضافة
      nameController.clear();
      idController.clear();
      phoneController.clear();
    } catch (e) {
      print("Error adding admin: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء الإضافة")));
    }
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
      body: Column(
        children: [
          const Spacer(flex: 3), // زيادة المسافة لدفع المحتوى للأسفل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  hintText: "الرقم الوظيفي",
                ),
                SizedBox(height: 15),
                CustomTextField(
                  controller: phoneController,
                  icon: Icons.phone,
                  hintText: "رقم هاتف الإداري",
                ),
              ],
            ),
          ),
          const Spacer(flex: 4), // دفع الزر للأسفل أكثر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomButtonAuth(
              title: "إضافة",
              onPressed: () async {
                await addAdmin(context);
              },
              color: const Color.fromRGBO(33, 150, 243, 1),
            ),
          ),
          const Spacer(flex: 2), // مسافة في الأسفل
        ],
      ),
    );
  }
}

class CustomButtonAuth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final Color color;

  const CustomButtonAuth({
    super.key,
    this.onPressed,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 50,
      minWidth: 200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: color,
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text(title, style: TextStyle(fontSize: 20)),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;

  CustomTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.indigo),
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
