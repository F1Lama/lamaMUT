// study_stage_screen.dart
import 'package:flutter/material.dart';
import 'package:map/screens/class_screen.dart'; // استيراد صفحة classScreen
import 'package:map/widgets/teacher_custom_drawer.dart'; // استيراد القائمة الجانبية

class StudyStageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("المعلمين", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // العودة إلى الصفحة السابقة
            Navigator.pop(context);
          },
        ),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(
                      context,
                    ).openEndDrawer(); // فتح القائمة الجانبية
                  },
                ),
          ),
        ],
      ),
      endDrawer: TeacherCustomDrawer(), // القائمة الجانبية
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              ":طلبات الخروج من الحصة",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            CustomButton(
              title: "طلب جديد",
              onPressed: () {
                // الانتقال إلى صفحة classScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassScreen()),
                );
              },
            ),
            SizedBox(height: 15),
            CustomButton(title: "الطلبات السابقة", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const CustomButton({required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 250,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: const Color.fromARGB(255, 1, 113, 189),
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text(title, style: TextStyle(fontSize: 18)),
    );
  }
}
