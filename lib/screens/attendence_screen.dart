import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String studentId; // معرف الطالب
  final String guardianId; // معرف ولي الأمر

  const AttendanceScreen({
    Key? key,
    required this.studentId,
    required this.guardianId,
  }) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<Map<String, dynamic>> _studentDataFuture;
  late Future<List<Map<String, dynamic>>> _attendanceRecordsFuture;

  @override
  void initState() {
    super.initState();
    _studentDataFuture = _fetchStudentData(widget.studentId);
    _attendanceRecordsFuture = _fetchAttendanceRecords(widget.studentId);
  }

  Future<Map<String, dynamic>> _fetchStudentData(String studentId) async {
    try {
      final studentDoc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(studentId)
              .get();
      if (studentDoc.exists) {
        return studentDoc.data()!;
      } else {
        throw Exception("لم يتم العثور على بيانات الطالب");
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب بيانات الطالب: $e");
      throw Exception("حدث خطأ أثناء جلب بيانات الطالب");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceRecords(
    String studentId,
  ) async {
    try {
      final attendanceSnapshot =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('studentId', isEqualTo: studentId)
              .orderBy('timestamp', descending: true)
              .get();

      return attendanceSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("❌ خطأ أثناء جلب سجل الحضور: $e");
      return [];
    }
  }

  Future<Timestamp?> _getSchoolAttendanceStartTime(String schoolId) async {
    try {
      final schoolDoc =
          await FirebaseFirestore.instance
              .collection('schools')
              .doc(schoolId)
              .get();
      if (schoolDoc.exists &&
          schoolDoc.data()!.containsKey('attendanceStartTime')) {
        return schoolDoc['attendanceStartTime'];
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب وقت الحضور: $e");
    }
    return null;
  }

  Future<void> _markAttendance(String studentId, String schoolId) async {
    try {
      Timestamp? startTime = await _getSchoolAttendanceStartTime(schoolId);
      if (startTime == null) {
        _showSnackBar("لم يتم تحديد وقت الحضور من قبل المدرسة.");
        return;
      }

      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final query =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('studentId', isEqualTo: studentId)
              .where('date', isEqualTo: currentDate)
              .get();

      if (query.docs.isNotEmpty) {
        _showSnackBar('تم تسجيل الحضور لهذا الطالب اليوم بالفعل');
        return;
      }

      DateTime now = DateTime.now();
      DateTime attendanceStart = startTime.toDate();
      Duration difference = now.difference(attendanceStart);
      String status = 'حضور';

      if (difference.inMinutes > 30 && difference.inMinutes <= 60) {
        status = 'متأخر';
      } else if (difference.inMinutes > 60) {
        status = 'غائب';
      }

      await FirebaseFirestore.instance.collection('attendance').add({
        'studentId': studentId,
        'status': status,
        'date': currentDate,
        'timestamp': Timestamp.now(),
      });

      _showSnackBar('تم تسجيل الحالة: $status');
    } catch (e) {
      print("❌ خطأ أثناء تسجيل الحضور: $e");
      _showSnackBar('حدث خطأ أثناء تسجيل الحضور');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("تسجيل الحضور"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _studentDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Center(child: Text("حدث خطأ أثناء جلب بيانات الطالب"));
                } else {
                  final studentData = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "الطالب: ${studentData['name']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "الصف: ${studentData['schoolClass']}",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "المرحلة: ${studentData['stage']}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final studentData = await _studentDataFuture;
                _markAttendance(widget.studentId, studentData['schoolId']);
              },
              child: Text('تسجيل الحضور'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(MediaQuery.of(context).size.width / 2, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _attendanceRecordsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Text("حدث خطأ أثناء جلب بيانات الحضور"),
                    );
                  } else if (snapshot.data!.isEmpty) {
                    return Center(child: Text("لا توجد بيانات حضور متاحة"));
                  } else {
                    final records = snapshot.data!;
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        Color color;
                        switch (record['status']) {
                          case 'حضور':
                            color = Colors.green;
                            break;
                          case 'متأخر':
                            color = Colors.orange;
                            break;
                          case 'غائب':
                            color = Colors.red;
                            break;
                          default:
                            color = Colors.black;
                        }
                        return Card(
                          child: ListTile(
                            title: Text(
                              "التاريخ: ${record['date'] ?? 'غير محدد'}",
                            ),
                            subtitle: Text(
                              "الحالة: ${record['status'] ?? 'غير محدد'}",
                            ),
                            trailing: Icon(
                              Icons.circle,
                              color: color,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
