import 'package:flutter/material.dart';
import '../views/manage_services_view.dart';
import '../views/add_service_view.dart';
import '../views/booking_calendar_view.dart';

class AppPages {
  AppPages._();

  static const initialRoute = '/manage-services';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/manage-services':
        page = const ManageServicesView();
        break;
      case '/add-service':
        page = const AddServiceView();
        break;
      case '/booking-calendar':
        // We capture arguments passed to /booking-calendar here
        // The view model can use ModalRoute.of(context)!.settings.arguments
        // to retrieve it later in build, which we already do in BookingCalendarView
        page = const BookingCalendarView();
        break;
      default:
        page = const ManageServicesView();
    }

    return PageRouteBuilder(
      settings: settings, // Need this to pass arguments
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide in from right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
