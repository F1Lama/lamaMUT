import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map/screens/RequestDetailsScreen.dart'; // استيراد واجهة تفاصيل الطلب

class ExitPermitsScreen extends StatelessWidget {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // دالة لإضافة طلب تصريح خروج جديد إلى Firestore
  static Future<void> addStudent({
    required String studentName,
    required String grade,
    required String teacherName,
    required String exitTime,
  }) async {
    try {
      await firestore.collection('requests').add({
        'studentName': studentName,
        'grade': grade,
        'teacherName': teacherName,
        'exitTime': Timestamp.fromDate(
          DateTime.parse(exitTime),
        ), // تخزين الوقت كـ Timestamp
        'status': 'active', // الحالة الافتراضية للطلب
      });
      print("تمت إضافة الطلب بنجاح.");
    } catch (e) {
      print("❌ خطأ أثناء إضافة الطلب: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "تصاريح الخروج من الحصة",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              firestore
                  .collection('requests') // جلب الطلبات من Firestore
                  .where(
                    'status',
                    isEqualTo: 'active',
                  ) // عرض الطلبات النشطة فقط
                  .orderBy('exitTime', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("خطأ: ${snapshot.error.toString()}"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final requests = snapshot.data!.docs;

            // التحقق من الطلبات المنتهية وتحديث حالتها
            for (var request in requests) {
              final data = request.data() as Map<String, dynamic>;
              final exitTime = (data['exitTime'] as Timestamp).toDate();
              final currentTime = DateTime.now();

              if (currentTime.isAfter(exitTime)) {
                // تحديث الحالة إلى "expired" إذا انتهى الوقت
                FirebaseFirestore.instance
                    .collection('requests')
                    .doc(request.id)
                    .update({'status': 'expired'});
              }
            }

            // عرض الطلبات النشطة فقط
            final activeRequests =
                requests
                    .where(
                      (request) =>
                          (request.data() as Map<String, dynamic>)['status'] ==
                          'active',
                    )
                    .toList();

            if (activeRequests.isEmpty) {
              return Center(
                child: Text(
                  "لا توجد تصاريح حتى الآن.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            return ListView.builder(
              itemCount: activeRequests.length,
              itemBuilder: (context, index) {
                final request = activeRequests[index];
                final data = request.data() as Map<String, dynamic>;
                try {
                  final exitTime = (data['exitTime'] as Timestamp).toDate();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RequestDetailsScreen(
                                studentName: data['studentName'],
                                grade: data['grade'],
                                teacherName: data['teacherName'],
                                exitTime: exitTime.toString(),
                              ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        data['studentName'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } catch (e) {
                  return ListTile(
                    title: Text("خطأ في عرض الطلب: ${e.toString()}"),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
