import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../MapDeviceList.dart';
import 'map_conection_objects.dart';


class MapScreenValve extends StatefulWidget {
  const MapScreenValve({
    Key? key,
    required this.userId,
    required this.customerId,
    required this.controllerId,
    required this.imeiNo,
  }) : super(key: key);

  final int userId, customerId, controllerId;
  final String imeiNo;

  @override
  State<MapScreenValve> createState() => _MapScreenValveState();
}

class _MapScreenValveState extends State<MapScreenValve> {
  late GoogleMapController mapController;
  LatLng center = const LatLng(11.7749, 78.4194);

  Set<Marker> markers = {};
  Map<String, BitmapDescriptor> markerIcons = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadIcons();
    await _fetchData();
  }

  // ---------------- ICON LOAD ----------------
  Future<void> _loadIcons() async {
    Future<BitmapDescriptor> load(String path) {
      return BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        path,
      );
    }

    markerIcons = {
      "gray": await load('assets/png/markergray.png'),
      "green": await load('assets/png/markergreen.png'),
      "red": await load('assets/png/markerred.png'),
      "blue": await load('assets/png/markerblue.png'),
      "pump": await load('assets/png/markerpump.png'),
      "sensor": await load('assets/png/markersensor.png'),
      "fert": await load('assets/png/markerfertilizer.png'),
      "filter": await load('assets/png/markerfilter.png'),
      "injector": await load('assets/png/markerinjector.png'),
    };
  }

  // ---------------- FETCH DATA ----------------
  Future<void> _fetchData() async {
    try {
      final repo = Repository(HttpService());

      final response = await repo.getgeography({
        "userId": widget.customerId,
        "controllerId": widget.controllerId,
      });
       // print('getgeography userId${widget.userId},ctrl id ${widget.controllerId}');
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      // print("_fetchData data:$data");

      final deviceList = data["data"]["deviceList"] ?? [];

      Set<Marker> newMarkers = {};

      for (var device in deviceList) {
         final geo = device["geography"];
        if (geo != null &&
            geo["lat"] != null &&
            geo["long"] != null) {
          newMarkers.add(_createMarker(
            id: "device-${device["deviceId"]}",
            lat: geo["lat"],
            lng: geo["long"],
            title: device["deviceName"],
            type: device["categoryName"],
            status: geo["status"],
            percentage: 0,
          ));
        }

        for (var obj in device["connectedObject"] ?? []) {
          if (obj["lat"] != null && obj["long"] != null) {

            var resultstaus = getStatusPercentage(obj["sNo"],data["data"]["liveMessage"]);

            newMarkers.add(_createMarker(
              id: "obj-${obj["sNo"]}",
              lat: obj["lat"],
              lng: obj["long"],
              title: obj["name"] ?? obj["objectName"],
              type: obj["objectName"],
              status: resultstaus["status"] ?? 0,
              percentage: resultstaus["percentage"] ?? 0,
            ));
          }
        }
      }
      final initialCenter = _getInitialCenter(deviceList);

       setState(() {
        markers = newMarkers;
        if (initialCenter != null) {
          center = initialCenter;
         }
      });

    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Map<String, int> getStatusPercentage(
      double serialNumber, Map<String, dynamic>? liveMessage)
  {
     try {
      // 1. Safe extraction of the nested map and string
      if (liveMessage == null || liveMessage["cM"] == null) {
        return {"status": 0, "percentage": 0};
      }

      // Cast cM safely
      final dynamic cMData = liveMessage["cM"];
      if (cMData is! Map) return {"status": 0, "percentage": 0};

      final String? data = cMData["2402"]?.toString();

      if (data == null || data.isEmpty) {
        print('data is empty or null');
        return {"status": 0, "percentage": 0};
      }

      final List<String> values = data.split(";");

      for (var value in values) {
        final List<String> parts = value.split(",");

        if (parts.length >= 3) {
          // 2. Convert string ID to double to ensure 13.010 == 13.01
          double? partId = double.tryParse(parts[0]);

          if (partId != null && partId == serialNumber) {
             return {
              "status": int.tryParse(parts[1]) ?? 0,
              "percentage": int.tryParse(parts[2]) ?? 0,
            };
          }
        }
      }

      print('No match found for serialNumber');
      return {"status": 0, "percentage": 0};

    } catch (e, stacktrace) {
      print("Error getting valve data: $e");
      print("Stacktrace: $stacktrace");
      return {"status": 0, "percentage": 0};
    }
  }

  LatLng? _getInitialCenter(List deviceList) {
    print("_getInitialCenter");
    // 1️⃣ First Valve Object
    for (var device in deviceList) {
      for (var obj in device["connectedObject"] ?? []) {
        if (obj["objectName"] != null &&
            obj["objectName"].toString().contains("Valve") &&
            obj["lat"] != null &&
            obj["long"] != null) {

          return LatLng(obj["lat"], obj["long"]);
        }
      }
    }

    // 2️⃣ First Available Object
    for (var device in deviceList) {
      for (var obj in device["connectedObject"] ?? []) {
        if (obj["lat"] != null && obj["long"] != null) {

          // print("object:%:${LatLng(obj["lat"], obj["long"])}");
          return LatLng(obj["lat"], obj["long"]);
        }
      }
    }

    // 3️⃣ First Device Geography
    for (var device in deviceList) {
      final geo = device["geography"];
      if (geo != null &&
          geo["lat"] != null &&
          geo["long"] != null) {
        // print("geography:%:${LatLng(geo["lat"], geo["long"])}");

        return LatLng(geo["lat"], geo["long"]);
      }
    }

    return null;
  }

  // ---------------- CREATE MARKER ----------------
  Marker _createMarker({
    required String id,
    required double lat,
    required double lng,
    required String title,
    required String type,
    int? status,
    int? percentage,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      icon: _getIcon(type, status, percentage),
      infoWindow: InfoWindow(
        title: title,
        snippet: "Irrigation: ${percentage ?? 0}%",
      ),
    );
  }



  BitmapDescriptor _getIcon(String type, int? status, int? percentage) {

    int st = status ?? 0;
    int per = percentage ?? 0;

    if (type.contains("Valve")) {
      if (st == 1 && per == 100) {
        return markerIcons["blue"] ?? BitmapDescriptor.defaultMarker;
      }
      else if (st == 0 && per == 0) {
        return markerIcons["gray"] ?? BitmapDescriptor.defaultMarker;
      }
      else if (st == 0 && per > 0) {
        return markerIcons["yellow"] ?? BitmapDescriptor.defaultMarker;
      }
      else if (st == 1 && per <= 100) {
        return markerIcons["green"] ?? BitmapDescriptor.defaultMarker;
      }
      else {
        return markerIcons["gray"] ?? BitmapDescriptor.defaultMarker;
      }
    }

    if (type.contains("Pump")) {
      return markerIcons["pump"] ?? BitmapDescriptor.defaultMarker;
    }

    if (type.contains("Sensor")) {
      return markerIcons["sensor"] ?? BitmapDescriptor.defaultMarker;
    }

    if (type.contains("Filter")) {
      return markerIcons["filter"] ?? BitmapDescriptor.defaultMarker;
    }

    if (type.contains("fertilizer")) {
      return markerIcons["fert"] ?? BitmapDescriptor.defaultMarker;
    }

    if (type.contains("Injector")) {
      return markerIcons["injector"] ?? BitmapDescriptor.defaultMarker;
    }

    return markerIcons["blue"] ?? BitmapDescriptor.defaultMarker;
  }

  // ---------------- MAP CREATED ----------------

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Small delay to make sure map is fully rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: center,
            zoom: 17, // 🔥 your zoom level
          ),
        ),
      );
    });
  }



  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    // print("build center:$center");

    return Scaffold(
      appBar: AppBar(title: const Text("Geography new "),
          actions: [
          IconButton(
          icon: Icon(Icons.map_outlined),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MapConnectionObject(userId: widget.userId, customerId: widget.customerId, controllerId: widget.controllerId, imeiNo: widget.imeiNo,),
        ));
      },
      tooltip: 'Edit',
    ),
    ],
      ),

      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 8,
        ),
        markers: markers,
        onMapCreated: _onMapCreated,
       ),
    );
  }
}
