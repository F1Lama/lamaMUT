import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:map/screens/student_card_screen.dart';
import 'package:map/widgets/custom_button_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class StudentBarcodeScreen extends StatefulWidget {
  @override
  _StudentBarcodeScreenState createState() => _StudentBarcodeScreenState();
}

class _StudentBarcodeScreenState extends State<StudentBarcodeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _guardianIdController = TextEditingController();

  // القوائم الخاصة بالمرحلة الدراسية والصف
  final List<String> _stages = ['أولى ثانوي', 'ثاني ثانوي', 'ثالث ثانوي'];
  final List<String> _classes = ['1', '2', '3', '4', '5', '6'];

  String? _selectedStage; // المرحلة الدراسية المختارة
  String? _selectedClass; // الصف الدراسي المختار
  String? _qrData; // بيانات QR

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الألوان المستخدمة في التصميم
  final Color _buttonColor = const Color(0xFF0171BD); // الأزرق الفاتح
  final Color _textFieldFillColor =
      Colors.grey[200]!; // اللون الرمادي الفاتح للخلفية
  final Color _textColor = Colors.blue; // اللون الأزرق للنصوص داخل المربعات

  Future<void> _generateQR() async {
    String name = _nameController.text.trim();
    String id = _idController.text.trim();
    String guardianId = _guardianIdController.text.trim();

    // التحقق من أن جميع الحقول مملوءة
    if ([name, id, guardianId, _selectedStage, _selectedClass].contains(null) ||
        [name, id, guardianId].any((e) => e.isEmpty)) {
      _showSnackBar('رجاءً عَبِّ البيانات كاملة');
      return;
    }

    // التحقق من تكرار الطالب
    bool isDuplicate = await _isStudentDuplicate(id);
    if (isDuplicate) {
      _showSnackBar('هذا الطالب مسجل مسبقًا');
      return;
    }

    // جلب البريد الإلكتروني لولي الأمر
    String? emailFromDb = await _getGuardianEmail(guardianId);
    if (emailFromDb == null) {
      _showSnackBar('لم يتم العثور على البريد الإلكتروني لولي الأمر');
      return;
    }

    try {
      // حفظ بيانات الطالب في Firestore
      await _firestore.collection('students').doc(id).set({
        'name': name,
        'id': id,
        'stage': _selectedStage,
        'schoolClass': _selectedClass,
        'guardianId': guardianId,
        'guardianEmail': emailFromDb,
      });

      // إنشاء بيانات QR
      _qrData =
          'Name: $name\nID: $id\nStage: $_selectedStage\nClass: $_selectedClass\nGuardian ID: $guardianId\nEmail: $emailFromDb';

      // إرسال بطاقة الطالب عبر البريد الإلكتروني
      await _sendStudentCardEmail(
        emailFromDb,
        name,
        id,
        _selectedStage!,
        _selectedClass!,
        guardianId,
      );

      // التنقل إلى صفحة عرض بطاقة الطالب
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => StudentCardScreen(
                name: name,
                id: id,
                stage: _selectedStage!,
                schoolClass: _selectedClass!,
                guardianId: guardianId,
                qrData: _qrData!,
                guardianEmail: emailFromDb,
                guardianPhone: '',
              ),
        ),
      );
    } catch (e) {
      print("❌ خطأ: $e");
      _showSnackBar('حدث خطأ أثناء حفظ البيانات');
    }
  }

  // التحقق من تكرار الطالب
  Future<bool> _isStudentDuplicate(String id) async {
    final doc = await _firestore.collection('students').doc(id).get();
    return doc.exists;
  }

  // جلب البريد الإلكتروني لولي الأمر
  Future<String?> _getGuardianEmail(String guardianId) async {
    try {
      final query =
          await _firestore
              .collection('parents')
              .where('id', isEqualTo: guardianId)
              .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first['email'];
      }
    } catch (e) {
      print("❌ خطأ في جلب البريد الإلكتروني: $e");
    }
    return null;
  }

  // إرسال بطاقة الطالب عبر البريد الإلكتروني
  Future<void> _sendStudentCardEmail(
    String email,
    String name,
    String id,
    String stage,
    String schoolClass,
    String guardianId,
  ) async {
    final smtpServer = gmail('8ffaay01@gmail.com', 'vljn jaxv hukr qbct');
    final pdf = pw.Document();

    // إنشاء ملف PDF
    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'بطاقة الطالب',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text("الاسم: $name"),
                pw.Text("رقم الهوية: $id"),
                pw.Text("المرحلة: $stage"),
                pw.Text("الصف: $schoolClass"),
                pw.Text("رقم ولي الأمر: $guardianId"),
                pw.SizedBox(height: 20),
                pw.Text("رمز QR:"),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data:
                      'Name: $name\nID: $id\nStage: $stage\nClass: $schoolClass\nGuardian ID: $guardianId',
                  width: 100,
                  height: 100,
                ),
              ],
            ),
      ),
    );

    // حفظ الملف مؤقتًا
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/student_card.pdf');
    await file.writeAsBytes(await pdf.save());

    // إعداد رسالة البريد الإلكتروني
    final message =
        Message()
          ..from = Address('8ffaay01@gmail.com', 'Student App')
          ..recipients.add(email)
          ..subject = 'بطاقة الطالب الخاصة بك'
          ..text =
              'مرحبًا $name،\nمرفقة بطاقة الطالب الخاصة بك.\nتحياتنا،\nفريق التطبيق'
          ..attachments = [
            FileAttachment(file)
              ..location = Location.inline
              ..cid = '<student_card>',
          ];

    try {
      await send(message, smtpServer);
      _showSnackBar('تم إرسال البريد الإلكتروني بنجاح');
    } catch (e) {
      print("❌ فشل إرسال الإيميل: $e");
      _showSnackBar('فشل إرسال البريد الإلكتروني');
    }
  }

  // عرض رسالة تنبيه
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة طالب', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // حقل اسم الطالب
              _buildTextField(_nameController, "اسم الطالب", Icons.person),
              const SizedBox(height: 10),

              // حقل رقم الهوية
              _buildTextField(
                _idController,
                "رقم الهوية",
                Icons.credit_card,
                isNumber: true,
              ),
              const SizedBox(height: 10),

              // قائمة اختيار المرحلة الدراسية
              _buildDropdown(),
              const SizedBox(height: 10),

              // قائمة اختيار الصف الدراسي
              _buildClassSelector(),
              const SizedBox(height: 10),

              // حقل رقم ولي الأمر
              _buildTextField(
                _guardianIdController,
                "رقم ولي الأمر",
                Icons.person_outline,
                isNumber: true,
              ),
              const SizedBox(height: 20),

              // زر إنشاء بطاقة الطالب
              CustomButtonAuth(
                title: 'إنشاء بطاقة الطالب',
                onPressed: _generateQR,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لإنشاء حقل نصي
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
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon, color: _buttonColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _buttonColor),
        ),
        hintStyle: TextStyle(color: _textColor),
        filled: true,
        fillColor: _textFieldFillColor,
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  // دالة لإنشاء قائمة اختيار المرحلة الدراسية
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'المرحلة الدراسية',
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _buttonColor),
        ),
      ),
      value: _selectedStage,
      items:
          _stages
              .map(
                (stage) => DropdownMenuItem(value: stage, child: Text(stage)),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedStage = value;
          _selectedClass = null; // إعادة تعيين الصف عند تغيير المرحلة
        });
      },
    );
  }

  // دالة لإنشاء قائمة اختيار الصف الدراسي
  Widget _buildClassSelector() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'اختر الصف',
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _buttonColor),
        ),
      ),
      value: _selectedClass,
      hint: const Text('اختر الصف'),
      items:
          _classes
              .map(
                (className) =>
                    DropdownMenuItem(value: className, child: Text(className)),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedClass = value;
        });
      },
    );
  }
}
