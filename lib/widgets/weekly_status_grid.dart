import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_log.dart';
import '../constants/app_theme.dart';

class WeeklyStatusGrid extends StatelessWidget {
  const WeeklyStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, AttendanceProvider>(
      builder: (context, appProvider, attendanceProvider, child) {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        
        final weeklyStatus = attendanceProvider.getWeeklyWorkStatus(
          weekStart,
          shiftId: appProvider.currentShiftId,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tuần này',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weeklyStatus.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dayStatus = entry.value;
                    final dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                    
                    return _buildDayStatus(
                      dayName: dayNames[index],
                      status: dayStatus,
                      isToday: _isToday(dayStatus.date),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayStatus({
    required String dayName,
    required DailyWorkStatus status,
    required bool isToday,
  }) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.overallStatus) {
      case AttendanceStatus.onTime:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.late:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        break;
      case AttendanceStatus.early:
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.fast_forward;
        break;
      case AttendanceStatus.overtime:
        statusColor = Colors.purple;
        statusIcon = Icons.access_time_filled;
        break;
      case AttendanceStatus.absent:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.incomplete:
        statusColor = Colors.grey;
        statusIcon = isToday ? Icons.radio_button_unchecked : Icons.remove_circle_outline;
        break;
    }

    return Column(
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? statusColor : null,
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: isToday ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: isToday ? Border.all(color: statusColor, width: 2) : null,
          ),
          child: Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
        ),
        
        const SizedBox(height: 4),
        
        Text(
          status.workTimeString,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
}
