import 'package:flutter/material.dart';
import 'package:map/screens/logout.dart';

class TeacherCustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          drawerItem(
            title: "تسجيل خروج",
            icon: Icons.logout,
            onTap: () {
              // تنفيذ تسجيل الخروج كما في LogoutScreen
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/HomeScreen', // استبدلها بمسار الصفحة الرئيسية
                (route) => false, // إزالة جميع الصفحات الأخرى من المكدس
              );
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
