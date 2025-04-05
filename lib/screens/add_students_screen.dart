import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/file_upload_widget.dart';

class AddStudentsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // خريطة لتحويل الأسماء العربية إلى الإنجليزية
  final Map<String, String> stageMap = {
    "أولى ثانوي": "first",
    "ثاني ثانوي": "second",
    "ثالث ثانوي": "third",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "إضافة طلاب",
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
          title: "إضافة طلاب",
          onConfirm: (fileName, fileData) async {
            if (fileData != null) {
              try {
                for (var row in fileData) {
                  if (row.isNotEmpty && row.length >= 5) {
                    // تم تحديث الشرط ليشمل العمود الخامس
                    // قراءة البيانات من الصف وتنسيقها
                    final studentId = row[0].trim();
                    final studentName = row[1].trim();
                    final schoolClass = row[2].trim();
                    final stage = row[3].trim();
                    final guardianId =
                        row[4].trim(); // إضافة خانة رقم ولي الأمر

                    // تحويل المرحلة إلى اللغة الإنجليزية
                    final formattedStage =
                        stageMap[stage] ?? stage.toLowerCase();

                    // التحقق من صحة المرحلة والكلاس
                    final validStages = ['first', 'second', 'third'];
                    final validClasses = ['1', '2', '3', '4', '5', '6'];

                    if (!validStages.contains(formattedStage)) {
                      print("مرحلة غير صالحة: $formattedStage");
                      continue;
                    }

                    if (!validClasses.contains(schoolClass)) {
                      print("كلاس غير صالح: $schoolClass");
                      continue;
                    }

                    // التحقق من صحة رقم ولي الأمر
                    if (guardianId.isEmpty) {
                      print("رقم ولي الأمر غير صالح: $guardianId");
                      continue;
                    }

                    // إضافة الطالب إلى Firestore
                    await firestore
                        .collection('stages') // المجموعة الرئيسية
                        .doc(formattedStage) // المرحلة (مثل "first")
                        .collection(schoolClass) // الكلاس (مثل "1")
                        .doc(studentId.toString()) // ID الطالب كمفتاح للمستند
                        .set({
                          'id': studentId,
                          'name': studentName,
                          'schoolClass': schoolClass,
                          'stage': formattedStage,
                          'guardianId': guardianId, // إضافة رقم ولي الأمر
                        });

                    print(
                      "تمت إضافة الطالب: $studentName في المرحلة: $formattedStage والكلاس: $schoolClass برقم ولي الأمر: $guardianId",
                    );
                  } else {
                    print("صف غير صالح: $row");
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("تم تخزين بيانات الطلاب بنجاح!")),
                );
              } catch (e) {
                print("خطأ أثناء التخزين: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("حدث خطأ أثناء التخزين: $e")),
                );
              }
            } else {
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
