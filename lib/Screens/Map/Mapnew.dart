import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';

class GoogleEarthEditorScreen extends StatefulWidget {
  @override
  State<GoogleEarthEditorScreen> createState() => _GoogleEarthEditorScreenState();
}

class _GoogleEarthEditorScreenState extends State<GoogleEarthEditorScreen> {
  GoogleMapController? _mapController;

  List<LatLng> _points = [];
  bool _isClosed = false;
  Set<Marker> _vertices = {};
  Set<Polyline> _lines = {};
  Set<Polygon> _fill = {};
  BitmapDescriptor? _dotIcon;

  @override
  void initState() {
    super.initState();
    _createMarkerImage();
  }


     Future<void> _createMarkerImage() async {
      const double size = 10;

      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.circle.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: Icons.circle.fontFamily,
          color: Colors.white, // dot color
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, const Offset(0, 0));

      final image = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );

      final byteData = await image.toByteData(format: ImageByteFormat.png);

      _dotIcon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    }


  void _refreshLayers() {
    setState(() {
      _vertices.clear();
      _lines.clear();
      _fill.clear();

      // Step A: Create interactive, DRAGGABLE dots (Vertices)
      for (int i = 0; i < _points.length; i++) {
        bool isStartPoint = (i == 0);

        _vertices.add(
          Marker(
            markerId: MarkerId("vertex_$i"),
            position: _points[i],
            draggable: true, // 🚀 THE KEY OPTION
            anchor: const Offset(0.5, 0.5), // Center the dot on the point
            // Visual style: Start point is Yellow (if open), others are Azure/Asset
            icon: (isStartPoint && !_isClosed)
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow)
                : (_dotIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),

            // Interaction: Closing the Loop
            onTap: () {
              // If tapping the start point, have 3+ points, and it's not closed, fill it!
              if (isStartPoint && _points.length >= 3 && !_isClosed) {
                setState(() => _isClosed = true);
                _refreshLayers();
              }
            },

            // Interaction: DRAGGING
            onDragEnd: (newPos) {
              // 🚀 Update the master point list with the new position
              setState(() {
                _points[i] = newPos;
                _refreshLayers(); // Rebuild lines/polygon instantly
              });
            },
          ),
        );
      }

      // Step B: Create the Lines (The Path)
      List<LatLng> linePath = List.from(_points);
      // Visually close the loop if the state is closed
      if (_isClosed && _points.isNotEmpty) {
        linePath.add(_points.first); // Join last point back to first
      }

      _lines.add(Polyline(
        polylineId: const PolylineId("path"),
        points: linePath,
        color: Colors.yellow,
        width: 3,
        jointType: JointType.round,
      ));

      // Step C: Create the Fill (Only when closed)
      if (_isClosed && _points.length >= 3) {
        _fill.add(Polygon(
          polygonId: const PolygonId("area_fill"),
          points: _points,
          strokeWidth: 0, // Border is handled by Polyline
          fillColor: Colors.blue.withOpacity(0.3),
        ));
      }
    });
  }
  void _handleMapTap(LatLng pos) {
    if (_isClosed) return; // Don't allow adding points if the area is closed

    setState(() {
      _points.add(pos);
      _refreshLayers();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earth Style Editor"),
        actions: [
          // Toggle to unlock/open the polygon for editing
          if (_isClosed)
            IconButton(
              icon: const Icon(Icons.lock_open),
              onPressed: () => setState(() { _isClosed = false; _refreshLayers(); }),
              tooltip: "Edit Boundary",
            ),
          // Clear everything
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() {
              _points.clear();
              _isClosed = false;
              _refreshLayers();
            }),
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: const CameraPosition(target: LatLng(11.12, 78.65), zoom: 16),
            onMapCreated: (c) => _mapController = c,
            onTap: _handleMapTap,
            markers: _vertices,
            polylines: _lines,
            polygons: _fill,
          ),

          // Instruction Overlay
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Card(
              color: Colors.black54,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _isClosed
                      ? "Area closed. Drag the dots to adjust the shape."
                      : "Tap map to add points. Tap the YELLOW dot to close the area.",
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ValveResponseModel valveResponseModelFromJson(String str) => ValveResponseModel.fromJson(json.decode(str));

class ValveResponseModel {
  int? code;
  String? message;
  ValveData? data;

  ValveResponseModel({this.code, this.message, this.data});

  factory ValveResponseModel.fromJson(Map<String, dynamic> json) => ValveResponseModel(
    code: json["code"],
    message: json["message"],
    data: json["data"] != null ? ValveData.fromJson(json["data"]) : null,
  );
}

class ValveData {
  List<Mapobject>? valveGeographyArea;
  Map<String, dynamic>? liveMessage;

  ValveData({this.valveGeographyArea, this.liveMessage});

  factory ValveData.fromJson(Map<String, dynamic> json) => ValveData(
    valveGeographyArea: json["valveGeographyArea"] == null
        ? []
        : List<Mapobject>.from(json["valveGeographyArea"].map((x) => Mapobject.fromJson(x))),
    liveMessage: json["liveMessage"],
  );
}

class Mapobject {
  int? objectId;
  double? sNo;
  String? name;
  String? objectName;
  double? lat;
  double? long;
  List<AreaPoint>? area;

  Mapobject({this.objectId, this.sNo, this.name, this.objectName, this.lat, this.long, this.area});

  factory Mapobject.fromJson(Map<String, dynamic> json) => Mapobject(
    objectId: json["objectId"],
    sNo: json["sNo"]?.toDouble(),
    name: json["name"],
    objectName: json["objectName"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
    area: json["area"] == null ? [] : List<AreaPoint>.from(json["area"].map((x) => AreaPoint.fromJson(x))),
  );
}

class AreaPoint {
  double? latitude;
  double? longitude;
  AreaPoint({this.latitude, this.longitude});

  factory AreaPoint.fromJson(Map<String, dynamic> json) => AreaPoint(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );
}

// --- App Functional Model ---
class Valve {
  final String name;
  final int objectId;
  final double sNo;
  double? lat;
  double? long;
  List<LatLng> area;
  int status;
  int percentage;

  Valve({
    required this.name,
    required this.objectId,
    required this.sNo,
    this.lat,
    this.long,
    required this.area,
    required this.status,
    required this.percentage,
  });

  factory Valve.fromMapobject(Mapobject obj, Map<String, dynamic>? liveMessage) {
    String snStr = obj.sNo?.toString() ?? "";
    return Valve(
      name: obj.name ?? '',
      objectId: obj.objectId ?? 0,
      sNo: obj.sNo ?? 0.0,
      lat: obj.lat,
      long: obj.long,
      area: obj.area?.map((a) => LatLng(a.latitude ?? 0.0, a.longitude ?? 0.0)).toList() ?? [],
      status: _parseLiveValue(snStr, liveMessage, 1),
      percentage: _parseLiveValue(snStr, liveMessage, 2),
    );
  }

  static int _parseLiveValue(String sn, Map<String, dynamic>? liveMsg, int index) {
    try {
      final data = liveMsg?['cM']?['2402']?.toString();
      if (data == null || data.isEmpty) return 0;
      for (var item in data.split(';')) {
        if (item.startsWith(sn)) {
          var parts = item.split(',');
          return parts.length > index ? int.parse(parts[index]) : 0;
        }
      }
    } catch (e) { return 0; }
    return 0;
  }
}