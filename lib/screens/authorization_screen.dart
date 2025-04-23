import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorizationScreen extends StatefulWidget {
  final String guardianId; // معرف ولي الأمر

  const AuthorizationScreen({Key? key, required this.guardianId})
    : super(key: key);

  @override
  _AuthorizationScreenState createState() => _AuthorizationScreenState();
}

class _AuthorizationScreenState extends State<AuthorizationScreen> {
  // المتحكمات الخاصة بالحقول النصية
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dependentIdController = TextEditingController();

  // قائمة لتخزين التابعين المختارين
  final List<Map<String, dynamic>> selectedDependents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التوكيل', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // العودة إلى الصفحة السابقة
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40), // المسافة بين الحقول والشريط العلوي
            // حقل اسم الوكيل
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم الوكيل',
                labelStyle: const TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.blue),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 10),

            // حقل رقم الهوية
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'رقم الهوية',
                labelStyle: const TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge, color: Colors.blue),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 10),

            // حقل كلمة المرور
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                labelStyle: const TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 10),

            // حقل هوية التابع
            TextField(
              controller: dependentIdController,
              decoration: InputDecoration(
                labelText: 'هوية التابع',
                labelStyle: const TextStyle(color: Colors.black54),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group, color: Colors.blue),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 20),

            // زر إضافة التابع
            ElevatedButton(
              onPressed: () async {
                final dependentId = dependentIdController.text.trim();
                if (dependentId.isNotEmpty) {
                  final dependent = await _validateDependent(dependentId);
                  if (dependent != null) {
                    _addDependent(dependent); // إضافة التابع إلى القائمة
                    dependentIdController.clear(); // مسح الحقل
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("يرجى إدخال هوية التابع")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 113, 189),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text("إضافة التابع"),
            ),

            const SizedBox(height: 20),

            // عرض التابعين المختارين
            Text(
              "التابعون المختارون:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: selectedDependents.length,
                itemBuilder: (context, index) {
                  final dependent = selectedDependents[index];
                  return ListTile(
                    title: Text(dependent["name"]),
                    subtitle: Text("الهوية: ${dependent["id"]}"),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        _removeDependent(dependent);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // زر تسجيل التوكيل
            ElevatedButton(
              onPressed: () async {
                if (await _validateFields()) {
                  try {
                    // إنشاء حساب جديد باستخدام Firebase Authentication
                    final userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                          email:
                              "${idController.text}@example.com", // استخدام رقم الهوية كبريد إلكتروني
                          password: passwordController.text,
                        );

                    // استخراج معرف Firebase (uid) ليكون هو agentId
                    final String agentId = userCredential.user!.uid;

                    // حفظ بيانات الحساب في Firestore
                    await FirebaseFirestore.instance
                        .collection('Authorizations')
                        .doc(agentId)
                        .set({
                          'name': nameController.text,
                          'id': idController.text,
                          'password': passwordController.text,
                          'guardianId': widget.guardianId, // معرف ولي الأمر
                        });

                    // حفظ بيانات التابعين المختارين مع حساب الوكيل
                    await _saveDependentsToFirestore(agentId);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم تسجيل التوكيل بنجاح")),
                    );
                  } catch (e) {
                    print("❌ خطأ أثناء التسجيل: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("حدث خطأ أثناء تسجيل التوكيل"),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 113, 189),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text("تسجيل"),
            ),
          ],
        ),
      ),
    );
  }

  // دالة للتحقق من وجود التابع في Firestore
  Future<Map<String, dynamic>?> _validateDependent(String dependentId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('students') // البحث في كولكشن الطلاب
              .where('id', isEqualTo: dependentId) // التحقق من الحقل 'id'
              .where(
                'guardianId',
                isEqualTo: widget.guardianId,
              ) // التحقق من الحقل 'guardianId'
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final dependentData = querySnapshot.docs.first.data();
        return {"id": dependentData['id'], "name": dependentData['name']};
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("هذا التابع غير مسجل كتابع لولي الأمر")),
        );
        return null;
      }
    } catch (e) {
      print("❌ خطأ أثناء التحقق من التابع: $e");
      return null;
    }
  }

  // دالة لإضافة التابع إلى القائمة
  void _addDependent(Map<String, dynamic> dependent) {
    setState(() {
      if (!selectedDependents.contains(dependent)) {
        selectedDependents.add(dependent);
      }
    });
  }

  // دالة لإزالة التابع من القائمة
  void _removeDependent(Map<String, dynamic> dependent) {
    setState(() {
      selectedDependents.remove(dependent);
    });
  }

  // دالة للتحقق من صحة الحقول
  Future<bool> _validateFields() async {
    final name = nameController.text.trim();
    final id = idController.text.trim();
    final password = passwordController.text.trim();

    // التحقق من أن جميع الحقول مملوءة
    if (name.isEmpty || id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("جميع الحقول مطلوبة لإكمال العملية")),
      );
      return false;
    }

    // التحقق من أن الـ ID غير مستخدم مسبقًا
    final isIdAvailable = await _isIdAvailable(id);
    if (!isIdAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("رقم الموكل هذا مستخدم مسبقًا")),
      );
      return false;
    }

    // التحقق من صيغة كلمة المرور
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,20}$',
    );
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "كلمة المرور يجب أن تحتوي على أحرف كبيرة وصغيرة وأرقام",
          ),
        ),
      );
      return false;
    }

    return true;
  }

  // دالة للتحقق من أن الـ ID غير مستخدم مسبقًا
  Future<bool> _isIdAvailable(String id) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('Authorizations')
              .where('id', isEqualTo: id)
              .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print("❌ خطأ أثناء التحقق من الـ ID: $e");
      return false;
    }
  }

  // دالة لحفظ بيانات التابعين في Firestore
  Future<void> _saveDependentsToFirestore(String agentId) async {
    try {
      for (var dependent in selectedDependents) {
        await FirebaseFirestore.instance.collection('AgentDependents').add({
          'agentId': agentId, // معرف الوكيل (uid)
          'dependentId': dependent["id"], // معرف التابع
          'dependentName': dependent["name"], // اسم التابع
        });
      }
    } catch (e) {
      print("❌ خطأ أثناء حفظ بيانات التابعين: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء حفظ بيانات التابعين")),
      );
    }
  }
}
