import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/condition_library_view_model.dart';

class ConditionLibrary extends StatelessWidget {
  const ConditionLibrary(this.customerId, this.controllerId, {super.key});
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConditionLibraryViewModel(Repository(HttpService()))
        ..getConditionLibraryData(customerId, controllerId),
      child: Consumer<ConditionLibraryViewModel>(
        builder: (context, viewModel, _) {
          return viewModel.isLoading?
          buildLoadingIndicator(true, MediaQuery.sizeOf(context).width)
              : Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: GridView.builder(
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  childAspectRatio: 1.21,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Condition ${index + 1}'),
                              const Spacer(),
                              MaterialButton(
                                height: 30,
                                minWidth: 60,
                                color: Colors.redAccent,
                                textColor: Colors.white,
                                onPressed: (){
                                  viewModel.clearCondition(index);
                                },
                                child: const Text('Clear', style: TextStyle(fontSize: 12),),
                              ),
                              const SizedBox(width: 5),
                              Transform.scale(
                                scale: 0.7,
                                child: Tooltip(
                                  message: viewModel.selectedSwitchState[index]? 'Condition disable' : 'Condition enable',
                                  child: Switch(
                                    hoverColor: Theme.of(context).primaryColor,
                                    activeColor: Theme.of(context).primaryColorLight,
                                    value: viewModel.selectedSwitchState[index],
                                    onChanged: (bool value) {
                                      viewModel.switchStateOnChange(value, index);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: RadioListTile<String>(
                                  title: const Text("Sensor"),
                                  value: 'Sensor',
                                  groupValue: viewModel.selectedCnType[index],
                                  onChanged: (value) => viewModel.conTypeOnChange(value!, index),
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                  activeColor: Theme.of(context).primaryColorLight,
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                child: RadioListTile<String>(
                                  title: const Text("program"),
                                  value: 'program',
                                  groupValue: viewModel.selectedCnType[index],
                                  onChanged: (value) => viewModel.conTypeOnChange(value!, index),
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                  activeColor: Theme.of(context).primaryColorLight,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: RadioListTile<String>(
                                  title: const Text("Combined"),
                                  value: 'Combined',
                                  groupValue: viewModel.selectedCnType[index],
                                  onChanged: (value) => viewModel.conTypeOnChange(value!, index),
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                  activeColor: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(
                                width: 125,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Component', style: TextStyle(color: Colors.black54)),
                                    SizedBox(height: 10),
                                    Text('Parameter', style: TextStyle(color: Colors.black54)),
                                    SizedBox(height: 10),
                                    Text('Value/Threshold', style: TextStyle(color: Colors.black54)),
                                    SizedBox(height: 10),
                                    Text('Reason', style: TextStyle(color: Colors.black54)),
                                    SizedBox(height: 10),
                                    Text('Delay Time',style: TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(':'),
                                    SizedBox(height: 10),
                                    Text(':'),
                                    SizedBox(height: 10),
                                    Text(':'),
                                    SizedBox(height: 10),
                                    Text(':'),
                                    SizedBox(height: 10),
                                    Text(':'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.componentOnChange(selectedValue, index);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--',  'flow meter 1', 'Pressure Sensor 1', 'Pressure Sensor 2', 'flow meter 2', 'pressure switch', 'moisture sensor 1', 'level sensor 1',
                                          'well pump', 'program 1', 'filter 1']
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedComponent[index],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.lvlSensorCountOnChange(selectedValue, index);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--', 'Flow rate', 'Pressure', 'Temperature', 'Level', 'Power', 'Combined']
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedParameter[index],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Select values and Operator'),
                                              content: SizedBox(
                                                width: 250,
                                                height: 370,
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                        width: 250,
                                                        height: 50,
                                                        child: TextFormField(
                                                          controller: viewModel.controllerVT,
                                                          maxLength: 100,
                                                          readOnly: true,
                                                          decoration: const InputDecoration(
                                                            counterText: '',
                                                            labelText: 'Value/Threshold',
                                                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                            enabledBorder: UnderlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.black12),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null || value.isEmpty) {
                                                              return 'Please fill out this field';
                                                            }
                                                            return null;
                                                          },
                                                        )
                                                    ),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                        width: 250,
                                                        height: 40,
                                                        child: Row(
                                                          children: [
                                                            MaterialButton(
                                                              color: Theme.of(context).primaryColor,
                                                              textColor: Colors.white,
                                                              height: 40,
                                                              minWidth: 94,
                                                              onPressed: (){
                                                                viewModel.controllerVT.text += 'Higher than ';
                                                              },
                                                              child: const Text('Higher than', style: TextStyle(fontSize: 13),),
                                                            ),
                                                            const SizedBox(width: 5),
                                                            MaterialButton(
                                                              color: Theme.of(context).primaryColor,
                                                              textColor: Colors.white,
                                                              height: 40,
                                                              minWidth: 94,
                                                              onPressed: (){
                                                                viewModel.controllerVT.text += 'Lower than ';
                                                              },
                                                              child: const Text('Lower than', style: TextStyle(fontSize: 13),),
                                                            ),
                                                            const SizedBox(width: 5),
                                                            MaterialButton(
                                                              color: Theme.of(context).primaryColor,
                                                              textColor: Colors.white,
                                                              height: 40,
                                                              minWidth: 75,
                                                              onPressed: (){
                                                                viewModel.controllerVT.text += 'Equal to ';
                                                              },
                                                              child: const Text('Equal to', style: TextStyle(fontSize: 13),),
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                    SizedBox(
                                                      width: 250,
                                                      height: 200,
                                                      child: GridView.count(
                                                        crossAxisCount: 5,
                                                        crossAxisSpacing: 5,
                                                        mainAxisSpacing: 5,
                                                        children: [
                                                          '%','°C','.','cl','C','hour','min','sec','and',
                                                          'or','9','8','7','6','5','4',
                                                          '3','2','1','0'
                                                        ].map((operator) => ElevatedButton(
                                                            onPressed: () {
                                                              if(operator=='C'){
                                                                viewModel.controllerVT.text='';
                                                              }else if(operator=='cl'){
                                                                viewModel.controllerVT.text = viewModel.controllerVT.text.substring(0, viewModel.controllerVT.text.length - 1);
                                                              }
                                                              else if(operator=='Ok'){
                                                                Navigator.pop(context);
                                                              }else{
                                                                viewModel.controllerVT.text += operator;
                                                              }
                                                              ChangeNotifier();
                                                              //result = operator;
                                                              //Navigator.pop(context);
                                                            },
                                                          style: ButtonStyle(
                                                            backgroundColor: operator=='C'?WidgetStateProperty.all<Color>(Colors.redAccent):
                                                            WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                                                          ),
                                                            child: operator=='cl'? const Icon(Icons.backspace_outlined, color: Colors.white):
                                                            Text(operator, style: const TextStyle(fontSize: 15, color: Colors.white)),
                                                          ),
                                                        ).toList(),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: 250,
                                                        height: 50,
                                                        child: Row(
                                                          children: [
                                                            MaterialButton(
                                                              color: Theme.of(context).primaryColor,
                                                              textColor: Colors.white,
                                                              height: 40,
                                                              minWidth: 170,
                                                              onPressed: (){
                                                                viewModel.controllerVT.text += ' ';
                                                              },
                                                              child: const Text('Space'),
                                                            ),
                                                            const SizedBox(width: 5),
                                                            MaterialButton(
                                                              height: 40,
                                                              color: Theme.of(context).primaryColorLight,
                                                              textColor: Colors.white,
                                                              onPressed: (){
                                                                viewModel.valueOnChange(viewModel.controllerVT.text, index);
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Text('Enter'),
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      style: ButtonStyle(
                                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                                        minimumSize: WidgetStateProperty.all(Size.zero),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                      ),
                                      child: Text(viewModel.selectedValue[index], style: const TextStyle(color: Colors.black)),
                                    ),
                                    /*PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.valueOnChange(selectedValue, index);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--', '< 10 L/min', '> 150 L/min', '> 120 psi', '> 80°C', '> 90%', '< 10%', '0 L/min']
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedValue[index],
                                      ),
                                    ),*/
                                    const SizedBox(height: 10),
                                    PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.reasonOnChange(selectedValue, index);
                                        viewModel.controllerAM.text = '${viewModel.selectedReason[index]} detected in '
                                            '${viewModel.selectedComponent[index]}';
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--', 'Low flow', 'High flow', 'No flow',
                                          'High pressure', 'Low pressure', 'Over heating',
                                          'Low level', 'High level', 'Time limit', 'Dry run']
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedReason[index],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.delayTimeOnChange(selectedValue, index);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--', '3 Sec', '5 Sec', '10 Sec']
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedDelayTime[index],
                                      ),
                                    ),
                                    /*Row(
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                const Text('Start at ', style: TextStyle(color: Colors.black54)),
                                                GestureDetector(
                                                  onTap: () => viewModel.selectStartTime(context), // Open Time Picker on tap
                                                  child: Text(
                                                    viewModel.selectedStartTime.format(context),
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        Flexible(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                const Text('End at ', style: TextStyle(color: Colors.black54)),
                                                GestureDetector(
                                                  onTap: () => viewModel.selectEndTime(context), // Open Time Picker on tap
                                                  child: Text(
                                                    viewModel.selectedEndTime.format(context),
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      ],
                                    ),*/
                                    /*PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.controllerAM.text = '${viewModel.selectedReason[index]} detected in '
                                            '${viewModel.selectedComponent[index]}';
                                        viewModel.actionOnChange(selectedValue, index);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--', 'turn_off', 'turn_on', 'turn_off & Notify', 'turn_on & Notify',]
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedAction[index],
                                      ),
                                    ),*/
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextFormField(
                              maxLength: 100,
                              controller: viewModel.controllerAM,
                              decoration: const InputDecoration(
                                counterText: '',
                                labelText: 'Alert message',
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill out this field';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: MaterialButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: (){},
              child: Text('Save'),
            ),
          );
        },
      ),
    );
  }


  Widget buildLoadingIndicator(bool isVisible, double width) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }
}
