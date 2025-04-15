
import 'package:flutter/material.dart';


class AttendenceNames extends StatelessWidget {
  final List<Map<String, dynamic>> students = [
    {"name": "مريم خالد", "status": "غياب", "color": Colors.red},
    {"name": "رهف محمد", "status": "حضور", "color": Colors.green},
    {"name": "", "status": "غياب", "color": Colors.red},
    {"name": "", "status": "تأخير", "color": Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("فصل 1/1", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: students.map((student) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      student["name"],
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: student["color"],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            Spacer(),
            MaterialButton(
              onPressed: () {},
              color: Color.fromARGB(255, 1, 113, 189),
              textColor: Colors.white,
              child: Text("تعديل"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              height: 50,
              minWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}