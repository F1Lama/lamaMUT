import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerWidget extends StatelessWidget {
  final Function(String?) onFileSelected;

  const FilePickerWidget({super.key, required this.onFileSelected});

  Future<void> pickFile(Function(String?) callback) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      callback(result.files.single.name);
    } else {
      callback(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pickFile(onFileSelected),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "اختر ملف CSV",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
