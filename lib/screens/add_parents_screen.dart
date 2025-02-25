import 'package:flutter/material.dart';
import '../widgets/file_picker_widget.dart';

class AddParentsScreen extends StatefulWidget {
  @override
  _AddParentsScreenState createState() => _AddParentsScreenState();
}

class _AddParentsScreenState extends State<AddParentsScreen> {
  String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "إضافة أولياء الأمور",
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilePickerWidget(
              onFileSelected: (fileName) {
                setState(() {
                  selectedFileName = fileName;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 1, 113, 189),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                if (selectedFileName != null) {
                  print("تم تأكيد رفع الملف: $selectedFileName");
                } else {
                  print("لم يتم اختيار ملف بعد!");
                }
              },
              child: const Text(
                "تأكيد",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
