import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ChangeLocationScreen extends StatefulWidget {
  const ChangeLocationScreen({super.key});

  @override
  _ChangeLocationScreenState createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  late GoogleMapController mapController;
  late LatLng _initialPosition;
  late LocationData _currentLocation;

  @override
  void initState() {
    super.initState();
    _initialPosition = LatLng(0.0, 0.0); // البداية في موقع افتراضي
    _getCurrentLocation();
  }

  // جلب الموقع الحالي للمستخدم
  void _getCurrentLocation() async {
    var location = Location();
    try {
      _currentLocation = await location.getLocation();
      setState(() {
        _initialPosition = LatLng(
          _currentLocation.latitude!,
          _currentLocation.longitude!,
        );
      });
    } catch (e) {
      print("خطأ في جلب الموقع: $e");
    }
  }

  // عند إنشاء الخريطة
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تغيير موقع المدرسة"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('school'),
                position: _initialPosition,
                infoWindow: InfoWindow(title: 'موقع المدرسة'),
              ),
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _initialPosition = position.target;
              });
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // منطق حفظ الموقع
                print(
                  "الموقع الجديد: ${_initialPosition.latitude}, ${_initialPosition.longitude}",
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("حفظ الموقع الجديد"),
            ),
          ),
        ],
      ),
    );
  }
}
