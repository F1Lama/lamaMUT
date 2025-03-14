import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map/screens/PreviousRequestsScreen.dart';
import 'package:map/screens/class_screen.dart';
import 'alert_screen.dart'; // استيراد صفحة AlertScreen

class StudyStageScreen extends StatefulWidget {
  final Duration exitDuration; // المدة المحددة

  StudyStageScreen({required this.exitDuration});

  @override
  _StudyStageScreenState createState() => _StudyStageScreenState();
}

class _StudyStageScreenState extends State<StudyStageScreen>
    with WidgetsBindingObserver {
  DateTime? exitTime; // وقت انتهاء الطلب
  bool isTimerFinished = false; // لتحديد ما إذا انتهى المؤقت أم لا

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    exitTime = DateTime.now().add(widget.exitDuration); // استخدام المدة المحددة
    startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // عندما يعود المستخدم إلى التطبيق، تحقق من الوقت المتبقي
      if (exitTime != null && DateTime.now().isAfter(exitTime!)) {
        setState(() {
          isTimerFinished = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlertScreen()),
        );
      }
    }
  }

  void startTimer() {
    if (exitTime != null) {
      Duration remainingTime = exitTime!.difference(DateTime.now());
      if (remainingTime > Duration.zero) {
        print("المؤقت بدأ. الوقت المتبقي: ${remainingTime.inSeconds} ثانية");
        Timer(remainingTime, () {
          print("المؤقت انتهى!");
          setState(() {
            isTimerFinished = true;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlertScreen()),
          );
        });
      } else {
        print("الوقت قد انتهى بالفعل.");
        setState(() {
          isTimerFinished = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlertScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("المعلمين", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassScreen()),
                );
              },
            ),
            SizedBox(height: 15),
            CustomButton(
              title: "الطلبات السابقة",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviousRequestsScreen(),
                  ),
                );
              },
            ),
            if (isTimerFinished)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "انتهت مدة الخروج!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
