import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../viewmodels/booking_calendar_view_model.dart';

class BookingCalendarView extends StatelessWidget {
  const BookingCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookingCalendarViewModel>();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && viewModel.serviceData.isEmpty) {
      viewModel.initData(args);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking & Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability Calendar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: viewModel.focusedDay,
                selectedDayPredicate: (day) {
                  return viewModel.selectedDays.any(
                    (d) =>
                        d.year == day.year &&
                        d.month == day.month &&
                        d.day == day.day,
                  );
                },
                onDaySelected: viewModel.onDaySelected,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.buttonColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.buttonColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildRadioOption(viewModel, 'Any', 'Any'),
                _buildRadioOption(
                  viewModel,
                  'Morning',
                  'Morning (6 AM - 12 PM)',
                ),
                _buildRadioOption(
                  viewModel,
                  'Afternoon',
                  'Afternoon (12 PM - 4 PM)',
                ),
                _buildRadioOption(
                  viewModel,
                  'Evening',
                  'Evening (4 PM - 9 PM)',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Custom Time Range',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.buttonColor.withValues(alpha: 0.5),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: Colors.white,
                overlayColor: AppTheme.buttonColor.withValues(alpha: 0.1),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 3,
                ),
              ),
              child: RangeSlider(
                values: viewModel.currentRangeValues,
                min: 0,
                max: 100,
                onChanged: viewModel.updateTimeRange,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTimeInput('From')),
                const SizedBox(width: 16),
                Expanded(child: _buildTimeInput('To')),
              ],
            ),
            const SizedBox(height: 40),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppTheme.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => viewModel.createService(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'SAVE & SUBMIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    BookingCalendarViewModel viewModel,
    String value,
    String label,
  ) {
    return InkWell(
      onTap: () => viewModel.setTimeSlot(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: viewModel.selectedTimeSlot == value
                      ? AppTheme.buttonColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: viewModel.selectedTimeSlot == value
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.buttonColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: viewModel.selectedTimeSlot == value
                    ? AppTheme.textDark
                    : Colors.grey.shade600,
                fontWeight: viewModel.selectedTimeSlot == value
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInput(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          const Icon(
            Icons.access_time_filled,
            color: AppTheme.buttonColor,
            size: 18,
          ),
        ],
      ),
    );
  }
}
