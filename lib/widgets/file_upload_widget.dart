import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadWidget extends StatefulWidget {
  final String title;
  final Function(String?, List<List<dynamic>>?) onConfirm;

  const FileUploadWidget({
    super.key,
    required this.title,
    required this.onConfirm,
  });

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? selectedFileName;
  List<List<dynamic>>? fileData; // لتخزين بيانات الملف

  // دالة لاختيار الملف
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
      });

      // قراءة محتوى الملف
      final fileBytes = result.files.single.bytes;
      if (fileBytes != null) {
        final fileContent = String.fromCharCodes(
          fileBytes,
        ); // تحويل الملف إلى نص
        fileData = parseCSV(fileContent); // تحليل الملف CSV
      }
    } else {
      print("لم يتم اختيار أي ملف");
    }
  }

  // دالة لتحليل ملف CSV
  List<List<dynamic>> parseCSV(String csvContent) {
    final rows = csvContent.split('\n'); // تقسيم الملف إلى صفوف
    return rows.map((row) => row.split(',')).toList(); // تقسيم كل صف إلى أعمدة
  }

  // دالة للتعامل مع زر التأكيد
  void confirmUpload(BuildContext context) {
    if (selectedFileName != null && fileData != null) {
      widget.onConfirm(selectedFileName, fileData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم رفع الملف بنجاح: $selectedFileName")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى اختيار ملف أولاً")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: pickFile,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                selectedFileName ?? "اختر ملف CSV",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 1, 113, 189),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () => confirmUpload(context), // استدعاء دالة التأكيد
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
    );
  }
}
