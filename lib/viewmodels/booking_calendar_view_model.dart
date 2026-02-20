import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../providers/api_provider.dart';
import '../viewmodels/manage_services_view_model.dart';

/// Final ViewModel in the Create/Edit Service flow.
/// Takes the raw data assembled by [AddServiceViewModel], mixes it with
/// user-selected calendrical data, and flushes it securely to the REST API.
class BookingCalendarViewModel extends ChangeNotifier {
  DateTime focusedDay = DateTime.now();
  List<DateTime> selectedDays = [];

  String selectedTimeSlot = 'Morning';

  RangeValues currentRangeValues = const RangeValues(20, 80);

  Map<String, dynamic> serviceData = {};

  /// Binds the `serviceData` passed dynamically via route arguments.
  void initData(Map<String, dynamic> data) {
    serviceData = data;
  }

  /// Toggles dates on or off the multi-select calendar.
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
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Warning!',
            message: 'Please select at least one availability date',
            contentType: ContentType.warning,
          ),
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

    /// Dynamically routes the logic based on whether we are 'CREATING' a new
    /// object or 'UPDATING' an existing one. Avoids duplicating boilerplate API forms.
    final isEdit = postData.containsKey('id') && postData['id'] != null;
    final success = isEdit
        ? await ApiProvider.updateService(postData['id'], postData)
        : await ApiProvider.createService(postData);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: isEdit
                ? 'Service updated successfully'
                : 'Service created successfully',
            contentType: ContentType.success,
          ),
        ),
      );

      // Refresh the services list BEFORE navigating back
      try {
        final manageVm = Provider.of<ManageServicesViewModel>(
          context,
          listen: false,
        );
        await manageVm.fetchServices();
      } catch (_) {}

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/manage-services'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: isEdit
                ? 'Failed to update service. Please check logs.'
                : 'Failed to create service. Please check logs.',
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }
}
