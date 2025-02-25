import 'package:flutter/material.dart';
import '../screens/add_parents_screen.dart';
import '../screens/add_students_screen.dart';
import '../screens/add_teachers_screen.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40), // مسافة من الأعلى
          drawerItem(
            title: "إضافة أولياء الأمور",
            icon: Icons.add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddParentsScreen()),
              );
            },
          ),
          drawerItem(
            title: "إضافة طلاب",
            icon: Icons.add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddStudentsScreen()),
              );
            },
          ),
          drawerItem(
            title: "إضافة المعلمين",
            icon: Icons.add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTeachersScreen()),
              );
            },
          ),
          drawerItem(
            title: "الأعذار المرفقة",
            icon: Icons.attachment,
            onTap: () {
              print("الأعذار المرفقة");
            },
          ),
          const Spacer(), // دفع "تسجيل خروج" للأسفل
          drawerItem(
            title: "تسجيل خروج",
            icon: Icons.logout,
            onTap: () {
              print("تسجيل خروج");
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget drawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
