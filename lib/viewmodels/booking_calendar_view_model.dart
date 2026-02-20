import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/api_provider.dart';

class BookingCalendarViewModel extends ChangeNotifier {
  DateTime focusedDay = DateTime.now();
  List<DateTime> selectedDays = [];

  String selectedTimeSlot = 'Morning';

  RangeValues currentRangeValues = const RangeValues(20, 80);

  Map<String, dynamic> serviceData = {};

  void initData(Map<String, dynamic> data) {
    serviceData = data;
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay_) {
    focusedDay = focusedDay_;
    if (selectedDays.contains(selectedDay)) {
      selectedDays.remove(selectedDay);
    } else {
      selectedDays.add(selectedDay);
    }
    notifyListeners();
  }

  void setTimeSlot(String value) {
    selectedTimeSlot = value;
    notifyListeners();
  }

  void updateTimeRange(RangeValues values) {
    currentRangeValues = values;
    notifyListeners();
  }

  Future<void> createService(BuildContext context) async {
    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one availability date'),
        ),
      );
      return;
    }

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    List<Map<String, String>> availabilityStr = selectedDays
        .map((d) => {"date": formatter.format(d)})
        .toList();

    String start = "09:00 AM";
    String end = "05:00 PM";

    if (selectedTimeSlot == 'Morning') {
      start = "06:00 AM";
      end = "12:00 PM";
    } else if (selectedTimeSlot == 'Afternoon') {
      start = "12:00 PM";
      end = "04:00 PM";
    } else if (selectedTimeSlot == 'Evening') {
      start = "04:00 PM";
      end = "09:00 PM";
    }

    final postData = {
      ...serviceData,
      'startTime': start,
      'endTime': end,
      'availability': availabilityStr,
    };

    final isEdit = postData.containsKey('id') && postData['id'] != null;
    final success = isEdit
        ? await ApiProvider.updateService(postData['id'], postData)
        : await ApiProvider.createService(postData);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Service updated successfully'
                : 'Service created successfully',
          ),
        ),
      );
      Navigator.popUntil(context, ModalRoute.withName('/manage-services'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Failed to update service' : 'Failed to create service',
          ),
        ),
      );
    }
  }
}
