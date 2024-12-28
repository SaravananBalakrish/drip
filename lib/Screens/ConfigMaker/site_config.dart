import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Constants/properties.dart';
import '../../StateManagement/config_maker_provider.dart';

class SiteConfig extends StatefulWidget {
  const SiteConfig({super.key});

  @override
  State<SiteConfig> createState() => _SiteConfigState();
}

class _SiteConfigState extends State<SiteConfig> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              _buildTabBar(),
              _buildFiltersGridView()
            ],
          );
        }
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for(int i = 0; i < 5; i++)
            _buildTab(i)
        ],
      ),
    );
  }

  Widget _buildTab(int i) {
    return InkWell(
      onTap: () {
        context.read<ConfigMakerProvider>().updateSelectedSiteConfig(i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 3,
              color: context.read<ConfigMakerProvider>().selectedSiteConfig == i
                  ? AppProperties.selectedColor
                  : Colors.white,
            ),
          ),
        ),
        child: Text(
          ConfigMakerProvider.siteConfigTabs[i],
          style: TextStyle(
              fontWeight: context.read<ConfigMakerProvider>().selectedSiteConfig == i
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: context.read<ConfigMakerProvider>().selectedSiteConfig == i
                  ? AppProperties.selectedColor
                  : Colors.black
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersGridView() {
    return Expanded(
      child: ResponsiveGridList(
        horizontalGridSpacing: 50,
        verticalGridSpacing: 50,
        horizontalGridMargin: 25,
        verticalGridMargin: 50,
        minItemWidth: 400,
        minItemsPerRow: 2,
        maxItemsPerRow: 5,
        children: [
          for(int index = 0; index < 4; index++)
            _buildFilterItem(index: index)
        ],
      ),
    );
  }

  Widget _buildFilterItem({required int index}) {
    const int length = 3;
    return SizedBox(
      height: 350,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            height: constraints.maxWidth,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: AppProperties.customBoxShadow,
              border: Border.all(color: AppProperties.selectedColor, width: 0.3)
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Item $index',
                  style: const TextStyle(color: Colors.white),
                ),
                Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      scrollDirection: Axis.horizontal,
                        itemCount: length,
                        itemBuilder: (BuildContext context, int index) {
                          return SvgPicture.asset(
                            index == length - 1
                                ? 'assets/SiteConfig/objectId_11_last_0.svg.svg'
                                : 'assets/SiteConfig/objectId_11_center_0.svg',
                            width: constraints.maxWidth / 3,
                          );
                        }
                    )
                )
              ],
            ),
          );
        }
      ),
    );
  }

}
