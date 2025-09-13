import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:oro_drip_irrigation/Constants/data_convertion.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import '../../../Widgets/custom_buttons.dart';
import '../repository/irrigation_repository.dart';
import 'log_home.dart';


class Ec25Log extends StatefulWidget {
  final Map<String, dynamic> userData;
  const Ec25Log({super.key, required this.userData});

  @override
  State<Ec25Log> createState() => _Ec25LogState();
}

class _Ec25LogState extends State<Ec25Log> {
  DateTime? selectedDate;
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  DateRange? selectedDateRange;

  Map<String, dynamic> data = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        getData();
      }
    });
  }

  String _formatNumber(int number) {
    // Add leading zero if the number is less than 10
    return number.toString().padLeft(2, '0');
  }

  void getData()async{
    print('data request to the server.............');
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    print('_selectedDate : $_selectedDate');
    _selectedDate = _selectedDate == '' ? '$formattedDate - $formattedDate' : _selectedDate;
    print('_selectedDate : $_selectedDate');
    String dateString1 = _selectedDate.split(' - ')[0];
    String dateString2 = _selectedDate.split(' - ')[1];
    print("dateString2 ==> $dateString2");

    List<String> parts1 = dateString1.split('/');
    List<String> parts2 = dateString2.split('/');

    // Create DateTime objects
    DateTime date1 = DateTime(int.parse(parts1[2]), int.parse(parts1[1]), int.parse(parts1[0]));
    DateTime date2 = DateTime(int.parse(parts2[2]), int.parse(parts2[1]), int.parse(parts2[0]));

    // Format DateTime objects into desired format
    String formattedDate1 = "${date1.year}-${_formatNumber(date1.month)}-${_formatNumber(date1.day)}";
    String formattedDate2 = "${date2.year}-${_formatNumber(date2.month)}-${_formatNumber(date2.day)}";

    try{
      String? startMonth = selectedDateRange?.start.month.toString();
      print('startMonth : $startMonth');

      String? startday = selectedDateRange?.start.day.toString();
      String? endMonth = selectedDateRange?.end.month.toString();
      String? endday = selectedDateRange?.end.day.toString();
      var body = {
        "userId": widget.userData['customerId'],
        "controllerId": widget.userData['controllerId'],
        "logType" : "IrrigationMotorCyclic",
        "fromDate" : formattedDate1,
        "toDate" : formattedDate2,
      };
      var response = await IrrigationRepository().getNovaLogDateWise(body);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      print('jsonData $jsonData');
      if(jsonData['code'] == 200){
        setState(() {
          data = jsonData;
        });
      }

    }catch(e,stackTrace){
      print('error in log = > ${e.toString()}');
      print('error in log stackTrace= > $stackTrace');
    }
  }



  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    print('args : ${args}');
    setState(() {
      if (args.value is PickerDateRange) {
        _selectedDate  = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';

        print('_selectedDate : $_selectedDate');
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
      print("range: ${_range},rangecount:${_rangeCount},Select date:${_selectedDate}");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: const Text('Date Picker'),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter stateSetter) {
                  return SizedBox(
                    width: 200,
                    height: 250,
                    child:SfDateRangePicker(
                      onSelectionChanged:  _onSelectionChanged,
                      selectionMode: DateRangePickerSelectionMode.range,
                      initialSelectedRange: PickerDateRange(
                        // DateTime.now().subtract(const Duration(days: 4)),
                        // DateTime.now().add(const Duration(days: 3))
                          DateTime.now(),
                          DateTime.now()
                      ),
                    ),
                  );
                },
              ),
              actions: [
                CustomMaterialButton(
                  title: 'Cancel',
                  outlined: true,
                ),
                CustomMaterialButton(
                  onPressed: ()async{
                    Navigator.pop(context);
                    getDialog(context);
                    getData();
                    if(mounted){
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );

          });
        },
        child: Icon(Icons.date_range),
      ),
      body: data.isNotEmpty ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: [
                const SizedBox(height: 1,),
                for(var programData in data["data"]["motorCyclic"])
                  programBox(programData: programData)
              ],
            ),
          ),
        ),
      ) : Center(
        child: Text('There is no data in $_selectedDate'),
      ),
    );
  }
  Widget getTitleValue({required String title, required String value, Color? titleColor, Color? valueColor, double? fontSize}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize ?? 13, color: titleColor ?? Colors.black),),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize ?? 13, color: valueColor ?? Colors.black),),
      ],
    );
  }

  Widget programBox({
    required Map<String, dynamic> programData,
  }){
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        spacing: 8,
        children: [
          getTitleValue(title: 'Program', value: programData["program"], titleColor: Colors.white, valueColor: Colors.white),
          getTitleValue(title: 'Cyclic duration', value: getCyclicDuration(programData: programData), titleColor: Colors.white, valueColor: Colors.white),
          getTitleValue(title: 'Cyclic flow', value: getCyclicFlow(programData: programData), titleColor: Colors.white, valueColor: Colors.white),
          Column(
            spacing: 10,
            children: [
              for(var zoneData in programData["zoneList"])
                zoneBox(zoneData: zoneData)
            ],
          ),
        ],
      ),
    );
  }

  String getCyclicDuration({required Map<String, dynamic> programData,}){
    DataConvert dataConvert = DataConvert();
    int totalSeconds = 0;
    for(var zoneData in programData['zoneList']){
      totalSeconds += dataConvert.parseTimeString(zoneData["duration"]);
    }
    return dataConvert.formatTime(totalSeconds);
  }

  String getCyclicFlow({required Map<String, dynamic> programData,}){
    double totalFlow = 0;
    for(var zoneData in programData['zoneList']){
      totalFlow += double.parse(zoneData["flow"]);
    }
    return totalFlow.toString();
  }

  Widget zoneBox({
  required Map<String, dynamic> zoneData,
  }){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          height: 30,
          color: Theme.of(context).primaryColorDark,
          child: Row(
            children: [
              Expanded(child: getTitleValue(title: 'Zone', value: zoneData["zone"], titleColor: Colors.white, valueColor: Colors.white)),
              Expanded(child: Container())
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
          ),
          child: Column(
            spacing: 10,
            children: [
              Row(
                children: [
                  Expanded(child: getTitleValue(title: 'On Time', value: zoneData["OnTime"], fontSize : 12, titleColor: Colors.black54)),
                  getDivider(),
                  Expanded(child: getTitleValue(title: 'Off Time', value: zoneData["OffTime"], fontSize : 12, titleColor: Colors.black54))
                ],
              ),
              Row(
                children: [
                  Expanded(child: getTitleValue(title: 'Duration', value: zoneData["duration"], fontSize : 12, titleColor: Colors.black54)),
                  getDivider(),
                  Expanded(child: getTitleValue(title: 'Flow', value: zoneData["flow"], fontSize : 12, titleColor: Colors.black54))
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget getDivider({Color? color}){
    return SizedBox(
      height: 30,
      child: VerticalDivider(
        thickness: 1,
        color: color ?? Colors.black,
      ),
    );
  }

}
