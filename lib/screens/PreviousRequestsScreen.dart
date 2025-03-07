import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PreviousRequestsScreen extends StatefulWidget {
  @override
  _PreviousRequestsScreenState createState() => _PreviousRequestsScreenState();
}

class _PreviousRequestsScreenState extends State<PreviousRequestsScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Stream<QuerySnapshot>? _filteredStream;

  void _applyFilter() {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("يرجى اختيار نطاق تاريخ كامل.")));
      return;
    }

    // طباعة نطاق التاريخ للتحقق
    print("From Date: ${fromDate.toString()}");
    print("To Date: ${toDate.toString()}");

    setState(() {
      _filteredStream =
          FirebaseFirestore.instance
              .collection('requests')
              .where('status', whereIn: ['expired', 'cancelled'])
              .where(
                'exitTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate!),
              )
              .where(
                'exitTime',
                isLessThanOrEqualTo: Timestamp.fromDate(toDate!),
              )
              .orderBy('exitTime', descending: true)
              .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("الطلبات السابقة", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    width: 120,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      fromDate != null
                          ? DateFormat('yyyy-MM-dd').format(fromDate!)
                          : "اختر التاريخ",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text("إلى", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    width: 120,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      toDate != null
                          ? DateFormat('yyyy-MM-dd').format(toDate!)
                          : "اختر التاريخ",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _applyFilter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "تصفية",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _filteredStream ??
                    FirebaseFirestore.instance
                        .collection('requests')
                        .where('status', whereIn: ['expired', 'cancelled'])
                        .orderBy('exitTime', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("خطأ: ${snapshot.error.toString()}"),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final requests = snapshot.data!.docs;

                  // طباعة عدد الطلبات المجلوبة للتحقق
                  print("Number of requests fetched: ${requests.length}");

                  if (requests.isEmpty) {
                    return Center(
                      child: Text(
                        "لا توجد طلبات سابقة.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final data = request.data() as Map<String, dynamic>;
                      try {
                        final exitTime =
                            (data['exitTime'] as Timestamp).toDate();
                        final status = data['status'];

                        return _buildRequestTile(
                          data['studentName'],
                          data['grade'],
                          DateFormat('yyyy-MM-dd HH:mm').format(exitTime),
                          status,
                        );
                      } catch (e) {
                        return ListTile(
                          title: Text("خطأ في عرض الطلب: ${e.toString()}"),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTile(
    String studentName,
    String grade,
    String exitTime,
    String status,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "طلب تصريح خروج",
            style: TextStyle(fontSize: 16, color: Colors.green),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            "الطالب: $studentName",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            "الصف: $grade",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            "وقت الخروج: $exitTime",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            "الحالة: $status",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
