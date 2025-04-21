import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentCardScreen extends StatefulWidget {
  final String name;
  final String id;
  final String stage;
  final String schoolClass;
  final String guardianId;
  final String guardianEmail;
  final String guardianPhone;
  final String qrData;

  const StudentCardScreen({
    required this.name,
    required this.id,
    required this.stage,
    required this.schoolClass,
    required this.guardianId,
    required this.guardianEmail,
    required this.guardianPhone,
    required this.qrData,
  });

  @override
  State<StudentCardScreen> createState() => _StudentCardScreenState();
}

class _StudentCardScreenState extends State<StudentCardScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  // تعريف الألوان المستخدمة
  final Color _iconColor = const Color(
    0xFF007AFF,
  ); // أزرق مشابه للون iOS الافتراضي
  final Color _buttonColor = const Color(0xFF007AFF); // نفس اللون الأزرق للزر
  final Color _textColor = Colors.black87; // نص أسود داكن (أكثر وضوحًا)

  Future<void> _saveCardAsImage() async {
    try {
      // طلب الأذونات
      await Permission.storage.request();
      await Permission.photos.request(); // مهم جداً لـ iOS

      final imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(imageBytes),
          quality: 100,
          name: 'student_card_${widget.id}',
        );

        print("🔽 تم الحفظ: $result");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم حفظ البطاقة كصورة في المعرض')),
        );
      }
    } catch (e) {
      print('❌ خطأ في الحفظ: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في حفظ البطاقة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'بطاقة الطالب',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _buttonColor, // نفس لون الزر
        iconTheme: const IconThemeData(color: Colors.white), // أيقونة بيضاء
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://i.postimg.cc/DwnKf079/321e9c9d-4d67-4112-a513-d368fc26b0c0.jpg',
                        height: 80,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "بطاقة الطالب",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _buttonColor, // نفس لون الزر
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "الاسم: ${widget.name}",
                              style: TextStyle(color: _textColor),
                            ),
                            Text(
                              "رقم الهوية: ${widget.id}",
                              style: TextStyle(color: _textColor),
                            ),
                            Text(
                              "المرحلة: ${widget.stage}",
                              style: TextStyle(color: _textColor),
                            ),
                            Text(
                              "الصف: ${widget.schoolClass}",
                              style: TextStyle(color: _textColor),
                            ),
                            Text(
                              "رقم ولي الأمر: ${widget.guardianId}",
                              style: TextStyle(color: _textColor),
                            ),
                            Text(
                              "هاتف ولي الأمر: ${widget.guardianPhone}",
                              style: TextStyle(color: _textColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      QrImageView(
                        data: widget.qrData,
                        version: QrVersions.auto,
                        size: 150.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveCardAsImage,
              icon: Icon(Icons.download, color: Colors.white),
              label: const Text(
                "حفظ البطاقة كصورة",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor, // نفس اللون الأزرق للزر
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 30,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
