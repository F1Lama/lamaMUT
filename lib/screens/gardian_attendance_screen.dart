import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceRecords = [
    {"day": "الأحد", "date": "٣/١", "status": "حاضر", "color": Colors.green},
    {
      "day": "الاثنين",
      "date": "٣/٢",
      "status": "متأخر",
      "color": Colors.orange,
    },
    {"day": "الثلاثاء", "date": "٣/٣", "status": "حاضر", "color": Colors.green},
    {"day": "الأربعاء", "date": "٣/٤", "status": "غائب", "color": Colors.red},
    {"day": "الخميس", "date": "٣/٥", "status": "حاضر", "color": Colors.green},
    {"day": "الأحد", "date": "٣/٨", "status": "حاضر", "color": Colors.green},
    {"day": "الاثنين", "date": "٣/٩", "status": "حاضر", "color": Colors.green},
    {
      "day": "الثلاثاء",
      "date": "٣/١٠",
      "status": "حاضر",
      "color": Colors.green,
    },
    {
      "day": "الأربعاء",
      "date": "٣/١١",
      "status": "حاضر",
      "color": Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "سجل الحضور",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "معلومات الطالبة: مريم خالد",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "الصف: ١/٢",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "الحالة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "اليوم / التاريخ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Column(
                    children:
                        attendanceRecords
                            .map(
                              (record) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: record["color"],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          record["status"],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${record["day"]} ${record["date"]}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
