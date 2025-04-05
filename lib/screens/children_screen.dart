import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildrenScreen extends StatefulWidget {
  final String guardianId; // معرف ولي الأمر المسجل

  const ChildrenScreen({Key? key, required this.guardianId}) : super(key: key);

  @override
  _ChildrenScreenState createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    // جلب بيانات الطلاب بناءً على معرف ولي الأمر
    _studentsFuture = _fetchStudentsByGuardianId(widget.guardianId);
  }

  Future<List<Map<String, dynamic>>> _fetchStudentsByGuardianId(
    String guardianId,
  ) async {
    List<Map<String, dynamic>> students = [];

    try {
      // البحث في جميع المراحل والفصول
      final stages = ['first', 'second', 'third'];
      for (var stage in stages) {
        final classes = ['1', '2', '3', '4', '5', '6'];
        for (var schoolClass in classes) {
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('stages')
                  .doc(stage)
                  .collection(schoolClass)
                  .where('guardianId', isEqualTo: guardianId)
                  .get();

          for (var doc in querySnapshot.docs) {
            students.add({
              "id": doc['id'],
              "name": doc['name'],
              "schoolClass": doc['schoolClass'],
              "stage": doc['stage'],
              "isChecked": false,
            });
          }
        }
      }
    } catch (e) {
      print("خطأ أثناء جلب بيانات الطلاب: $e");
    }

    return students;
  }

  void _toggleCheck(int index, List<Map<String, dynamic>> students) {
    setState(() {
      students[index]["isChecked"] = !students[index]["isChecked"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "التابعين",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _studentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("حدث خطأ: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("لا توجد طلاب مسجلين لهذا ولي الأمر."),
                    );
                  } else {
                    final students = snapshot.data!;
                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox(
                                value: students[index]["isChecked"],
                                onChanged: (value) {
                                  _toggleCheck(index, students);
                                },
                              ),
                              const SizedBox(width: 10),
                              Text(
                                students[index]["name"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 1, 113, 189),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  print("تم الضغط على التالي");
                },
                child: const Text(
                  "التالي",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
