import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/shift_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/notes_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/main_action_button.dart';
import '../widgets/weather_widget.dart';
import '../widgets/weekly_status_grid.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/recent_notes_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialize weather data if location is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      final weatherProvider = context.read<WeatherProvider>();
      
      if (appProvider.settings.homeLocation != null && 
          appProvider.settings.canShowWeather) {
        final location = appProvider.settings.homeLocation!;
        weatherProvider.getCurrentWeather(
          latitude: location.latitude,
          longitude: location.longitude,
          locationName: location.name,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(),
              
              const SizedBox(height: 24),
              
              // Main action button
              const MainActionButton(),
              
              const SizedBox(height: 24),
              
              // Weather widget
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  if (appProvider.enableWeatherWidget && appProvider.canShowWeather) {
                    return Column(
                      children: [
                        const WeatherWidget(),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // Weekly status grid
              const WeeklyStatusGrid(),
              
              const SizedBox(height: 24),
              
              // Quick stats and recent notes
              Row(
                children: [
                  Expanded(
                    child: QuickStatsCard(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RecentNotesCard(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Quick actions
              _buildQuickActions(),
              
              // Bottom padding for safe area
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Workly'),
      actions: [
        // Theme toggle
        Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            return IconButton(
              icon: Icon(
                appProvider.isDarkMode 
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                appProvider.setThemeMode(!appProvider.isDarkMode);
              },
            );
          },
        ),
        
        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Workly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quản lý ca làm việc',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Trang chủ'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Quản lý ca'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to shifts
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.access_time_outlined),
            title: const Text('Lịch sử chấm công'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to attendance history
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.note_outlined),
            title: const Text('Ghi chú'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to notes
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Thống kê'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to statistics
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Trợ giúp'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final now = DateTime.now();
        final hour = now.hour;
        
        String greeting;
        if (hour < 12) {
          greeting = 'Chào buổi sáng';
        } else if (hour < 18) {
          greeting = 'Chào buổi chiều';
        } else {
          greeting = 'Chào buổi tối';
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hôm nay bạn có gì mới?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.schedule_outlined,
                title: 'Quản lý ca',
                subtitle: 'Tạo và chỉnh sửa ca làm việc',
                onTap: () {
                  // Navigate to shift management
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.note_add_outlined,
                title: 'Thêm ghi chú',
                subtitle: 'Tạo ghi chú mới',
                onTap: () {
                  // Navigate to add note
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final overdueNotes = notesProvider.getOverdueNotes();
        
        if (overdueNotes.isNotEmpty) {
          return FloatingActionButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show overdue notes
            },
            backgroundColor: AppTheme.warningColor,
            child: Badge(
              label: Text('${overdueNotes.length}'),
              child: const Icon(Icons.notification_important_outlined),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _onRefresh() async {
    final weatherProvider = context.read<WeatherProvider>();
    final appProvider = context.read<AppProvider>();
    final shiftProvider = context.read<ShiftProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final notesProvider = context.read<NotesProvider>();

    // Refresh weather if available
    if (appProvider.settings.homeLocation != null &&
        appProvider.settings.canShowWeather) {
      await weatherProvider.refreshWeather();
    }

    // Refresh other data
    await Future.wait([
      shiftProvider.refreshShifts(),
      attendanceProvider.refreshLogs(),
      notesProvider.refreshNotes(),
    ]);
  }
}
