import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_dealer/stock_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/formatters.dart';
import '../../view_models/admin_dealer/dealer_device_list_view_model.dart';

class DealerDeviceList extends StatelessWidget {
  const DealerDeviceList({
    super.key,
    required this.userId,
    required this.customerName,
    required this.customerId,
    required this.userRole,
    required this.productStockList,
    required this.fromAdminPage,

  });

  final int userId, customerId;
  final String userRole, customerName;
  final List<StockModel> productStockList;
  final bool fromAdminPage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = DealerDeviceListViewModel(Repository(HttpService()), userId, customerId, productStockList.length);
        viewModel.loadDeviceList(1);
        return viewModel;
      },
      child: Consumer<DealerDeviceListViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                customerName,
                style: const TextStyle(fontSize: 16),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                tooltip: "Close",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                PopupMenuButton(
                  tooltip: 'Add new product to $customerName',
                  color: Colors.white,
                  child : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add New Product',
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ],
                    ),
                  ),
                  onCanceled: () {
                    viewModel.selectedProducts = List<bool>.filled(productStockList.length, false);
                  },
                  itemBuilder: (context) {
                    return _buildProductListPopup(context, viewModel);
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: viewModel.isLoading ? const Center(
              child: CircularProgressIndicator(),
            ):
            Column(
              children: [
                Expanded(
                  child: viewModel.dealerDeviceList.isNotEmpty? DataTable2(
                    scrollController: viewModel.scrollController,
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    headingRowHeight: 30,
                    headingRowColor: WidgetStateProperty.all<
                        Color>(Theme.of(context).primaryColorDark.withAlpha(1)),
                    dataRowHeight: 35,
                    minWidth: 580,
                    columns: const [
                      DataColumn2(
                        label: Text('S.No',),
                        fixedWidth: 40,
                      ),
                      DataColumn2(
                        label: Text('Category'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Model'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('IMEI'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Status'),
                        fixedWidth: 90,
                      ),
                      DataColumn2(
                        label: Text('Modify Date'),
                        fixedWidth: 90,
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      viewModel.dealerDeviceList.length,
                          (index) => DataRow(
                        cells: [
                          DataCell(Center(
                            child: Text(
                              '${index + 1}',
                              style: viewModel.commonTextStyle,
                            ),
                          )),
                          DataCell(Text(viewModel.dealerDeviceList[index].categoryName,
                              style: viewModel.commonTextStyle)),
                          DataCell(Text(viewModel.dealerDeviceList[index].model,
                              style: viewModel.commonTextStyle)),
                          DataCell(SelectableText(viewModel.dealerDeviceList[index].deviceId,
                              style: viewModel.commonTextStyle)),
                          DataCell(Center(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: viewModel.dealerDeviceList[index]
                                      .productStatus ==
                                      1
                                      ? Colors.pink
                                      : viewModel.dealerDeviceList[index].productStatus == 2
                                      ? Colors.blue
                                      : viewModel.dealerDeviceList[index].productStatus == 3
                                      ? Colors.purple
                                      : Colors.green,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  viewModel.dealerDeviceList[index].productStatus == 1
                                      ? 'In-Stock'
                                      : viewModel.dealerDeviceList[index].productStatus == 2
                                      ? 'Stock'
                                      : viewModel.dealerDeviceList[index].productStatus == 3
                                      ? 'Free'
                                      : 'Active',
                                  style: viewModel.commonTextStyle,
                                ),
                              ],
                            ),
                          )),
                          DataCell(
                            Text(
                              Formatters().formatDate(viewModel.dealerDeviceList[index].modifyDate),
                              style: viewModel.commonTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ):
                  const Center(child: Text('No device available'),),
                ),
                viewModel.isLoading? Container(
                  width: double.infinity,
                  height: 30,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(300, 0, 300, 0),
                  child: const CircularProgressIndicator(),
                ):
                Container(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PopupMenuEntry> _buildProductListPopup(BuildContext context, DealerDeviceListViewModel viewModel) {
    if (productStockList.isEmpty) {
      return [const PopupMenuItem(child: Text('No stock available'))];
    }

    String searchText = "";
    List<StockModel> filteredList = List.from(productStockList);

    return [
      PopupMenuItem(
        enabled: false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(productStockList.length > 15)...[
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search...",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value.toLowerCase();
                          filteredList = productStockList.where((item) {
                            return item.categoryName.toLowerCase().contains(searchText) ||
                                item.imeiNo.toLowerCase().contains(searchText);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],

                  SizedBox(
                    height: 350,
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final originalIndex = productStockList.indexOf(item);

                        return CheckboxListTile(
                          title: Text(item.categoryName),
                          subtitle: Text(item.imeiNo),
                          value: viewModel.selectedProducts[originalIndex],
                          onChanged: (value) {
                            setState(() {
                              viewModel.toggleProductSelection(originalIndex);
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: const Text('CANCEL'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      MaterialButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: const Text('ADD'),
                        onPressed: () {
                          viewModel.addProductToDealer(context, productStockList, fromAdminPage);
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    ];
  }
}