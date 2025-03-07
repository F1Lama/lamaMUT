import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// استيراد الشاشات المناسبة
import 'package:map/screens/BarcodeScannerScreen.dart'; // ✅ استيراد شاشة مسح الباركود
import 'package:map/screens/add_parents_screen.dart';
import 'package:map/screens/add_students_screen.dart';
import 'package:map/screens/add_teachers_screen.dart';
import 'package:map/screens/home_screen.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isLoading = false;

  /// ✅ دالة توليد ورفع أكواد QR إلى Firebase Storage وتخزين الرابط في Firestore
  Future<void> generateAndSaveBarcodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot studentSnapshot =
          await FirebaseFirestore.instance.collection('students').get();

      for (var studentDoc in studentSnapshot.docs) {
        String studentID = studentDoc['id'];
        String studentName = studentDoc['name'];

        print("📌 جاري إنشاء QR للطالب: $studentName - ID: $studentID");

        // توليد رمز QR
        final QrPainter painter = QrPainter(
          data: studentID,
          version: QrVersions.auto,
          gapless: false,
          color: Colors.black,
        );

        // تحويل QR إلى صورة كـ Uint8List
        final picData = await painter.toImageData(320);
        if (picData == null) {
          print("❌ فشل تحويل QR إلى صورة!");
          continue; // تخطي الطالب إذا فشلت العملية
        }

        final Uint8List qrCodeImage = picData.buffer.asUint8List();
        print("✅ تم إنشاء الصورة بنجاح للطالب: $studentName");

        // 🔹 رفع الصورة إلى Firebase Storage
        String filePath = 'barcodes/$studentID.png';
        Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
        print("📂 رفع الملف إلى: $filePath");

        UploadTask uploadTask = storageRef.putData(qrCodeImage);

        await uploadTask.whenComplete(() async {
          print("✅ تم رفع الملف بنجاح: $filePath");

          // 🔹 الحصول على رابط الصورة بعد الرفع
          try {
            String downloadUrl = await storageRef.getDownloadURL();
            print("📌 رابط الصورة: $downloadUrl");

            // 🔹 تحديث Firestore برابط الصورة
            await FirebaseFirestore.instance
                .collection('students')
                .doc(studentDoc.id)
                .update({'barcode': downloadUrl});

            print("✅ تم حفظ الباركود للطالب: $studentName في Firestore");

            // 📩 إرسال البريد الإلكتروني بعد الحفظ
            await sendBarcodeByEmail(studentName, downloadUrl);
          } catch (e) {
            print("❌ خطأ أثناء جلب رابط الصورة: $e");
          }
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم إنشاء وحفظ جميع أكواد QR بنجاح!')),
      );
    } catch (e) {
      print("❌ خطأ أثناء العملية: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ حدث خطأ: $e')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// ✅ دالة إرسال الباركود عبر البريد الإلكتروني
  Future<void> sendBarcodeByEmail(String studentName, String barcodeUrl) async {
    String username = '8ffaay01@gmail.com'; // ✉️ ضع إيميل المرسل
    String password =
        'urwn frcb fzug ucyz'; // 🔐 ضع كلمة مرور الإيميل أو App Password

    final smtpServer = gmail(username, password);

    final message =
        Message()
          ..from = Address(username, 'School Admin') // اسم المرسل
          ..recipients.add(
            'fayalrddady2001@gmail.com',
          ) // 📩 الإيميل الموحد الذي سيستقبل الباركود
          ..subject = 'QR Code for Student: $studentName'
          ..text =
              'Hello,\n\nAttached is the QR code for student $studentName.\n\n$barcodeUrl';

    try {
      final sendReport = await send(message, smtpServer);
      print('✅ Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('❌ Failed to send email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          drawerItem(
            title: "إضافة أولياء الأمور",
            icon: Icons.group_add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddParentsScreen()),
              );
            },
          ),
          drawerItem(
            title: "إضافة طلاب",
            icon: Icons.person_add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddStudentsScreen()),
              );
            },
          ),
          drawerItem(
            title: "إضافة المعلمين",
            icon: Icons.school,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTeachersScreen()),
              );
            },
          ),
          drawerItem(
            title: "الأعذار المرفقة",
            icon: Icons.attachment,
            onTap: () {
              print("📎 تم الضغط على الأعذار المرفقة");
            },
          ),
          const Divider(), // 🔹 خط فاصل بين العناصر
          // ✅ *زر توليد الباركود*
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(),
                    ) // 🔄 تحميل أثناء التنفيذ
                    : ElevatedButton.icon(
                      onPressed: generateAndSaveBarcodes,
                      icon: Icon(Icons.qr_code, color: Colors.white),
                      label: Text(
                        "توليد وحفظ أكواد QR",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(
                          double.infinity,
                          50,
                        ), // يجعل الزر بعرض القائمة
                      ),
                    ),
          ),

          // ✅ *زر مسح الباركود*
          drawerItem(
            title: "مسح الباركود",
            icon: Icons.qr_code_scanner,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarcodeScannerScreen()),
              );
            },
          ),

          const Spacer(),
          drawerItem(
            title: "تسجيل خروج",
            icon: Icons.logout,
            onTap: () {
              _logout(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget drawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("❌ خطأ في تسجيل الخروج: $e");
    }
  }
}
