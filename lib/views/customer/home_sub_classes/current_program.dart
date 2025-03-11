
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';

class CurrentProgram extends StatelessWidget {
  const CurrentProgram({super.key, required this.scheduledPrograms});
  final List<ProgramList> scheduledPrograms;

  @override
  Widget build(BuildContext context) {

    var currentSchedule = Provider.of<MqttPayloadProvider>(context).currentSchedule;
    print('currentProgram:$currentSchedule');

    return currentSchedule.isNotEmpty && currentSchedule[0].isNotEmpty?
    Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              height: (currentSchedule.length * 45) + 45,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1100,
                dataRowHeight: 45.0,
                headingRowHeight: 40.0,
                headingRowColor: WidgetStateProperty.all<Color>(Colors.green.shade50),
                columns: const [
                  DataColumn2(
                      label: Text('Name', style: TextStyle(fontSize: 13),),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                    label: Text('Location', style: TextStyle(fontSize: 13)),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                    label: Text('Zone', style: TextStyle(fontSize: 13),),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                      label: Text('Zone Name', style: TextStyle(fontSize: 13)),
                      size: ColumnSize.S
                  ),
                  DataColumn2(
                    label: Center(child: Text('RTC', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Set (Dur/Flw)', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 100,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Avg/Flw Rate', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 100,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Remaining', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Center(child: Text('')),
                    fixedWidth: 90,
                  ),
                ],

                rows: List<DataRow>.generate(currentSchedule.length, (index) {

                  List<String> values = currentSchedule[index].split(",");

                  return DataRow(cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(getProgramNameById(int.parse(values[0]))),
                          //Text(getContentByCode(widget.currentSchedule[index].reasonCode), style: const TextStyle(fontSize: 10, color: Colors.black),),
                        ],
                      ),
                    ),
                    const DataCell(Text('--')),
                    DataCell(Text('${values[10]}/${values[9]}')),
                    DataCell(Text(
                      getProgramNameById(int.parse(values[0])) == 'StandAlone - Manual'
                          ? '--'
                          : getSequenceName(int.parse(values[0]), values[1]) ?? '--',
                    )),
                    DataCell(Center(child: Text(formatRtcValues(values[6], values[5])))),
                    DataCell(Center(child: Text(formatRtcValues(values[8],values[7])))),
                    DataCell(Center(child: Text(convert24HourTo12Hour(values[11])))),
                    DataCell(Center(child: Text(getProgramNameById(int.parse(values[0]))=='StandAlone - Manual' &&
                        (values[3]=='00:00:00'||values[3]=='0')?
                    'Timeless': values[3]))),
                    const DataCell(Center(child: Text('${'0'}/hr'))),
                    DataCell(Center(child: Text(getProgramNameById(int.parse(values[0]))=='StandAlone - Manual' &&
                        (values[3]=='00:00:00'||values[3]=='0')? '----': values[4],
                        style:  const TextStyle(fontSize: 20)))),
                    const DataCell(Center(child: Text('${'0'}/hr'))),

                  ]);
                }),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 0,
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(width: 0.5, color: Colors.grey)
              ),
              child: const Text('CURRENT SCHEDULE',  style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    ):
    const SizedBox();
  }

  String getProgramNameById(int id) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id).programName;
    } catch (e) {
      return "Stand Alone";
    }
  }

  ProgramList? getProgramById(int id) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id);
    } catch (e) {
      return null;
    }
  }

  String? getSequenceName(int programId, String sequenceId) {
    ProgramList? program = getProgramById(programId);
    if (program != null) {
      return getSequenceNameById(program, sequenceId);
    }
    return null;
  }

  String? getSequenceNameById(ProgramList program, String sequenceId) {
    try {
      return program.sequence.firstWhere((seq) => seq.sNo == sequenceId).name;
    } catch (e) {
      return null;
    }
  }

  String formatRtcValues(dynamic value1, dynamic value2) {
    if (value1 == 0 && value2 == 0) {
      return '--';
    } else {
      return '${value1.toString()}/${value2.toString()}';
    }
  }

  String convert24HourTo12Hour(String timeString) {
    if(timeString=='-'){
      return '-';
    }
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
  }

}
