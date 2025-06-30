import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/shift_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_log.dart';
import '../constants/app_theme.dart';

class MainActionButton extends StatefulWidget {
  const MainActionButton({super.key});

  @override
  State<MainActionButton> createState() => _MainActionButtonState();
}

class _MainActionButtonState extends State<MainActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulse animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppProvider, ShiftProvider, AttendanceProvider>(
      builder: (context, appProvider, shiftProvider, attendanceProvider, child) {
        final currentShiftId = appProvider.currentShiftId;
        final currentShift = currentShiftId != null 
            ? shiftProvider.getShiftById(currentShiftId)
            : null;
        
        final currentAction = attendanceProvider.currentAction;
        final isSimpleMode = appProvider.simpleMode;
        
        // Show setup message if no shift is selected
        if (currentShift == null) {
          return _buildSetupCard();
        }
        
        // Show completion message if work day is complete
        if (currentAction == null) {
          return _buildCompletionCard();
        }
        
        // Show simple mode button or full action button
        if (isSimpleMode && currentAction == AttendanceAction.goToWork) {
          return _buildSimpleButton(currentShift, attendanceProvider);
        } else {
          return _buildActionButton(currentShift, currentAction, attendanceProvider);
        }
      },
    );
  }

  Widget _buildSetupCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có ca làm việc',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy tạo ca làm việc đầu tiên để bắt đầu sử dụng Workly',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Navigate to shift creation
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo ca làm việc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Hoàn thành ca làm việc',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn đã hoàn thành ca làm việc hôm nay. Chúc bạn nghỉ ngơi vui vẻ!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // View today's summary
                  },
                  icon: const Icon(Icons.summarize_outlined),
                  label: const Text('Xem tổng kết'),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Add note
                  },
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Thêm ghi chú'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleButton(dynamic currentShift, AttendanceProvider attendanceProvider) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: double.infinity,
            height: 120,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _performAction(
                AttendanceAction.goToWork,
                currentShift.id,
                attendanceProvider,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work_outline, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Đi Làm',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentShift.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(dynamic currentShift, AttendanceAction currentAction, AttendanceProvider attendanceProvider) {
    final actionInfo = _getActionInfo(currentAction);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: 8,
            shadowColor: actionInfo['color'].withOpacity(0.3),
            child: InkWell(
              onTap: _isLoading ? null : () => _performAction(
                currentAction,
                currentShift.id,
                attendanceProvider,
              ),
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Action icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: actionInfo['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: actionInfo['color'],
                          width: 2,
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Icon(
                              actionInfo['icon'],
                              size: 40,
                              color: actionInfo['color'],
                            ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action title
                    Text(
                      currentAction.displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: actionInfo['color'],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Shift info
                    Text(
                      'Ca: ${currentShift.name}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    
                    Text(
                      'Thời gian: ${currentShift.timeRangeString}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Current time
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                      builder: (context, snapshot) {
                        final now = snapshot.data ?? DateTime.now();
                        return Text(
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getActionInfo(AttendanceAction action) {
    switch (action) {
      case AttendanceAction.goToWork:
        return {
          'icon': Icons.directions_walk,
          'color': AppTheme.primaryColor,
        };
      case AttendanceAction.checkIn:
        return {
          'icon': Icons.login,
          'color': AppTheme.successColor,
        };
      case AttendanceAction.signWork:
        return {
          'icon': Icons.edit_outlined,
          'color': AppTheme.warningColor,
        };
      case AttendanceAction.checkOut:
        return {
          'icon': Icons.logout,
          'color': AppTheme.errorColor,
        };
      case AttendanceAction.complete:
        return {
          'icon': Icons.check_circle,
          'color': AppTheme.successColor,
        };
    }
  }

  Future<void> _performAction(
    AttendanceAction action,
    String shiftId,
    AttendanceProvider attendanceProvider,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      // Perform the action
      final success = await attendanceProvider.performAttendanceAction(
        action: action,
        shiftId: shiftId,
        requireLocation: action == AttendanceAction.checkIn || action == AttendanceAction.checkOut,
      );

      if (success) {
        // Success feedback
        HapticFeedback.heavyImpact();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${action.displayName} thành công'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Error feedback
        HapticFeedback.vibrate();
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(attendanceProvider.error ?? 'Có lỗi xảy ra'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Error feedback
      HapticFeedback.vibrate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
