import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../constants/app_theme.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        
        final stats = attendanceProvider.getAttendanceStatistics(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thống kê tháng',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildStatItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Ngày làm việc',
                  value: '${stats['workDays']}',
                  color: AppTheme.primaryColor,
                ),
                
                const SizedBox(height: 12),
                
                _buildStatItem(
                  icon: Icons.schedule_outlined,
                  label: 'Đúng giờ',
                  value: '${stats['onTimePercentage'].toStringAsFixed(0)}%',
                  color: AppTheme.successColor,
                ),
                
                const SizedBox(height: 12),
                
                _buildStatItem(
                  icon: Icons.access_time_outlined,
                  label: 'Muộn',
                  value: '${stats['lateCount']}',
                  color: AppTheme.warningColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
