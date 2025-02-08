import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../Models/customer/sent_and_received_model.dart';
import '../../repository/repository.dart';

class SentAndReceivedViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";
  List<SentAndReceivedModel> sentAndReceivedList = [];

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  SentAndReceivedViewModel(this.repository);

  Future<void> getSentAndReceivedData(customerId, controllerId, date) async {
    setLoading(true);
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "fromDate":date, "toDate":date};
      final response = await repository.fetchSentAndReceivedData(body);
      if (response.statusCode == 200) {
        sentAndReceivedList.clear();
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sentAndReceivedList = [
            ...jsonData['data'].map((programJson) => SentAndReceivedModel.fromJson(programJson)).toList(),
          ];
        }
      }
    } catch (error) {
      debugPrint('Error fetching country list: $error');
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void onDateChanged(customerId, controllerId, sDate, fDate) {
    selectedDay = sDate;
    focusedDay = fDate;
    getSentAndReceivedData(customerId, controllerId, sDate);
  }

}