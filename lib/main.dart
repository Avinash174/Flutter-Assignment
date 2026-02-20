import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'viewmodels/add_service_view_model.dart';
import 'viewmodels/booking_calendar_view_model.dart';
import 'viewmodels/manage_services_view_model.dart';
import 'utils/pref_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the default token if not already set (for assignment purposes)
  final existingToken = await PrefManager.getToken();
  if (existingToken.isEmpty) {
    await PrefManager.saveToken(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODFjY2ViMjQ2MzI4M2MzOTc5ODIwYiIsInJvbGUiOiJwcm92aWRlciIsImlhdCI6MTc3MTQ4ODg4OSwiZXhwIjoxNzcyMDkzNjg5fQ.v7KHJfWDXh72hC14BDPwZ1Lp1mrlAFiTxIpcvfIdZGg',
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ManageServicesViewModel()),
        ChangeNotifierProvider(create: (_) => AddServiceViewModel()),
        ChangeNotifierProvider(create: (_) => BookingCalendarViewModel()),
      ],
      child: MaterialApp(
        title: "Assignment",
        initialRoute: AppPages.initialRoute,
        onGenerateRoute: AppPages.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          // Using standard font implementation to bypass Google Fonts binding crash during early app startup
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.primaryStatusColor,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
      ),
    ),
  );
}
