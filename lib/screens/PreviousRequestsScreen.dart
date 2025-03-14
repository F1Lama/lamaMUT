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
  Stream<QuerySnapshot>? _filteredStream;

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

  void _applyFilter() {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى اختيار نطاق التاريخ كاملًا.")),
      );
      return;
    }

    setState(() {
      _filteredStream =
          FirebaseFirestore.instance
              .collection('requests')
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
                _buildDateSelector(
                  "من",
                  fromDate,
                  () => _selectDate(context, true),
                ),
                SizedBox(width: 10),
                _buildDateSelector(
                  "إلى",
                  toDate,
                  () => _selectDate(context, false),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("تصفية", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _filteredStream ??
                    FirebaseFirestore.instance
                        .collection('requests')
                        .orderBy('exitTime', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("حدث خطأ: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final requests = snapshot.data!.docs;
                  if (requests.isEmpty) {
                    return Center(child: Text("لا توجد طلبات."));
                  }
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final data =
                          requests[index].data() as Map<String, dynamic>;
                      return _buildRequestTile(data);
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

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date != null ? DateFormat('yyyy-MM-dd').format(date) : label,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildRequestTile(Map<String, dynamic> data) {
    final studentName = data['studentName'] ?? 'غير معروف';
    final grade = data['grade'] ?? 'غير معروف';
    final exitTime =
        (data['exitTime'] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedExitTime = DateFormat('yyyy-MM-dd HH:mm').format(exitTime);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("الطالب: $studentName", style: TextStyle(fontSize: 16)),
          Text("الصف: $grade", style: TextStyle(fontSize: 16)),
          Text(
            "وقت الخروج: $formattedExitTime",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
