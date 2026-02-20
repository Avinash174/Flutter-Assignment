import 'package:get/get.dart';
import '../../modules/manage_services/bindings/manage_services_binding.dart';
import '../../modules/manage_services/views/manage_services_view.dart';
import '../../modules/add_service/bindings/add_service_binding.dart';
import '../../modules/add_service/views/add_service_view.dart';
import '../../modules/booking_calendar/bindings/booking_calendar_binding.dart';
import '../../modules/booking_calendar/views/booking_calendar_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MANAGE_SERVICES;

  static final routes = [
    GetPage(
      name: _Paths.MANAGE_SERVICES,
      page: () => const ManageServicesView(),
      binding: ManageServicesBinding(),
    ),
    GetPage(
      name: _Paths.ADD_SERVICE,
      page: () => const AddServiceView(),
      binding: AddServiceBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING_CALENDAR,
      page: () => const BookingCalendarView(),
      binding: BookingCalendarBinding(),
    ),
  ];
}
