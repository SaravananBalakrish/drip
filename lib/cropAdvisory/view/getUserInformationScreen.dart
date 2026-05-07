import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:oro_drip_irrigation/cropAdvisory/view/CropDetailsScreen.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/AppTextField.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/ContinueButton.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/ProgressWidget.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/SectionCard.dart';
import 'package:oro_drip_irrigation/cropAdvisory/view/map_picker_screen.dart';
import 'package:oro_drip_irrigation/cropAdvisory/service/location_service.dart';


class Getuserinformationscreen extends StatefulWidget {
  const Getuserinformationscreen({super.key});

  @override
  State<Getuserinformationscreen> createState() => _GetuserinformationscreenState();
}

class _GetuserinformationscreenState extends State<Getuserinformationscreen> {
  // --- Location related ---
  double? _latitude;
  double? _longitude;
  String _selectedAddress = '';
  final TextEditingController _locationController = TextEditingController();
  final LocationService _locationService = LocationService();

  // --- Other fields ---
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _farmIdController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _areaController.dispose();
    _farmIdController.dispose();
    super.dispose();
  }

  // Opens the full-screen map for manual selection
  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _locationController.text = result['address'] ?? '$_latitude, $_longitude';
        _selectedAddress = _locationController.text;
      });
    }
  }

  // Uses device GPS directly (the suffix icon action)
  Future<void> _getCurrentLocationOnly() async {
    try {
      final position = await _locationService.getCurrentLocation();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String address = '';
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        // Build a readable address
        address = [
          pm.street,
          pm.locality,
          pm.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
      if (address.isEmpty) {
        address = '${position.latitude}, ${position.longitude}';
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text = address;
        _selectedAddress = address;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crop Advisory")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Let's get started",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Tell us a bit about you to set up your farm profile.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const ProgressWidget(current: 1),
                const SizedBox(height: 20),

                // ---------- Location Field ----------
                SectionCard(
                  title: 'Share Location',
                  icon: Icons.location_on_outlined,
                  child: GestureDetector(
                    onTap: _openMapPicker,
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: _locationController,
                        hint: 'Search Or Use Current Location',
                        readOnly: true,
                        suffix: GestureDetector(
                          onTap: _getCurrentLocationOnly,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ),
                  ),
                ),

                // ---------- Area Field ----------
                SectionCard(
                  title: 'Area(acre/ hectare)',
                  icon: Icons.map_outlined,
                  child: AppTextField(
                    controller: _areaController,
                    hint: '10(acre)',
                    suffix: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                // ---------- Plot / Farm ID ----------
                SectionCard(
                  title: 'Plot / farm ID',
                  icon: Icons.edit,
                  child: AppTextField(
                    controller: _farmIdController,
                    hint: 'Enter The Plot Or Farm ID',
                  ),
                ),

                const SizedBox(height: 30),

                // ---------- Continue Button ----------
                CropContinueButton(
                  onTap: () {
                    if (_latitude == null || _longitude == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a location')),
                      );
                      return;
                    }
                    // Pass all collected data to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CropDetailsScreen(
                          latitude: _latitude,
                          longitude: _longitude,
                          address: _selectedAddress,
                          area: _areaController.text,
                          farmId: _farmIdController.text,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}