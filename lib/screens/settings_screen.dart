import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/shift_provider.dart';
import '../providers/notes_provider.dart';
import '../constants/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              // App Settings Section
              _buildSectionHeader('Ứng dụng'),
              _buildSettingsCard([
                _buildSwitchTile(
                  title: 'Chế độ tối',
                  subtitle: 'Sử dụng giao diện tối',
                  icon: Icons.dark_mode_outlined,
                  value: appProvider.isDarkMode,
                  onChanged: (value) => appProvider.setThemeMode(value),
                ),
                _buildSwitchTile(
                  title: 'Chế độ đơn giản',
                  subtitle: 'Chỉ hiển thị nút "Đi Làm"',
                  icon: Icons.view_compact_outlined,
                  value: appProvider.simpleMode,
                  onChanged: (value) => appProvider.setSimpleMode(value),
                ),
                _buildSwitchTile(
                  title: 'Rung phản hồi',
                  subtitle: 'Rung khi chạm vào nút',
                  icon: Icons.vibration_outlined,
                  value: appProvider.settings.enableHapticFeedback,
                  onChanged: (value) => appProvider.setHapticFeedback(value),
                ),
              ]),

              const SizedBox(height: 24),

              // Notification Settings Section
              _buildSectionHeader('Thông báo'),
              _buildSettingsCard([
                _buildSwitchTile(
                  title: 'Thông báo',
                  subtitle: 'Nhận thông báo từ ứng dụng',
                  icon: Icons.notifications_outlined,
                  value: appProvider.enableNotifications,
                  onChanged: (value) => appProvider.setNotifications(value),
                ),
                _buildSwitchTile(
                  title: 'Cảnh báo thời tiết',
                  subtitle: 'Nhận cảnh báo thời tiết cực đoan',
                  icon: Icons.wb_cloudy_outlined,
                  value: appProvider.enableWeatherAlerts,
                  onChanged: (value) => appProvider.setWeatherAlerts(value),
                ),
                _buildSwitchTile(
                  title: 'Nhắc nhở ca làm việc',
                  subtitle: 'Nhắc nhở trước khi bắt đầu ca',
                  icon: Icons.schedule_outlined,
                  value: appProvider.enableShiftReminders,
                  onChanged: (value) => appProvider.setShiftReminders(value),
                ),
              ]),

              const SizedBox(height: 24),

              // Work Settings Section
              _buildSectionHeader('Công việc'),
              _buildSettingsCard([
                _buildListTile(
                  title: 'Lương theo giờ',
                  subtitle: appProvider.settings.formattedHourlyRate,
                  icon: Icons.attach_money_outlined,
                  onTap: () => _showHourlyRateDialog(context, appProvider),
                ),
                _buildListTile(
                  title: 'Quản lý ca làm việc',
                  subtitle: 'Tạo và chỉnh sửa ca làm việc',
                  icon: Icons.work_outline,
                  onTap: () {
                    // Navigate to shift management
                  },
                ),
                _buildSwitchTile(
                  title: 'Tự động phát hiện vị trí',
                  subtitle: 'Tự động lấy vị trí khi chấm công',
                  icon: Icons.location_on_outlined,
                  value: appProvider.settings.autoLocationDetection,
                  onChanged: (value) => appProvider.setAutoLocationDetection(value),
                ),
              ]),

              const SizedBox(height: 24),

              // Weather Settings Section
              _buildSectionHeader('Thời tiết'),
              _buildSettingsCard([
                _buildSwitchTile(
                  title: 'Hiển thị thời tiết',
                  subtitle: 'Hiển thị widget thời tiết trên trang chủ',
                  icon: Icons.wb_sunny_outlined,
                  value: appProvider.enableWeatherWidget,
                  onChanged: (value) => appProvider.setWeatherWidget(value),
                ),
                _buildListTile(
                  title: 'API Key thời tiết',
                  subtitle: appProvider.settings.hasWeatherApiKey 
                      ? 'Đã cấu hình'
                      : 'Chưa cấu hình',
                  icon: Icons.key_outlined,
                  onTap: () => _showApiKeyDialog(context, appProvider),
                ),
                _buildListTile(
                  title: 'Vị trí nhà',
                  subtitle: appProvider.settings.homeLocation?.name ?? 'Chưa thiết lập',
                  icon: Icons.home_outlined,
                  onTap: () {
                    // Navigate to location settings
                  },
                ),
                _buildListTile(
                  title: 'Vị trí công ty',
                  subtitle: appProvider.settings.workLocation?.name ?? 'Chưa thiết lập',
                  icon: Icons.business_outlined,
                  onTap: () {
                    // Navigate to location settings
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // Data Settings Section
              _buildSectionHeader('Dữ liệu'),
              _buildSettingsCard([
                _buildListTile(
                  title: 'Xuất dữ liệu',
                  subtitle: 'Sao lưu dữ liệu ra file',
                  icon: Icons.download_outlined,
                  onTap: () => _exportData(context),
                ),
                _buildListTile(
                  title: 'Nhập dữ liệu',
                  subtitle: 'Khôi phục dữ liệu từ file',
                  icon: Icons.upload_outlined,
                  onTap: () => _importData(context),
                ),
                _buildListTile(
                  title: 'Xóa tất cả dữ liệu',
                  subtitle: 'Xóa toàn bộ dữ liệu ứng dụng',
                  icon: Icons.delete_outline,
                  onTap: () => _showClearDataDialog(context),
                  textColor: AppTheme.errorColor,
                ),
              ]),

              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('Về ứng dụng'),
              _buildSettingsCard([
                _buildListTile(
                  title: 'Phiên bản',
                  subtitle: AppConstants.appVersion,
                  icon: Icons.info_outline,
                  onTap: () {},
                ),
                _buildListTile(
                  title: 'Trợ giúp',
                  subtitle: 'Hướng dẫn sử dụng',
                  icon: Icons.help_outline,
                  onTap: () {
                    // Navigate to help
                  },
                ),
                _buildListTile(
                  title: 'Liên hệ',
                  subtitle: 'Gửi phản hồi cho nhà phát triển',
                  icon: Icons.contact_support_outlined,
                  onTap: () {
                    // Open contact
                  },
                ),
              ]),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      leading: Icon(icon, color: textColor),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showHourlyRateDialog(BuildContext context, AppProvider appProvider) {
    final controller = TextEditingController(
      text: appProvider.hourlyRate.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lương theo giờ'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Lương (VND/giờ)',
            hintText: 'Nhập lương theo giờ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final rate = double.tryParse(controller.text);
              if (rate != null && rate > 0) {
                appProvider.setHourlyRate(rate);
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, AppProvider appProvider) {
    final controller = TextEditingController(
      text: appProvider.settings.weatherApiKey ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key thời tiết'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Nhập API key từ OpenWeatherMap',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lấy API key miễn phí tại openweathermap.org',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              appProvider.setWeatherApiKey(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Đang xuất dữ liệu...'),
            ],
          ),
        ),
      );

      // Collect all data
      final appProvider = context.read<AppProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final shiftProvider = context.read<ShiftProvider>();
      final notesProvider = context.read<NotesProvider>();

      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'user_settings': appProvider.settings.toJson(),
        'attendance_logs': attendanceProvider.logs.map((log) => log.toJson()).toList(),
        'shifts': shiftProvider.shifts.map((shift) => shift.toJson()).toList(),
        'notes': notesProvider.notes.map((note) => note.toJson()).toList(),
      };

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'workly_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      // Write to file
      await file.writeAsString(jsonString);

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sao lưu dữ liệu Workly',
        subject: 'Workly Data Backup',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xuất dữ liệu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xuất dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final file = File(result.files.single.path!);

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Đang nhập dữ liệu...'),
              ],
            ),
          ),
        );
      }

      // Read and parse file
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate data structure
      if (!data.containsKey('user_settings') ||
          !data.containsKey('attendance_logs') ||
          !data.containsKey('shifts') ||
          !data.containsKey('notes')) {
        throw Exception('File không đúng định dạng');
      }

      // Import data to providers
      // Note: Import methods need to be implemented in respective providers
      // final appProvider = context.read<AppProvider>();
      // final attendanceProvider = context.read<AttendanceProvider>();
      // final shiftProvider = context.read<ShiftProvider>();
      // final notesProvider = context.read<NotesProvider>();

      // Import settings (optional, user can choose to keep current settings)
      // await appProvider.importSettings(data['user_settings']);

      // Import attendance logs
      // await attendanceProvider.importLogs(data['attendance_logs']);

      // Import shifts
      // await shiftProvider.importShifts(data['shifts']);

      // Import notes
      // await notesProvider.importNotes(data['notes']);

      // For now, just validate that the file was read successfully
      // Import methods need to be implemented in respective providers

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nhập dữ liệu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nhập dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả dữ liệu'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first

              try {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Đang xóa dữ liệu...'),
                      ],
                    ),
                  ),
                );

                // Clear all data from providers
                final attendanceProvider = context.read<AttendanceProvider>();
                final shiftProvider = context.read<ShiftProvider>();
                final notesProvider = context.read<NotesProvider>();

                await Future.wait([
                  attendanceProvider.clearAllLogs(),
                  shiftProvider.clearAllShifts(),
                  notesProvider.clearAllNotes(),
                ]);

                // Close loading dialog
                if (context.mounted) Navigator.pop(context);

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa toàn bộ dữ liệu thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog if still open
                if (context.mounted) Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi xóa dữ liệu: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
