import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:map/widgets/custom_text_field.dart';


import '../widgets/custom_button_auth.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  _TeacherListScreenState createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  Map<String, bool> selectedTeachers = {}; // المعلمون المحددون

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("المعلمون", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('teachers') // استبدال "admins" بـ "teachers"
                .where(
                  'schoolId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                )
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا يوجد معلمون"));
          }
          final teachers = snapshot.data!.docs;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    var teacher = teachers[index];
                    var teacherData = teacher.data() as Map<String, dynamic>;
                    String teacherId = teacher.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            teacherData['name'], // اسم المعلم
                            style: const TextStyle(fontSize: 18),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: selectedTeachers[teacherId] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                if (selectedTeachers.containsKey(teacherId) &&
                                    !value!) {
                                  selectedTeachers.remove(teacherId);
                                } else {
                                  selectedTeachers[teacherId] = value!;
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButtonAuth(
                        title: "حذف",
                        onPressed: () {
                          _showDeleteDialog();
                        },
                        color: const Color.fromRGBO(33, 150, 243, 1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButtonAuth(
                        title: "تعديل",
                        onPressed: () {
                          _editSelectedTeacher();
                        },
                        color: const Color.fromRGBO(33, 150, 243, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editSelectedTeacher() async {
    List<String> selectedIds =
        selectedTeachers.keys
            .where((id) => selectedTeachers[id] == true)
            .toList();
    if (selectedIds.isEmpty || selectedIds.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار معلم واحد فقط للتعديل")),
      );
      return;
    }
    String selectedId = selectedIds.first;
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('teachers')
              .doc(selectedId)
              .get();
      if (doc.exists) {
        Map<String, dynamic> teacherData = doc.data() as Map<String, dynamic>;
        _showEditDialog(context, selectedId, teacherData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء تحميل البيانات")),
      );
    }
  }

  Future<bool> _isPhoneAvailable(String phone, String currentTeacherId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('teachers')
              .where('phone', isEqualTo: phone)
              .get();
      return querySnapshot.docs.isEmpty ||
          (querySnapshot.docs.length == 1 &&
              querySnapshot.docs.first.id == currentTeacherId);
    } catch (e) {
      print("❌ خطأ أثناء التحقق من رقم الهاتف: $e");
      return false;
    }
  }

  Future<bool> _isEmailAvailable(String email, String currentTeacherId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('teachers')
              .where('email', isEqualTo: email)
              .get();
      return querySnapshot.docs.isEmpty ||
          (querySnapshot.docs.length == 1 &&
              querySnapshot.docs.first.id == currentTeacherId);
    } catch (e) {
      print("❌ خطأ أثناء التحقق من البريد الإلكتروني: $e");
      return false;
    }
  }

  void _showEditDialog(
    BuildContext context,
    String teacherId,
    Map<String, dynamic> teacherData,
  ) {
    TextEditingController nameController = TextEditingController(
      text: teacherData['name'],
    );
    TextEditingController idController = TextEditingController(
      text: teacherData['id'],
    );
    TextEditingController phoneController = TextEditingController(
      text: teacherData['phone'],
    );
    TextEditingController emailController = TextEditingController(
      text: teacherData['email'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "تعديل بيانات المعلم",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                icon: Icons.person,
                hintText: "اسم المعلم",
                iconColor: Colors.blue,
              ),
              CustomTextField(
                controller: idController,
                icon: Icons.badge,
                hintText: "رقم المعلم",
                iconColor: Colors.blue,
                enabled: false, // جعل الحقل غير قابل للتعديل
              ),
              CustomTextField(
                controller: phoneController,
                icon: Icons.phone,
                hintText: "رقم الهاتف",
                iconColor: Colors.blue,
              ),
              CustomTextField(
                controller: emailController,
                icon: Icons.email,
                hintText: "البريد الإلكتروني",
                iconColor: Colors.blue,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomButtonAuth(
                    title: "إلغاء",
                    onPressed: () => Navigator.pop(context),
                    color: const Color.fromRGBO(33, 150, 243, 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButtonAuth(
                    title: "حفظ",
                    onPressed: () async {
                      String name = nameController.text.trim();
                      String phone = phoneController.text.trim();
                      String email = emailController.text.trim();

                      // التحقق من أن جميع الحقول مملوءة
                      if (name.isEmpty || phone.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("جميع الحقول مطلوبة لإكمال العملية"),
                          ),
                        );
                        return;
                      }

                      // التحقق من صيغة رقم الهاتف
                      if (!phone.startsWith('05') || phone.length != 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "رقم الهاتف يجب أن يبدأ بـ '05' ويتكون من 10 أرقام",
                            ),
                          ),
                        );
                        return;
                      }

                      // التحقق من صيغة البريد الإلكتروني
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("صيغة البريد الإلكتروني غير صحيحة"),
                          ),
                        );
                        return;
                      }

                      // التحقق من أن رقم الهاتف غير مستخدم مسبقًا
                      bool isPhoneAvailable = await _isPhoneAvailable(
                        phone,
                        teacherId,
                      );
                      if (!isPhoneAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("رقم الهاتف هذا مستخدم مسبقًا"),
                          ),
                        );
                        return;
                      }

                      // التحقق من أن البريد الإلكتروني غير مستخدم مسبقًا
                      bool isEmailAvailable = await _isEmailAvailable(
                        email,
                        teacherId,
                      );
                      if (!isEmailAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "البريد الإلكتروني هذا مستخدم مسبقًا",
                            ),
                          ),
                        );
                        return;
                      }

                      // تحديث البيانات في Firestore
                      await FirebaseFirestore.instance
                          .collection('teachers')
                          .doc(teacherId)
                          .update({
                            'name': name,
                            'phone': phone,
                            'email': email,
                          });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم تعديل البيانات بنجاح"),
                        ),
                      );
                    },
                    color: const Color.fromRGBO(33, 150, 243, 1),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    List<String> selectedIds =
        selectedTeachers.keys
            .where((id) => selectedTeachers[id] == true)
            .toList();
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار معلم واحد على الأقل للحذف")),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "تأكيد العملية",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomButtonAuth(
                    title: "إلغاء",
                    onPressed: () => Navigator.pop(context),
                    color: const Color.fromRGBO(33, 150, 243, 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButtonAuth(
                    title: "حذف",
                    onPressed: () async {
                      for (String id in selectedIds) {
                        await FirebaseFirestore.instance
                            .collection('teachers')
                            .doc(id)
                            .delete();
                      }
                      setState(() {
                        selectedTeachers.clear();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تم حذف المعلمين بنجاح")),
                      );
                    },
                    color: const Color.fromRGBO(33, 150, 243, 1),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}