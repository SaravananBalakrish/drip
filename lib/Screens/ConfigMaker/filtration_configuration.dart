import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../Constants/dialog_boxes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Models/Configuration/filtration_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/sized_image.dart';
import 'config_web_view.dart';

class FiltrationConfiguration extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const FiltrationConfiguration({super.key, required this.configPvd});

  @override
  State<FiltrationConfiguration> createState() => _FiltrationConfigurationState();
}

class _FiltrationConfigurationState extends State<FiltrationConfiguration> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(builder: (context, constraint){
        double ratio = constraint.maxWidth < 500 ? 0.6 : 1.0;
        return SizedBox(
          width: constraint.maxWidth,
          height: constraint.maxHeight,
          child:  SingleChildScrollView(
            child: ResponsiveGridList(
              horizontalGridMargin: 0,
              verticalGridMargin: 10,
              minItemWidth: 500,
              shrinkWrap: true,
              listViewBuilderOptions: ListViewBuilderOptions(
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: [
                for(var filtrationSite in widget.configPvd.filtration)
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: AppProperties.customBoxShadow
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicWidth(
                          stepWidth: 200,
                          child: ListTile(
                            leading: SizedImage(imagePath: 'assets/Images/Png/objectId_4.png'),
                            title: Text(filtrationSite.commonDetails.name!),
                            trailing: IntrinsicWidth(
                              child: MaterialButton(
                                  color: Theme.of(context).primaryColorLight,
                                  onPressed: (){
                                    setState(() {
                                      widget.configPvd.listOfSelectedSno.addAll(filtrationSite.filters);
                                    });
                                    selectionDialogBox(
                                        context: context,
                                        title: 'Select Filters',
                                        singleSelection: false,
                                        listOfObject: getUnselectedFilterObject(filtrationSite),
                                        onPressed: (){
                                          setState(() {
                                            filtrationSite.filters.clear();
                                            filtrationSite.filters.addAll(widget.configPvd.listOfSelectedSno);
                                            widget.configPvd.listOfSelectedSno.clear();
                                          });
                                          Navigator.pop(context);
                                        }
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add, color: Colors.white,),
                                      Text('Add Filter', style: AppProperties.tableHeaderStyleWhite,)
                                    ],
                                  )
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 200,
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if(filtrationSite.pressureIn != 0.0)
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      width: 250,
                                      child: SvgPicture.asset(
                                        'assets/Images/Svg/objectId_24.svg',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  if(filtrationSite.filters.length == 1)
                                    singleFilter(ratio, constraint, filtrationSite),
                                  if(filtrationSite.filters.length > 1)
                                    multipleFilter(ratio, constraint, filtrationSite),

                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/Images/Svg/objectId_24.svg',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 20,),
                            Text('Pressure In : ', style: AppProperties.listTileBlackBoldStyle,),
                            SizedBox(
                              width: 150,
                              child: Center(
                                child: Text(filtrationSite.pressureIn == 0.0 ? '-' : getObjectName(filtrationSite.pressureIn, widget.configPvd).name!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold),),
                              ),
                            ),
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    widget.configPvd.selectedSno = filtrationSite.pressureIn;
                                  });
                                  selectionDialogBox(
                                      context: context,
                                      title: 'Select Pressure In',
                                      singleSelection: true,
                                      listOfObject: getPressureSensor(filtrationSite, 1),
                                      onPressed: (){
                                        setState(() {
                                          filtrationSite.pressureIn = widget.configPvd.selectedSno;
                                          widget.configPvd.selectedSno = 0.0;
                                        });
                                        Navigator.pop(context);
                                      }
                                  );
                                },
                                icon: Icon(Icons.touch_app, color: Theme.of(context).primaryColor, size: 20,)
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/Images/Svg/objectId_24.svg',
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 20,),
                            const Text('Pressure Out : ', style: AppProperties.listTileBlackBoldStyle,),
                            SizedBox(
                              width: 150,
                              child: Center(
                                child: Text(filtrationSite.pressureOut == 0.0 ? '-' : getObjectName(filtrationSite.pressureOut, widget.configPvd).name!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold),),
                              ),
                            ),
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    widget.configPvd.selectedSno = filtrationSite.pressureOut;
                                  });
                                  selectionDialogBox(
                                      context: context,
                                      title: 'Select Pressure Out',
                                      singleSelection: true,
                                      listOfObject: getPressureSensor(filtrationSite, 2),
                                      onPressed: (){
                                        setState(() {
                                          filtrationSite.pressureOut = widget.configPvd.selectedSno;
                                          widget.configPvd.selectedSno = 0.0;
                                        });
                                        Navigator.pop(context);
                                      }
                                  );
                                },
                                icon: Icon(Icons.touch_app, color: Theme.of(context).primaryColor, size: 20,)
                            )
                          ],
                        ),


                      ],
                    ),
                  )
              ],
            ),
          ),

        );
      }),
    );
  }
  List<DeviceObjectModel> getUnselectedFilterObject(FiltrationModel filtrationSite){
    List<DeviceObjectModel> filterObject = widget.configPvd.listOfGeneratedObject
        .where((object) => object.objectId == 11)
        .toList();
    List<double> assignedFilters = [];
    List<double> unAssignedFilters = [];
    for(var site in widget.configPvd.filtration){
      for(var filterSno in site.filters){
        assignedFilters.add(filterSno);
      }
    }
    filterObject = filterObject.where((object) => (!assignedFilters.contains(object.sNo!) || filtrationSite.filters.contains(object.sNo))).toList();
    return filterObject;
  }
  List<DeviceObjectModel> getPressureSensor(FiltrationModel filtrationSite, int pressureMode){
    List<double> assignedPressureSensor = [];
    List<double> sensorList = [];
    for(var filtration in widget.configPvd.filtration){
      if(filtration.pressureIn != 0.0){
        assignedPressureSensor.add(filtration.pressureIn);
      }
      if(filtration.pressureOut != 0.0){
        assignedPressureSensor.add(filtration.pressureOut);
      }
    }
    for(var object in widget.configPvd.listOfGeneratedObject){
      double currentPressureSno = pressureMode == 1 ?  filtrationSite.pressureIn : filtrationSite.pressureOut;
      if(currentPressureSno == object.sNo || (!assignedPressureSensor.contains(object.sNo) && object.objectId == 24)){
        sensorList.add(object.sNo!);
      }
    }
    return widget.configPvd.listOfGeneratedObject.where((generatedObject) => sensorList.contains(generatedObject.sNo)).toList();
  }

  Widget firstHorizontalPipe(double ratio){
    return SizedBox(
      width: 60 * ratio,
      height: 150 * ratio,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/Images/Filtration/horizontal_pipe_4.svg',
              width: 60,
              height: 8 * ratio,
            ),
          ),
          Positioned(
            top: 22,
            right: 0,
            child: SvgPicture.asset(
              'assets/Images/Filtration/horizontal_pipe_0.svg',
              width: 60,
              height: 8 * ratio,
            ),
          ),
        ],
      ),
    );
  }

  Widget secondHorizontalPipe(double ratio, BoxConstraints constraint, FiltrationModel filtrationSite){
    return SizedBox(
      width: 60,
      height: 150 * ratio,
      child: Stack(
        children: [
          Positioned(
            bottom: 2 * ratio,
            child: SvgPicture.asset(
              'assets/Images/Filtration/horizontal_pipe_4.svg',
              width: 60 * ratio,
              height: 8 * ratio,
            ),
          ),
          if(filtrationSite.pressureOut != 0.0)
            Positioned(
              bottom: constraint.maxWidth < 500 ? 5 : 10,
              child: SvgPicture.asset(
                'assets/Images/Svg/objectId_24.svg',
                width: 30,
                height: 30,
              ),
            ),
        ],
      ),
    );
  }

  Widget multipleFilterFirstFilter(double ratio,double filterSno){
    DeviceObjectModel filterObject = widget.configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo == filterSno);
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/Images/Filtration/multiple_filter_first_4.svg',
          width: 150,
          height: 150 * ratio,
        ),
        Positioned(
          top: 20 * ratio,
          child: SvgPicture.asset(
            'assets/Images/Filtration/multiple_filter_first_backwash_pipe_0.svg',
            width: 150,
            height: 17.3 * ratio,
          ),
        ),
      ],
    );
  }

  Widget multipleFilterMiddleFilter(double ratio, double filterSno){
    DeviceObjectModel filterObject = widget.configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo == filterSno);
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/Images/Filtration/multiple_filter_middle_4.svg',
          width: 150,
          height: 150 * ratio,
        ),
        Positioned(
          top: 20 * ratio,
          child: SvgPicture.asset(
            'assets/Images/Filtration/multiple_filter_middle_backwash_pipe_0.svg',
            width: 150,
            height: 17.1 * ratio,
          ),
        ),

      ],
    );
  }

  Widget multipleFilterLastFilter(double ratio, double filterSno){
    DeviceObjectModel filterObject = widget.configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo == filterSno);
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/Images/Filtration/multiple_filter_last_4.svg',
          width: 150,
          height: 150 * ratio,
        ),
        Positioned(
          bottom: 0,
          child: SvgPicture.asset(
            'assets/Images/Filtration/multiple_filter_last_bottom_filtration_pipe_4.svg',
            width: 150,
            height: 17 * ratio,
          ),
        ),
      ],
    );
  }

  Widget singleFilter(double ratio, BoxConstraints constraint, FiltrationModel filtrationSite){
    DeviceObjectModel filterObject = widget.configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo == filtrationSite.filters[0]);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        firstHorizontalPipe(ratio),
        Stack(
          children: [
            SvgPicture.asset(
              'assets/Images/Filtration/single_filter_4.svg',
              width: 150,
              height: 150 * ratio,
            ),
          ],
        ),
        secondHorizontalPipe(ratio, constraint, filtrationSite),
      ],
    );
  }

  Widget multipleFilter(double ratio, BoxConstraints constraint, FiltrationModel filtrationSite){
    print('filtrationSite : ${filtrationSite.filters}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        firstHorizontalPipe(ratio),
        if(filtrationSite.filters.isNotEmpty)
          multipleFilterFirstFilter(ratio, filtrationSite.filters[0]),
        if(filtrationSite.filters.length > 2)
          for(var middleFilter = 1;middleFilter < filtrationSite.filters.length - 1;middleFilter++)
            multipleFilterMiddleFilter(ratio, filtrationSite.filters[middleFilter]),
        if(filtrationSite.filters.length > 1)
          multipleFilterLastFilter(ratio, filtrationSite.filters[filtrationSite.filters.length - 1]),
        secondHorizontalPipe(ratio, constraint, filtrationSite),
      ],
    );
  }

}
