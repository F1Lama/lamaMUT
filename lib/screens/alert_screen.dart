import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AlertScreen());
  }
}

class AlertScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة التحذير
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 130),

              SizedBox(height: 20),

              // نص التنبيه
              Text(
                "هل ترغب بإرسال تنبيه للإدارة ؟",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              // أزرار الإرسال والإلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButtonAuth(
                    title: "إلغاء",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 15),
                  CustomButtonAuth(
                    title: "إرسال",
                    onPressed: () {
                      // تنفيذ أمر الإرسال هنا
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("تم إرسال التنبيه")),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButtonAuth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;

  const CustomButtonAuth({Key? key, this.onPressed, required this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170, // عرض الزر
      child: MaterialButton(
        height: 45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: const Color.fromARGB(255, 1, 113, 189),
        textColor: Colors.white,
        onPressed: onPressed,
        child: Text(title, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
