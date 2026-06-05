import 'dart:async';
import 'package:flutter/material.dart';
 import '../../repository/repository.dart';
import '../../services/http_service.dart';
 import 'package:oro_drip_irrigation/utils/helpers/log_print.dart';

import 'getUserInformationScreen.dart';


class CropListScreen extends StatefulWidget {
  const CropListScreen({
    Key? key,
    required this.userId,
     required this.controllerId,
  }) : super(key: key);

  final int userId,controllerId;

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  bool _isLoading = true;
  List<dynamic> cropList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final repository = Repository(HttpService());

      final response = await repository.getCropList({
        "userId": widget.userId,
        "controllerId": widget.controllerId,
      });

      if (response.statusCode == 200) {
        setState(() {
          // cropList = response.data ?? [];
        });
      }
    } catch (e) {
      AppLog.log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop List'),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cropList.length,
        itemBuilder: (context, index) {
          final crop = cropList[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(crop['cropName'] ?? ''),
              subtitle: Text(crop['cropType'] ?? ''),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Cropinformationscreen(
                // userId: widget.userId,
                // controllerId: widget.controllerId,
              ),
            ),
          );

          fetchData(); // refresh list
        },
        icon: const Icon(Icons.add),
        label: const Text("Create Crop"),
      ),
    );
  }
}