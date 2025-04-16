import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map/screens/student_card_screen.dart';

class StudentSearchScreen extends StatefulWidget {
  @override
  _StudentSearchScreenState createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchResult;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _searchStudent() async {
    String studentId = _searchController.text.trim();

    if (studentId.isEmpty) {
      _showSnackBar('يرجى إدخال رقم الهوية');
      return;
    }

    // البحث عن الطالب في Firestore
    try {
      final studentDoc =
          await _firestore.collection('students').doc(studentId).get();

      if (studentDoc.exists) {
        final studentData = studentDoc.data()!;
        final name = studentData['name'];
        final stage = studentData['stage'];
        final schoolClass = studentData['schoolClass'];
        final guardianId = studentData['guardianId'];
        final phone = studentData['phone'];

        setState(() {
          _searchResult = 'تم العثور على الطالب: $name - $stage - $schoolClass';
        });

        // الانتقال إلى شاشة البطاقة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => StudentCardScreen(
                  name: name,
                  id: studentId,
                  stage: stage,
                  schoolClass: schoolClass,
                  guardianId: guardianId,
                  qrData:
                      'اسم الطالب: $name\nرقم الهوية: $studentId\nالمرحلة: $stage\nالصف: $schoolClass\nرقم ولي الأمر: $guardianId\nرقم الجوال: $phone',
                  guardianEmail: '', // سيتم تحديده لاحقًا
                  guardianPhone: phone,
                ),
          ),
        );
      } else {
        _showSnackBar('لم يتم العثور على الطالب');
      }
    } catch (e) {
      print("❌ خطأ أثناء البحث عن الطالب: $e");
      _showSnackBar('حدث خطأ أثناء البحث');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('بحث عن بطاقة الطالب'),
        backgroundColor: Color(0xFF4CAF50),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'رقم الهوية',
                labelStyle: TextStyle(color: Color(0xFF4CAF50)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4CAF50)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchStudent,
              child: Text('بحث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0171BD),
              ),
            ),
            SizedBox(height: 20),
            if (_searchResult != null)
              Text(
                _searchResult!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}