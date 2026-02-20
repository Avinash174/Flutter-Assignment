import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../providers/api_provider.dart';

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
    services = data;
    isLoading = false;
    notifyListeners();
  }

  void deleteService(String id) {
    services.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void editService(BuildContext context, String id) {
    Navigator.pushNamed(context, '/add-service', arguments: {'id': id});
  }

  void goToAddService(BuildContext context) {
    Navigator.pushNamed(context, '/add-service');
  }
}
