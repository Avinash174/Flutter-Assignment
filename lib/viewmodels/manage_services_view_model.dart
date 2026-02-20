import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../models/service_model.dart';
import '../providers/api_provider.dart';
import '../viewmodels/add_service_view_model.dart';

class ManageServicesViewModel extends ChangeNotifier {
  List<ServiceModel> services = [];
  bool isLoading = true;

  ManageServicesViewModel() {
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading = true;
    notifyListeners();
    final data = await ApiProvider.getServices();
    // Newest service items at the top
    services = data.reversed.toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteService(BuildContext context, String id) async {
    final oldList = List<ServiceModel>.from(services);
    services.removeWhere((element) => element.id == id);
    notifyListeners();

    final success = await ApiProvider.deleteService(id);
    if (!success) {
      services = oldList;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: 'Failed to delete service',
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Service deleted successfully',
              contentType: ContentType.success,
            ),
          ),
        );
      }
    }
  }

  Future<void> editService(BuildContext context, String id) async {
    final service = services.firstWhere((s) => s.id == id);
    final addVm = Provider.of<AddServiceViewModel>(context, listen: false);
    addVm.initEditMode(service);
    await Navigator.pushNamed(context, '/add-service');
    fetchServices();
  }

  Future<void> goToAddService(BuildContext context) async {
    final addVm = Provider.of<AddServiceViewModel>(context, listen: false);
    addVm.initAddMode();
    await Navigator.pushNamed(context, '/add-service');
    fetchServices();
  }
}
