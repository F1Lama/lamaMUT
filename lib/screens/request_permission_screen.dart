import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class RequestPermissionScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String schoolId; // ✅ إضافة schoolId

  const RequestPermissionScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.schoolId,
  }) : super(key: key);

  @override
  _RequestPermissionScreenState createState() => _RequestPermissionScreenState();
}

class _RequestPermissionScreenState extends State<RequestPermissionScreen> {
  final TextEditingController reasonController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  PlatformFile? pickedFile;
  String? uploadedFileUrl;

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          pickedFile = result.files.first;
        });
        final storageRef = FirebaseStorage.instance.ref().child(
          'excuse_files/${pickedFile!.name}',
        );
        final uploadTask = storageRef.putData(pickedFile!.bytes!);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          uploadedFileUrl = downloadUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء اختيار أو تحميل الملف: $e')),
      );
    }
  }

  Future<void> _submitRequest() async {
    if (_validateFields()) {
      try {
        // إعداد بيانات المرحلة والصف بشكل افتراضي مؤقت (تستطيع ربطه ببيانات الطالب لاحقاً)
        final stage = "ثالث ثانوي"; // ملاحظة: يمكنك تعديل هذا بحسب بيانات الطالب لاحقاً
        final schoolClass = "3";
        final grade = "$stage/$schoolClass";

        await FirebaseFirestore.instance.collection('exitPermits').add({
          'studentId': widget.studentId,
          'studentName': widget.studentName,
          'schoolClass': schoolClass,
          'reason': reasonController.text.trim(),
          'date': selectedDate != null
              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
              : '',
          'time': selectedTime != null ? _formatTime(selectedTime!) : '',
          'attachedFileUrl': uploadedFileUrl ?? '',
          'timestamp': DateTime.now(),
          'grade': grade,
          'status': null, // ✅ لضمان التوافق مع الفلترة
          'schoolId': widget.schoolId, // ✅ تخزين schoolId
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إرسال الطلب بنجاح!")),
        );
        _clearFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء إرسال الطلب: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('طلب الاستئذان', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              CustomLabel(text: 'السبب'),
              CustomTextField(controller: reasonController, hintText: 'اكتب السبب هنا'),
              CustomLabel(text: 'التاريخ'),
              InkWell(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                          : 'اختر التاريخ',
                    ),
                    hintText: 'اختر التاريخ',
                  ),
                ),
              ),
              CustomLabel(text: 'الوقت'),
              InkWell(
                onTap: _selectTime,
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: TextEditingController(
                      text: selectedTime != null
                          ? _formatTime(selectedTime!)
                          : 'اختر الوقت',
                    ),
                    hintText: 'اختر الوقت',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomLabel(text: 'إرفاق ملف PDF (اختياري)'),
              InkWell(
                onTap: _pickAndUploadFile,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      pickedFile != null
                          ? "ملف مرفوع: ${pickedFile!.name}"
                          : "اضغط لاختيار ملف PDF",
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  height: 50,
                  color: const Color.fromARGB(255, 1, 113, 189),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  onPressed: _submitRequest,
                  child: const Text('إرسال', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _validateFields() {
    if (reasonController.text.isEmpty || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return false;
    }
    return true;
  }

  void _clearFields() {
    reasonController.clear();
    setState(() {
      selectedDate = null;
      selectedTime = null;
      pickedFile = null;
      uploadedFileUrl = null;
    });
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class CustomLabel extends StatelessWidget {
  final String text;

  const CustomLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
