import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/communication_codes.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/Models/Configuration/device_model.dart';
import 'package:oro_drip_irrigation/Widgets/connection_grid_list_tile.dart';
import 'package:oro_drip_irrigation/Widgets/connector_widget.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../StateManagement/config_maker_provider.dart';

class Connection extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const Connection({
    super.key,
    required this.configPvd
  });

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    DeviceModel selectedDevice = widget.configPvd.listOfDeviceModel.firstWhere((device) => device.controllerId == widget.configPvd.selectedModelControllerId);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (context, constraint){
        return SizedBox(
          width: constraint.maxWidth,
          height: constraint.maxHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getAvailableDeviceCategory(),
                const SizedBox(height: 8,),
                getModelBySelectedCategory(),
                const SizedBox(height: 10,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if((selectedDevice.noOfRelay == 0 ? selectedDevice.noOfLatch : selectedDevice.noOfRelay) != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: const Color(0xffD2EAFF),
                            from: 0,
                            to: selectedDevice.noOfRelay == 0 ? selectedDevice.noOfLatch : selectedDevice.noOfRelay,
                            type: '1,2',
                            typeName: 'Relay',
                          keyWord: 'R'
                        ),
                      if(selectedDevice.noOfAnalogInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(3),
                            from: 0,
                            to: selectedDevice.noOfAnalogInput,
                            type: '3',
                            typeName: 'Analog',
                            keyWord: 'A'
                        ),
                      if(selectedDevice.noOfDigitalInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(4),
                            from: 0,
                            to: selectedDevice.noOfDigitalInput,
                            type: '4',
                            typeName: 'Digital',
                            keyWord: 'D'
                        ),
                      if(selectedDevice.noOfPulseInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(6),
                            from: 0,
                            to: selectedDevice.noOfPulseInput,
                            type: '6',
                            typeName: 'Pulse',
                            keyWord: 'P'
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                outputObject(selectedDevice),
                const SizedBox(height: 10,),
                analogObject(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget getConnectionBox(
  {
    required DeviceModel selectedDevice,
    required Color color,
    required int from,
    required int to,
    required String type,
    required String typeName,
    required String keyWord,
  }
      ){
    int firstEight = 8;
    if(to < 8){
      firstEight = firstEight - (8 - to);
    }
    return Container(
      width: to > 8 ? 500 : 250,
      height: 250,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
          // boxShadow: AppProperties.customBoxShadow
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    for(var count = from;count < firstEight;count++)
                      ...[
                        ConnectorWidget(
                          connectionNo: count + 1,
                          selectedDevice: selectedDevice,
                          configPvd: widget.configPvd,
                          type: type,
                          keyWord: keyWord,
                        ),
                        const SizedBox(height: 5,)
                      ],
                  ],
                ),
              ),
              if(to > 8)
                const SizedBox(width: 10,),
              if(to > 8)
                Expanded(
                child: Column(
                  children: [
                    for(var count = firstEight;count < to;count++)
                      ...[
                        ConnectorWidget(
                          connectionNo: count + 1,
                          selectedDevice: selectedDevice,
                          configPvd: widget.configPvd,
                          type: type,
                          keyWord: keyWord,
                        ),
                        const SizedBox(height: 5,)
                      ],
                  ],
                ),
              ),
            ],
          ),
          Text('$typeName ${from+1} to $typeName $to', style: AppProperties.tableHeaderStyle,)
        ],
      ),
    );
  }

  Widget outputObject(DeviceModel selectedDevice){
    DeviceModel selectedDevice = widget.configPvd.listOfDeviceModel.firstWhere((device) => device.controllerId == widget.configPvd.selectedModelControllerId);
    List<int> filteredObjectList = widget.configPvd.listOfSampleObjectModel
        .where((object) => (object.type == '1,2' && !['', '0', null].contains(object.count)))
        .toList().where((object) => selectedDevice.connectingObjectId.contains(object.objectId)).toList().map((object) => object.objectId)
        .toList();
    List<DeviceObjectModel> filteredList = widget.configPvd.listOfObjectModelConnection.where((object)=> filteredObjectList.contains(object.objectId)).toList();

    return ConnectionGridListTile(
      listOfObjectModel: filteredList,
      title: 'Output Object',
      leadingColor: const Color(0xffD2EAFF),
      configPvd: widget.configPvd,
      selectedDevice: selectedDevice,
    );
  }
  Widget analogObject(){
    DeviceModel selectedDevice = widget.configPvd.listOfDeviceModel.firstWhere((device) => device.controllerId == widget.configPvd.selectedModelControllerId);
    List<int> filteredObjectList = widget.configPvd.listOfSampleObjectModel
        .where((object) => (!['-', '1,2'].contains(object.type) && !['', '0', null].contains(object.count)))
        .toList().where((object) => selectedDevice.connectingObjectId.contains(object.objectId)).toList().map((object) => object.objectId)
        .toList();
    List<DeviceObjectModel> filteredList = widget.configPvd.listOfObjectModelConnection.where((object)=> filteredObjectList.contains(object.objectId)).toList();    filteredList.sort((a, b) => a.type.compareTo(b.type));
    return ConnectionGridListTile(
      listOfObjectModel: filteredList,
      title: 'Input Object',
      configPvd: widget.configPvd,
      selectedDevice: selectedDevice,
    );
  }
  Widget getAvailableDeviceCategory(){
    List<int> listOfCategory = [];
    for(var device in widget.configPvd.listOfDeviceModel){
      if(device.categoryId != 1 && device.isUsedInConfig == 1 && !listOfCategory.contains(device.categoryId)){
        listOfCategory.add(device.categoryId);
      }
    }
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            for(var categoryId in listOfCategory)
              InkWell(
                onTap: (){
                  setState(() {
                    widget.configPvd.selectedCategory = categoryId;
                    for(var device in widget.configPvd.listOfDeviceModel){
                      if(device.categoryId == categoryId){
                        widget.configPvd.selectedModelControllerId = device.controllerId;
                        break;
                      }
                    }
                  });
                  widget.configPvd.updateConnectionListTile();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.configPvd.selectedCategory == categoryId ? Theme.of(context).primaryColorLight : Colors.grey.shade300
                  ),
                  child: Text(getDeviceCodeToString(categoryId), style: TextStyle(color: widget.configPvd.selectedCategory == categoryId ? Colors.white : Colors.black, fontSize: 13),),
                ),
              )
          ],
        ),
        Container(
          width: double.infinity,
          height: 3,
          color: Theme.of(context).primaryColorLight,
        )
      ],
    );
    return child;
  }
  Widget getModelBySelectedCategory(){
    List<DeviceModel> filteredDeviceModel = widget.configPvd.listOfDeviceModel.where((device) => device.categoryId == widget.configPvd.selectedCategory).toList();
    Widget child = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for(var model in filteredDeviceModel)
            ...[
              InkWell(
                onTap: (){
                  setState(() {
                    widget.configPvd.selectedModelControllerId = model.controllerId;
                  });
                  widget.configPvd.updateConnectionListTile();
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: widget.configPvd.selectedModelControllerId == model.controllerId ? Color(0xff1C863F) :Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(model.deviceName,style: TextStyle(color: widget.configPvd.selectedModelControllerId == model.controllerId ? Colors.white : Colors.black, fontSize: 13),)
                ),
              ),
              const SizedBox(width: 10,)
            ]

        ],
      ),
    );
    return child;
  }
}
