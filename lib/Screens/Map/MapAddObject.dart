import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';

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
  LatLng? _valvePosition;

  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateValveMarker();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateValveMarker() {
    final device = mqttPayloadProvider.mapModelInstance.data?.deviceList?[widget.index];
    final connectedObj = device?.connectedObject?.isNotEmpty == true
        ? device?.connectedObject!.first
        : null;

    if (connectedObj != null && connectedObj.lat != null && connectedObj.long != null) {
      final position = LatLng(connectedObj.lat!, connectedObj.long!);

      setState(() {
        _valvePosition = position;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('valve'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              connectedObj.status == null
                  ? BitmapDescriptor.hueOrange
                  : connectedObj.status == 1
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Valve Controller',
              snippet: 'Status: ${connectedObj.status ?? 'Unknown'}',
            ),
          ),
        );
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
    }
  }

  void _showConnectedObjects() {
    final connectedObjects = mqttPayloadProvider
        .mapModelInstance.data?.deviceList?[widget.index].connectedObject;
    print('connectedObjects---> ${widget.index} $connectedObjects');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: connectedObjects?.length ?? 0,
          itemBuilder: (context, index) {
            final object = connectedObjects![index];
            return ListTile(
              title: Text(object.name ?? ''),
              subtitle: Text('Lat: ${object.lat}, Long: ${object.long}'),
              onTap: () {
                _updateMarker(object.lat!, object.long!);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  void _updateMarker(double lat, double long) {
    final position = LatLng(lat, long);

    setState(() {
      _valvePosition = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('valve'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'Valve Controller',
            snippet: 'Status: 1',
          ),
        ),
      );
    });

    final device = mqttPayloadProvider.mapModelInstance.data?.deviceList?[widget.index];
    if (device != null && device.connectedObject?.isNotEmpty == true) {
      device.connectedObject![0].lat = lat;
      device.connectedObject![0].long = long;
      device.connectedObject![0].status = 1;
      mqttPayloadProvider.notifyListeners();
    }

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  void _searchLocation() {
    try {
      final input = _searchController.text.trim();
      final extracted = extractCoordinates(input);
      final coords = extracted.split(',');

      if (coords.length == 2) {
        final lat = double.parse(coords[0].trim());
        final long = double.parse(coords[1].trim());
        _updateMarker(lat, long);
      } else {
        throw Exception('Invalid coordinate format');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter coordinates as "lat, long" (e.g., 11.1326952, 76.9767822)'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valve Controller Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showConnectedObjects,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Area (e.g., 11.1326952, 76.9767822)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              markers: _markers,
              onTap: (LatLng latLng) {
                _updateMarker(latLng.latitude, latLng.longitude);
              },
            ),
          ),
        ],
      ),
    );
  }
}