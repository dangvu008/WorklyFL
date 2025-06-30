import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/app_provider.dart';
import '../models/weather_data.dart';
import '../constants/app_theme.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeatherProvider, AppProvider>(
      builder: (context, weatherProvider, appProvider, child) {
        if (!appProvider.enableWeatherWidget || !appProvider.canShowWeather) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thời tiết',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (weatherProvider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => weatherProvider.refreshWeather(),
                        iconSize: 20,
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                if (weatherProvider.error != null)
                  _buildErrorState(weatherProvider.error!)
                else if (weatherProvider.currentWeather != null)
                  _buildWeatherContent(weatherProvider.currentWeather!)
                else
                  _buildEmptyState(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherContent(WeatherData weather) {
    return Column(
      children: [
        Row(
          children: [
            // Weather icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getWeatherColor(weather.condition).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getWeatherIcon(weather.condition),
                size: 32,
                color: _getWeatherColor(weather.condition),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Temperature and location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.temperatureString,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.location.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Feels like temperature
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Cảm giác',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  weather.feelsLikeString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Weather details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherDetail(
              icon: Icons.water_drop_outlined,
              label: 'Độ ẩm',
              value: weather.humidityString,
            ),
            _buildWeatherDetail(
              icon: Icons.air,
              label: 'Gió',
              value: weather.windSpeedString,
            ),
            _buildWeatherDetail(
              icon: Icons.visibility_outlined,
              label: 'Tầm nhìn',
              value: weather.visibilityString,
            ),
          ],
        ),
        
        // Weather alerts
        if (weather.alerts.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...weather.alerts.where((alert) => alert.isActive).map(
            (alert) => _buildWeatherAlert(alert),
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAlert(WeatherAlert alert) {
    Color alertColor;
    IconData alertIcon;
    
    switch (alert.severity) {
      case WeatherSeverity.warning:
        alertColor = AppTheme.warningColor;
        alertIcon = Icons.warning_outlined;
        break;
      case WeatherSeverity.severe:
        alertColor = AppTheme.errorColor;
        alertIcon = Icons.error_outline;
        break;
      case WeatherSeverity.extreme:
        alertColor = Colors.red[800]!;
        alertIcon = Icons.dangerous_outlined;
        break;
      default:
        alertColor = AppTheme.primaryColor;
        alertIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            alertIcon,
            size: 20,
            color: alertColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: alertColor,
                  ),
                ),
                if (alert.message.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: alertColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chưa có dữ liệu thời tiết',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Hãy thiết lập vị trí trong cài đặt',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Icons.wb_sunny_outlined;
      case WeatherCondition.clouds:
        return Icons.cloud_outlined;
      case WeatherCondition.rain:
        return Icons.umbrella_outlined;
      case WeatherCondition.drizzle:
        return Icons.grain_outlined;
      case WeatherCondition.thunderstorm:
        return Icons.thunderstorm_outlined;
      case WeatherCondition.snow:
        return Icons.ac_unit_outlined;
      case WeatherCondition.mist:
      case WeatherCondition.fog:
        return Icons.foggy;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  Color _getWeatherColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.orange;
      case WeatherCondition.clouds:
        return Colors.grey;
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
        return Colors.blue;
      case WeatherCondition.thunderstorm:
        return Colors.purple;
      case WeatherCondition.snow:
        return Colors.lightBlue;
      case WeatherCondition.mist:
      case WeatherCondition.fog:
        return Colors.blueGrey;
      default:
        return AppTheme.primaryColor;
    }
  }
}
