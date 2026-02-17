import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import 'googlemap_model.dart';
import 'oro_map/getlatlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? _objectPosition;

  late MqttPayloadProvider mqttPayloadProvider;
  ConnectedObject? _selectedObject;
  bool _isDrawerOpen = false;
  double _drawerWidth = 280;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllMarkers();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Load all markers from device's connected objects
  void _loadAllMarkers() {
    final device =
    mqttPayloadProvider.mapModelInstance.data?.deviceList?[widget.index];

    final objects = device?.connectedObject;

    if (objects == null || objects.isEmpty) return;

    Set<Marker> newMarkers = {};

    for (var obj in objects) {
      if (obj.lat != null && obj.long != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(obj.name ?? obj.objectName ?? 'object_${objects.indexOf(obj)}'),
            position: LatLng(obj.lat!, obj.long!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              obj == _selectedObject
                  ? BitmapDescriptor.hueAzure
                  : obj.status == 1
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: obj.name ?? 'Connected Object',
              snippet:
              'Lat: ${obj.lat}, Long: ${obj.long}, Status: ${obj.status ?? "Unknown"}',
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  /// Update only the selected marker's position
  void _updateMarker(double lat, double long) {
    if (_selectedObject == null) return;

    final position = LatLng(lat, long);

    setState(() {
      // Remove old marker of selected object
      _markers.removeWhere((marker) =>
      marker.markerId.value ==
          (_selectedObject!.name ?? _selectedObject!.objectName));

      // Add updated marker with info always visible
      _markers.add(
        Marker(
          markerId: MarkerId(
              _selectedObject!.name ?? _selectedObject!.objectName ?? 'selected'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: _selectedObject?.name ?? 'Connected Object',
            snippet:
            'Lat: ${_selectedObject?.lat}, Long: ${_selectedObject?.long}, Status: ON',
          ),
        ),
      );
    });

    _selectedObject!.lat = lat;
    _selectedObject!.long = long;
    _selectedObject!.status = 1;

    mqttPayloadProvider.notifyListeners();

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  /// Search location and update marker
  void _searchLocation() async {
    final input = _searchController.text;
    final LatLng? result = await getLatLngFromInput(input);

    if (result != null) {
      _updateMarker(result.latitude, result.longitude);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter valid area name, map link or lat,long"),
        ),
      );
    }
  }

  String extractCoordinates(String input) {
    final regExp = RegExp(r"@(-?\d+\.\d+),(-?\d+\.\d+)");
    final match = regExp.firstMatch(input);

    if (match != null) {
      return '${match.group(1)},${match.group(2)}';
    }

    var coords = input.split(",");
    if (coords.length == 2) {
      return '${coords[0].trim()},${coords[1].trim()}';
    }

    return "Invalid coordinates format.";
  }


  LatLng _getInitialCameraPosition() {
    // 1️⃣ If selected object has valid lat/long → use it
    if (_selectedObject != null &&
        _selectedObject!.lat != null &&
        _selectedObject!.long != null &&
        _selectedObject!.lat != 0 &&
        _selectedObject!.long != 0) {
      return LatLng(_selectedObject!.lat!, _selectedObject!.long!);
    }

    // 2️⃣ Otherwise use first valid object
    final device =
    mqttPayloadProvider.mapModelInstance.data?.deviceList?[widget.index];

    final objects = device?.connectedObject;

    if (objects != null && objects.isNotEmpty) {
      for (var obj in objects) {
        if (obj.lat != null &&
            obj.long != null &&
            obj.lat != 0 &&
            obj.long != 0) {
          return LatLng(obj.lat!, obj.long!);
        }
      }
    }

    // 3️⃣ Final fallback (safe location)
    return const LatLng(11.1271, 78.6569);
  }


  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final objects = mqttPayloadProvider
        .mapModelInstance.data?.deviceList?[widget.index].connectedObject;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Location'),
        leading: IconButton(
          icon: Icon(_isDrawerOpen ? Icons.close : Icons.menu),
          onPressed: () {
            setState(() {
              _isDrawerOpen = !_isDrawerOpen;
            });
          },
        ),
      ),
      body: Row(
        children: [
          // ✅ Side Drawer Panel (Resizable)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? _drawerWidth : 0,
            color: Colors.white,
            child: _isDrawerOpen
                ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.teal.shade500,
                  child: const Text(
                    "Connected Objects",
                    style:
                    TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: objects == null || objects.isEmpty
                      ? const Center(
                      child: Text("No Connected Objects"))
                      : ListView.builder(
                    itemCount: objects.length,
                    itemBuilder: (context, index) {
                      final obj = objects[index];

                      return ListTile(
                        selected: obj == _selectedObject,
                        selectedTileColor:
                        Colors.blue.withOpacity(0.2),
                        title: Text(obj.name ??
                            obj.objectName ??
                            "Object"),
                        subtitle: Text(
                            "Lat: ${obj.lat}, Long: ${obj.long}\nStatus: ${obj.status ?? "Unknown"}"),
                        onTap: () {
                          setState(() {
                            _selectedObject = obj;
                          });

                          if (obj.lat != null &&
                              obj.long != null) {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(
                                    obj.lat!, obj.long!),
                                15,
                              ),
                            );
                          }

                          _loadAllMarkers();
                        },
                      );
                    },
                  ),
                ),
              ],
            )
                : null,
          ),

          // ✅ Map Area (Auto Resizes)
          Expanded(
            child: Column(
              children: [
                _buildSelectedObjectBar(),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText:
                            'Search Area (e.g., 11.1326952, 76.9767822)',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            _searchLocation();
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: _searchLocation,
                        child: const Text(
                          'Search',
                          style:
                          TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                 // Google Map
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _getInitialCameraPosition(),
                      zoom: 15,
                    ),
                    markers: _markers,
                    onTap: (LatLng latLng) {
                      _updateMarker(
                          latLng.latitude,
                          latLng.longitude);
                    },
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    compassEnabled: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSelectedObjectBar() {
    if (_selectedObject == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        color: Colors.grey.shade200,
        child: const Text(
          "No Object Selected",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      color: Colors.teal.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedObject!.name ??
                _selectedObject!.objectName ??
                "Connected Object",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
           Text(
            "Lat: ${_selectedObject!.lat ?? "-"}  "
                "Long: ${_selectedObject!.long ?? "-"}",
          ),
          Text(
            "Status: ${_selectedObject!.status == 1 ? "ON" : "OFF"}",
          ),
        ],
      ),
    );
  }

}

