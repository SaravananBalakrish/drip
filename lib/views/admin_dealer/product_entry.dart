import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/product_entry_form/category_form.dart';

class ProductEntry extends StatefulWidget {
  const ProductEntry({super.key, required this.userId});
  final int userId;

  @override
  State<ProductEntry> createState() => _ProductEntryState();
}

class _ProductEntryState extends State<ProductEntry> with SingleTickerProviderStateMixin {

  late final TabController _tabCont;
  late Map<String, Widget> tabWidgets;

  static const List<Object> myObjectList = [
    'Product category',
    'Product model',
    'DD Category',
    'Dealer Definition',
    'Setting menu',
    'Settings category',
    'Languages',
  ];




  @override
  void initState() {
    tabWidgets = {
      'Product category': ProductCategoryForm(userId: widget.userId),
      /*'DD Category': const DDCategory(),
    'Dealer Definition': const DealerDefinitions(),
    'Product category': const ProductCategory(),
    'Product model': const ProductModelForm(),
    'Setting menu': const AddGlobalSettings(),
    'Settings category': const AddSettingCategory(),
    'Languages': const AddLanguage(),*/
    };
    _tabCont = TabController(length: myObjectList.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master'),
        bottom: TabBar(
          controller: _tabCont,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          tabs: [
            ...myObjectList.map((label) => Tab(
              child: Text(label.toString()),
            ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCont,
        children: [
          ...myObjectList.map((label) => tabWidgets[label] ?? Center(child: Text('Page of $label')),
          ),
        ],
      ),
    );
  }
}
