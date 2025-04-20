import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendenceNames extends StatelessWidget {
  final String stage;
  final int classNumber;

  AttendenceNames({required this.stage, required this.classNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("فصل $stage/$classNumber", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .where('stage', isEqualTo: stage)
                    .where('schoolClass', isEqualTo: '$classNumber')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("لا يوجد طلاب في هذا الفصل"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final student = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final name = student['name'];
                      final status = student['status'] ?? 'غير معروف'; // حالة الطالب

                      Color statusColor;
                      switch (status) {
                        case 'حضور':
                          statusColor = Colors.green;
                          break;
                        case 'غياب':
                          statusColor = Colors.red;
                          break;
                        case 'تأخير':
                          statusColor = Colors.orange;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            MaterialButton(
              onPressed: () {},
              color: Color.fromARGB(255, 1, 113, 189),
              textColor: Colors.white,
              child: Text("تعديل"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              height: 50,
              minWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}