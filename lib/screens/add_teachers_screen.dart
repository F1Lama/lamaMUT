import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // إضافة Firestore
import '../widgets/file_upload_widget.dart';

class AddTeachersScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "إضافة المعلمين",
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
          title: "إضافة المعلمين",
          onConfirm: (fileName, fileData) async {
            if (fileData != null) {
              try {
                for (var row in fileData) {
                  // التحقق من صحة الصف
                  if (row.isNotEmpty && row.length >= 3) {
                    await firestore.collection('teachers').add({
                      'id': row[0], // العمود الأول (مثل ID)
                      'name': row[1], // العمود الثاني (مثل الاسم)
                      'phone': row[2], // العمود الثالث (مثل الهاتف)
                    });
                    print("تمت إضافة الصف: $row");
                  } else {
                    print("صف غير صالح: $row");
                  }
                }
                // عرض رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("تم تخزين بيانات المعلمين بنجاح!")),
                );
              } catch (e) {
                // طباعة الخطأ في الكونسول
                print("خطأ أثناء التخزين: $e");
                // عرض رسالة خطأ للمستخدم
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("حدث خطأ أثناء التخزين: $e")),
                );
              }
            } else {
              // إذا لم يتم اختيار ملف
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("لم يتم اختيار ملف!")),
              );
            }
          },
        ),
      ),
    );
  }
}
