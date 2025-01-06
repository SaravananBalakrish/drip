import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Models/Configuration/fertigation_model.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../Constants/dialog_boxes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Models/Configuration/filtration_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/sized_image.dart';
import 'config_web_view.dart';

class SourceConfiguration extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const SourceConfiguration({super.key, required this.configPvd});

  @override
  State<SourceConfiguration> createState() => _SourceConfigurationState();
}

class _SourceConfigurationState extends State<SourceConfiguration> {
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
            child: Column(
              children: [
                ResponsiveGridList(
                  horizontalGridMargin: 0,
                  verticalGridMargin: 10,
                  minItemWidth: 500,
                  shrinkWrap: true,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  children: [
                    for(var source in widget.configPvd.source)
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: AppProperties.customBoxShadow
                        ),
                        height: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for(var i = 0;i < 2;i++)
                                    Stack(
                                      children: [
                                        Positioned(
                                          bottom: 32,
                                          child: SvgPicture.asset(
                                            'assets/Images/Source/backside_pipe_1.svg',
                                            width: 120,
                                            height: 8.5,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          'assets/Images/Source/pump_1.svg',
                                          width: 120,
                                          height: 120,
                                        ),
                                      ],
                                    ),
                                  SvgPicture.asset(
                                    'assets/Images/Source/tank_1.svg',
                                    width: 120,
                                    height: 120,
                                  ),
                                  for(var i = 0;i < 3;i++)
                                    SvgPicture.asset(
                                      'assets/Images/Source/pump_1.svg',
                                      width: 120,
                                      height: 120,
                                    ),
                                ],
                              ),
                            )

                          ],
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),

        );
      }),
    );
  }
}
