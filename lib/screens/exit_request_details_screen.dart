import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot request;
  final String studentName;
  final String grade;
  final String stage;
  final String schoolClass;
  final String schoolId;

  const RequestDetailsScreen({
    Key? key,
    required this.request,
    required this.studentName,
    required this.grade,
    required this.stage,
    required this.schoolClass,
    required this.schoolId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = request.data() as Map<String, dynamic>;

    final reason = data['reason'] ?? 'غير محدد';
    final date = data['date'] ?? 'غير محدد';
    final time = data['time'] ?? 'غير محدد';
    final attachedFileUrl = data['attachedFileUrl'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("تفاصيل الطلب", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("الطالبة:", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  Text(studentName, textAlign: TextAlign.right),
                  const SizedBox(height: 10),
                  const Text("الصف:", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  Text(grade.isNotEmpty ? grade : 'غير محدد', textAlign: TextAlign.right),
                  const SizedBox(height: 10),
                  const Text("سبب الاستئذان:", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  Text(reason, textAlign: TextAlign.right),
                  const SizedBox(height: 10),
                  const Text("وقت الاستئذان:", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  Text(time, textAlign: TextAlign.right),
                ],
              ),
            ),
            if (attachedFileUrl != null && attachedFileUrl.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final uri = Uri.parse(attachedFileUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("لا يمكن فتح الرابط")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("حدث خطأ أثناء فتح الملف")),
                    );
                  }
                },
                child: const Text("عرض الملف", style: TextStyle(color: Colors.blue)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("لا يوجد ملف لعرضه")),
                  );
                },
                child: const Text("عرض الملف", style: TextStyle(color: Colors.blue)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleDecision(context, 'accepted'),
                    child: const Text("قبول", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleDecision(context, 'rejected'),
                    child: const Text("رفض", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDecision(BuildContext context, String decision) async {
    try {
      final excuseData = request.data() as Map<String, dynamic>;

      // إضافة نسخة من الطلب إلى exitPermits
      await FirebaseFirestore.instance.collection('exitPermits').add({
        ...excuseData,
        'decision': decision,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
        'schoolId': schoolId, // ✅ تمرير schoolId مع الطلب الجديد
      });

      // حذف الطلب من excuses
      await FirebaseFirestore.instance
          .collection('excuses')
          .doc(request.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(decision == 'accepted' ? "تم قبول الطلب" : "تم رفض الطلب"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء معالجة الطلب")),
      );
    }
  }
}
