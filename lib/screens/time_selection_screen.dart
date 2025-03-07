import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:map/screens/exit_permits_screen.dart';

class TimeSelectionScreen extends StatefulWidget {
  final String studentName; // اسم الطالب المحدد
  final String grade; // الصف الدراسي
  final String teacherName; // اسم المعلمة

  TimeSelectionScreen({
    required this.studentName,
    required this.grade,
    required this.teacherName,
  });

  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  bool isTenMinutesSelected = false;
  bool isOtherSelected = false;
  Duration selectedDuration = Duration(minutes: 3);

  void _showTimerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.ms,
            initialTimerDuration: selectedDuration,
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                selectedDuration = newDuration;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("تحديد الوقت", style: TextStyle(color: Colors.white)),
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
            Text(
              "اسم الطالب: ${widget.studentName}", // عرض اسم الطالب
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isTenMinutesSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      isTenMinutesSelected = value!;
                      isOtherSelected = false;
                      selectedDuration = Duration(
                        minutes: 10,
                      ); // تحديد مدة 10 دقائق
                    });
                  },
                ),
                Text("10 دقائق"),
                SizedBox(width: 20),
                Checkbox(
                  value: isOtherSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      isOtherSelected = value!;
                      isTenMinutesSelected = false;
                    });
                  },
                ),
                GestureDetector(
                  onTap:
                      isOtherSelected ? () => _showTimerPicker(context) : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isOtherSelected
                              ? "${selectedDuration.inMinutes} دقيقة"
                              : "أخرى",
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_drop_down, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            MaterialButton(
              onPressed: () {
                // حساب وقت الخروج بناءً على الوقت الحالي والمدة المحددة
                DateTime now = DateTime.now();
                DateTime exitTime = now.add(selectedDuration);

                // إضافة بيانات الطلب إلى Firestore
                ExitPermitsScreen.addStudent(
                  studentName: widget.studentName,
                  grade: widget.grade,
                  teacherName: widget.teacherName,
                  exitTime: exitTime.toIso8601String(), // تخزين الوقت بصيغة ISO
                );

                Navigator.pop(context); // العودة إلى الصفحة السابقة
              },
              color: Color.fromARGB(255, 1, 113, 189),
              textColor: Colors.white,
              child: Text("تأكيد"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              height: 50,
              minWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
