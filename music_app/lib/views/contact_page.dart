// 📁 contact_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/drawer_menu.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {

  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  double initialLatitude = 43.4643;
  double initialLongitude = -80.5204;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("office"),
          position: LatLng(initialLatitude, initialLongitude),
          infoWindow: InfoWindow(title: "MusicApp Main Office")));
    });
  }

  @override
  Widget build(BuildContext context) {
    const LatLng location = LatLng(43.4643, -80.5204); // Waterloo

    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 3,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(initialLatitude, initialLongitude),
                        zoom: 14.0),
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildContactRow(Icons.location_on, "123 Example St, Waterloo, ON"),
              _buildContactRow(Icons.email, "musicapp@domain.com"),
              _buildContactRow(Icons.phone, "(+1) 123-123-1234"),
              _buildContactRow(Icons.alternate_email, "@musicApp"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(icon, color: AppColors.background),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}