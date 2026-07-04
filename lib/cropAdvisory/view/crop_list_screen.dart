import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/cropAdvisory/view/crop_advisory_main_screen.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import 'package:oro_drip_irrigation/utils/helpers/log_print.dart';
import '../../utils/snack_bar.dart';
import '../model/cropadvisory_model.dart';
import 'getUserInformationScreen.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({
    Key? key,
    required this.userId,
    required this.controllerId,
  }) : super(key: key);

  final int userId, controllerId;

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  bool _isLoading = true;
  List<CropAdvisoryModel> cropList = [];
  int cropId = 1;

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
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> cropData = body['data'];

        setState(() {
          cropList =
              cropData.map((e) => CropAdvisoryModel.fromJson(e)).toList();
          cropId = cropData.length + 1;
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

  Future<void> deleteCropList(int cropId) async {
    try {
      final repository = Repository(HttpService());

      final response = await repository.deleteCropList({
        "userId": widget.userId,
        "controllerId": widget.controllerId,
        "cropId": cropId
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (mounted) {
          GlobalSnackBar.show(context, body['message'], response.statusCode);
        }
        setState(() {
          fetchData();
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
    Widget content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: kIsWeb ? 800 : double.infinity),
        child: ListView.builder(
          itemCount: cropList.length,
          itemBuilder: (context, index) {
            final crop = cropList[index];

            return Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  // Populate singleton and navigate to Main Screen (Dashboard)
                  CropAdvisoryModel.instance.fromJson(crop.toJson());
                  CropAdvisoryModel.instance.cropId = crop.cropId;
                  CropAdvisoryModel.instance.userId = widget.userId;
                  CropAdvisoryModel.instance.controllerId =
                      widget.controllerId;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CropAdvisoryMainScreen(
                          userId: widget.userId,
                          controllerId: widget.controllerId,
                        )),
                  );
                },
                title: Text(
                  crop.cropName ?? 'Unnamed Crop',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "${crop.cropType ?? 'N/A'} • ${crop.areaName ?? 'No area'}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Color(0xff0E8797)),
                      onPressed: () async {
                        // Populate singleton for editing flow
                        CropAdvisoryModel.instance.fromJson(crop.toJson());
                        CropAdvisoryModel.instance.cropId = crop.cropId;
                        CropAdvisoryModel.instance.userId = widget.userId;
                        CropAdvisoryModel.instance.controllerId =
                            widget.controllerId;

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Cropinformationscreen(
                              userId: widget.userId,
                              controllerId: widget.controllerId,
                              cropId: crop.cropId!,
                              edit: true,
                            ),
                          ),
                        );
                        fetchData();
                      },
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        setState(() {
                          deleteCropList(crop.cropId!);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop List'),
      ),
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          CropAdvisoryModel.instance.reset();
          CropAdvisoryModel.instance.userId = widget.userId;
          CropAdvisoryModel.instance.controllerId = widget.controllerId;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Cropinformationscreen(
                userId: widget.userId,
                controllerId: widget.controllerId,
                cropId: cropId,
                edit: false,
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