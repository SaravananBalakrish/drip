import 'dart:convert';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:html' as html;

Future<bool> generateExcel(Map<String, dynamic> data, String name) async {
  // Create a new workbook
  final workbook = xlsio.Workbook();

  try {
    final sheet = workbook.worksheets[0];
    sheet.name = 'Logs';

    // Create header row
    List<String> headerRow = [
      data['fixedColumn'],
      if (data['generalColumnData'].isNotEmpty)
        for (var j = 0; j < data['generalColumnData'][0].length; j++)
          data['generalColumn'][j],
      if (data['waterColumnData'].isNotEmpty)
        for (var j = 0; j < data['waterColumnData'][0].length; j++)
          'Water ${data['waterColumn'][j]}',
      if (data['filterColumnData'].isNotEmpty)
        for (var j = 0; j < data['filterColumnData'][0].length; j++)
          data['filterColumn'][j],
      if (data['prePostColumnData'].isNotEmpty)
        for (var j = 0; j < data['prePostColumnData'][0].length; j++)
          data['prePostColumn'][j],
      if (data['centralEcPhColumnData'].isNotEmpty)
        for (var j = 0; j < data['centralEcPhColumnData'][0].length; j++)
          data['centralEcPhColumn'][j],
      for (var i = 1; i < 9; i++)
        if (data['centralChannel${i}ColumnData'].isNotEmpty)
          for (var j = 0; j < data['centralChannel${i}ColumnData'][0].length; j++)
            'Central CH$i - ${data['centralChannel${i}Column'][j]}',
      if (data['localEcPhColumnData'].isNotEmpty)
        for (var j = 0; j < data['localEcPhColumnData'][0].length; j++)
          data['localEcPhColumn'][j],
      for (var i = 1; i < 9; i++)
        if (data['localChannel${i}ColumnData'].isNotEmpty)
          for (var j = 0; j < data['localChannel${i}ColumnData'][0].length; j++)
            'Local CH$i - ${data['localChannel${i}Column'][j]}',
    ];

    // Add header row to the sheet
    for (int i = 0; i < headerRow.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headerRow[i]);
    }

    // Add data rows
    for (var i = 0; i < data['fixedColumnData'].length; i++) {
      List<String> eachRow = [data['fixedColumnData'][i]];
      List<String> columnDataKeys = [
        'generalColumnData',
        'waterColumnData',
        'prePostColumnData',
        'centralEcPhColumnData',
        'filterColumnData',
        for (var i = 1; i < 9; i++) 'centralChannel${i}ColumnData',
        'localEcPhColumnData',
        for (var i = 1; i < 9; i++) 'localChannel${i}ColumnData',
      ];

      for (var columnData in columnDataKeys) {
        if (data[columnData][0] != null) {
          for (var j = 0; j < data[columnData][i].length; j++) {
            eachRow.add('${data[columnData][i][j]}');
          }
        }
      }

      for (int j = 0; j < eachRow.length; j++) {
        sheet.getRangeByIndex(i + 2, j + 1).setText(eachRow[j]);
      }
    }

    // Save the file
    final List<int> bytes = workbook.saveAsStream();

    if (bytes.isNotEmpty) {
      // Encode bytes to base64
      final content = base64Encode(bytes);

      // Create a download link
      final anchor = html.AnchorElement(
        href:
        'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$content',
      )
        ..setAttribute('download', '$name.xlsx')
        ..click();

      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error generating Excel: $e');
    return false;
  } finally {
    workbook.dispose();
  }
}
