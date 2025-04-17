import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreenArea extends StatefulWidget {
  const MapScreenArea({super.key});

  @override
  State<MapScreenArea> createState() => _MapScreenAreaState();
}

class _MapScreenAreaState extends State<MapScreenArea> {
  late GoogleMapController _mapController;

  // Initial camera position
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.166315, 76.125778),
    zoom: 15,
  );
    final List<LatLng> _polygonPoints = [];

   final Set<Polygon> _polygons = {};

   final Set<Marker> _markers = {};

   Map<String, List<LatLng>> _savedAreas = {};

  @override
  void initState() {
    super.initState();
    _loadSavedAreas();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Load saved areas from SharedPreferences
  Future<void> _loadSavedAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAreas = prefs.getString('saved_areas') ?? '{}';
    final decoded = jsonDecode(savedAreas) as Map<String, dynamic>;
    setState(() {
      _savedAreas = decoded.map((key, value) => MapEntry(
        key,
        (value as List).map((point) {
          final coords = point as Map<String, dynamic>;
          return LatLng(coords['latitude'], coords['longitude']);
        }).toList(),
      ));
    });
  }

  // Save areas to SharedPreferences
  Future<void> _saveAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_savedAreas.map((key, value) => MapEntry(
      key,
      value
          .map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      })
          .toList(),
    )));
    await prefs.setString('saved_areas', encoded);
  }

  // Handle map taps to add polygon points
  void _onMapTapped(LatLng position) {
    setState(() {
      _polygonPoints.add(position);
      _markers.add(
        Marker(
          markerId: MarkerId('point_${_polygonPoints.length}'),
          position: position,
          infoWindow: InfoWindow(title: 'Point ${_polygonPoints.length}'),
          draggable: true,
          onDragEnd: (newPosition) => _onMarkerDragEnd(
              MarkerId('point_${_polygonPoints.length}'), newPosition),
        ),
      );
      _updatePolygon();
    });
  }

  // Handle marker drag to update polygon points
  void _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) {
    setState(() {
      final index = int.parse(markerId.value.split('_')[1]) - 1;
      _polygonPoints[index] = newPosition;
      _markers.removeWhere((marker) => marker.markerId == markerId);
      _markers.add(
        Marker(
          markerId: markerId,
          position: newPosition,
          infoWindow: InfoWindow(title: 'Point ${index + 1}'),
          draggable: true,
          onDragEnd: (newPosition) => _onMarkerDragEnd(markerId, newPosition),
        ),
      );
      _updatePolygon();
    });
  }

  // Update polygon based on current points
  void _updatePolygon() {
    _polygons.clear();
    if (_polygonPoints.length >= 3) {
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('freehand_boundary'),
          points: _polygonPoints,
          strokeColor: Colors.green,
          strokeWidth: 2,
          fillColor: Colors.green.withOpacity(0.3),
        ),
      );
    }
  }

  // Clear the drawn boundary
  void _clearBoundary() {
    setState(() {
      _polygonPoints.clear();
      _polygons.clear();
      _markers.clear();
    });
  }

  // Undo the last added point
  void _undoLastPoint() {
    setState(() {
      if (_polygonPoints.isNotEmpty) {
        _polygonPoints.removeLast();
        _markers
            .removeWhere((marker) => marker.markerId.value == 'point_${_markers.length}');
        _updatePolygon();
      }
    });
  }

  // Save the current polygon
  void _saveBoundary() {
    if (_polygonPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No boundary to save')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Save Area'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter area name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _savedAreas[nameController.text] = List.from(_polygonPoints);
                  });
                  await _saveAreas();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Area "${nameController.text}" saved')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Load and edit a saved area
  void _loadArea(String areaName) {
    setState(() {
      _polygonPoints.clear();
      _markers.clear();
      _polygons.clear();
      _polygonPoints.addAll(_savedAreas[areaName]!);
      for (var i = 0; i < _polygonPoints.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('point_${i + 1}'),
            position: _polygonPoints[i],
            infoWindow: InfoWindow(title: 'Point ${i + 1}'),
            draggable: true,
            onDragEnd: (newPosition) =>
                _onMarkerDragEnd(MarkerId('point_${i + 1}'), newPosition),
          ),
        );
      }
      _updatePolygon();
      // Move camera to the first point of the loaded area
      if (_polygonPoints.isNotEmpty) {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_polygonPoints.first),
        );
      }
    });
  }

  // Navigate to Saved Areas screen
  void _showSavedAreas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedAreasScreen(
          savedAreas: _savedAreas,
          onLoadArea: _loadArea,
          onDeleteArea: (areaName) async {
            setState(() {
              _savedAreas.remove(areaName);
            });
            await _saveAreas();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boundary with Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo Last Point',
            onPressed: _undoLastPoint,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Boundary',
            onPressed: _clearBoundary,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Boundary',
            onPressed: _saveBoundary,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Saved Area',
            onPressed: _editSavedArea,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Saved Areas',
            onPressed: _showSavedAreas,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: _onMapCreated,
            polygons: _polygons,
            mapType: MapType.hybrid,
            markers: _markers,
            onTap: _onMapTapped,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _clearBoundary,
              tooltip: 'Clear Boundary',
              child: const Icon(Icons.delete),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _saveBoundary,
              tooltip: 'Save Boundary',
              child: const Icon(Icons.save),
            ),
          ),
        ],
      ),
    );
  }
  void _editSavedArea() {
    if (_savedAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved areas')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Area to Edit'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _savedAreas.keys.map((areaName) {
                return ListTile(
                  title: Text(areaName),
                  onTap: () {
                    setState(() {
                      _polygonPoints.clear();
                      _markers.clear();
                      _polygons.clear();
                      _polygonPoints.addAll(_savedAreas[areaName]!);
                      for (var i = 0; i < _polygonPoints.length; i++) {
                        _markers.add(
                          Marker(
                            markerId: MarkerId('point_${i + 1}'),
                            position: _polygonPoints[i],
                            infoWindow: InfoWindow(title: 'Point ${i + 1}'),
                            draggable: true,
                            onDragEnd: (newPosition) =>
                                _onMarkerDragEnd(MarkerId('point_${i + 1}'), newPosition),
                          ),
                        );
                      }
                      _updatePolygon();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class SavedAreasScreen extends StatelessWidget {
  final Map<String, List<LatLng>> savedAreas;
  final Function(String) onLoadArea;
  final Function(String) onDeleteArea;

  const SavedAreasScreen({
    super.key,
    required this.savedAreas,
    required this.onLoadArea,
    required this.onDeleteArea,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Areas'),
      ),
      body: savedAreas.isEmpty
          ? const Center(child: Text('No saved areas'))
          : ListView.builder(
        itemCount: savedAreas.length,
        itemBuilder: (context, index) {
          final areaName = savedAreas.keys.elementAt(index);
          return ListTile(
            title: Text(areaName),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await onDeleteArea(areaName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Area "$areaName" deleted')),
                );
              },
            ),
            onTap: () {
              onLoadArea(areaName);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}