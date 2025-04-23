import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgentChildrenScreen extends StatefulWidget {
  final String agentId; // معرف الوكيل

  const AgentChildrenScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  _AgentChildrenScreenState createState() => _AgentChildrenScreenState();
}

class _AgentChildrenScreenState extends State<AgentChildrenScreen> {
  late Future<List<Map<String, dynamic>>> _dependentsFuture;

  @override
  void initState() {
    super.initState();
    // جلب بيانات التابعين عند بدء الصفحة
    _dependentsFuture = _fetchDependentsByAgentId(widget.agentId);
  }

  // دالة لجلب بيانات التابعين من Firestore بناءً على معرف الوكيل
  Future<List<Map<String, dynamic>>> _fetchDependentsByAgentId(String agentId) async {
    try {
      print("Fetching dependents for agentId: $agentId"); // طباعة قيمة agentId للتحقق
      final querySnapshot = await FirebaseFirestore.instance
          .collection('AgentDependents') // الكولكشن التي تحتوي على بيانات التابعين
          .where('agentId', isEqualTo: agentId) // التحقق من أن التابع مرتبط بالوكيل
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("Found ${querySnapshot.docs.length} dependents"); // طباعة عدد التابعين
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      } else {
        print("No dependents found for agentId: $agentId"); // طباعة رسالة عدم وجود بيانات
        return [];
      }
    } catch (e) {
      print("❌ Error fetching dependents: $e"); // طباعة الخطأ
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التابعون', style: TextStyle(color: Colors.white)),
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _dependentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // عرض مؤشر التحميل أثناء جلب البيانات
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // عرض رسالة خطأ إذا حدث خطأ أثناء جلب البيانات
              return Center(child: Text("حدث خطأ أثناء جلب بيانات التابعين"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // عرض رسالة إذا لم يكن هناك تابعون مرتبطون بالوكيل
              return Center(child: Text("لا يوجد تابعون مرتبطون بهذا الحساب"));
            } else {
              // عرض قائمة التابعين
              final dependents = snapshot.data!;
              return ListView.builder(
                itemCount: dependents.length,
                itemBuilder: (context, index) {
                  final dependent = dependents[index];
                  return ListTile(
                    title: Text(dependent['dependentName']), // اسم التابع
                    subtitle: Text("الهوية: ${dependent['dependentId']}"), // هوية التابع
                    trailing: Icon(Icons.person, color: Colors.blue), // أيقونة بجانب الاسم
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}