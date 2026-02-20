import 'package:flutter/material.dart';
import '../views/manage_services_view.dart';
import '../views/add_service_view.dart';
import '../views/booking_calendar_view.dart';

class AppPages {
  AppPages._();

  static const initialRoute = '/manage-services';

  static final Map<String, WidgetBuilder> routes = {
    '/manage-services': (context) => const ManageServicesView(),
    '/add-service': (context) => const AddServiceView(),
    '/booking-calendar': (context) => const BookingCalendarView(),
  };
}
