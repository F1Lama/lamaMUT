import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherProvider with ChangeNotifier {
  String? _teacherId;
  String? _teacherName;

  // Getters لاسترجاع البيانات
  String? get teacherId => _teacherId;
  String? get teacherName => _teacherName;

  // دالة لتعيين بيانات المعلم يدويًا
  void setTeacherData(String id, String name) {
    _teacherId = id;
    _teacherName = name;
    notifyListeners(); // إشعار المستمعين بتحديث البيانات
  }

  // دالة لمسح بيانات المعلم
  void clearTeacherData() {
    _teacherId = null;
    _teacherName = null;
    notifyListeners(); // إشعار المستمعين بتحديث البيانات
  }

  // دالة لجلب بيانات المعلم من Firestore باستخدام teacherId
  Future<void> fetchTeacherData(String teacherId) async {
    try {
      // جلب بيانات المعلم من Firestore باستخدام المعرف (teacherId)
      final doc = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (!doc.exists) {
        throw Exception("لم يتم العثور على بيانات المعلم");
      }

      // التحقق من وجود الحقول المطلوبة
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('name')) {
        throw Exception("بيانات المعلم غير مكتملة");
      }

      // تحديث بيانات المعلم
      setTeacherData(doc.id, data['name']);
      print("✅ تم جلب بيانات المعلم بنجاح: $teacherName");
    } catch (e) {
      print("❌ خطأ أثناء جلب بيانات المعلم: $e");
      rethrow; // إعادة رفع الخطأ ليتم التعامل معه في الصفحة
    }
  }
}