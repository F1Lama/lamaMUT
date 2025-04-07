import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text("الطلبات السابقة",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {},
              color: Colors.grey[300],
              textColor: Colors.black,
              child: const Text("تصفية"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              height: 40,
              minWidth: 120,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fromDate != null
                          ? DateFormat('yyyy-MM-dd').format(fromDate!)
                          : "اختر التاريخ",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text("إلى", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      toDate != null
                          ? DateFormat('yyyy-MM-dd').format(toDate!)
                          : "اختر التاريخ",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            RequestCard(
              requestType: "طلب نداء",
              studentName: "سارة محمد",
              className: "١/٢",
              textColor: Colors.green,
            ),
            const SizedBox(height: 10),
            RequestCard(
              requestType: "طلب استئذان",
              studentName: "مريم محمد",
className: "١/٢",
              textColor: Colors.green,
            ),
            const SizedBox(height: 10),
            RequestCard(
              requestType: "طلب استئذان",
              studentName: "سالم محمد",
              className: "١/٢",
              textColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String requestType;
  final String studentName;
  final String className;
  final Color textColor;

  const RequestCard({
    Key? key,
    required this.requestType,
    required this.studentName,
    required this.className,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            requestType,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "الطالبة: $studentName",
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            "الصف: $className",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}