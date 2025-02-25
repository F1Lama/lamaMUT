import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_drawer.dart';
import '../utils/navigation_helper.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "الإداريين",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(
                      context,
                    ).openEndDrawer(); // فتح القائمة الجانبية
                  },
                ),
          ),
        ],
      ),
      endDrawer: CustomDrawer(), // القائمة الجانبية
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://i.postimg.cc/DwnKf079/321e9c9d-4d67-4112-a513-d368fc26b0c0.jpg',
                width: 200,
                height: 189,
              ),
              const SizedBox(height: 70),
              CustomButton(
                title: "طلبات الاستئذان",
                onPressed:
                    () => NavigationHelper.navigateTo(
                      context,
                      '/PermissionRequests',
                    ),
              ),
              const SizedBox(height: 35),
              CustomButton(
                title: "تصاريح الخروج من الحصة",
                onPressed:
                    () => NavigationHelper.navigateTo(context, '/ExitPermits'),
              ),
              const SizedBox(height: 35),
              CustomButton(
                title: "حضور الطلاب",
                onPressed:
                    () => NavigationHelper.navigateTo(
                      context,
                      '/StudentAttendance',
                    ),
              ),
              const SizedBox(height: 35),
              CustomButton(
                title: "الطلبات السابقة",
                onPressed:
                    () => NavigationHelper.navigateTo(
                      context,
                      '/PreviousRequests',
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
