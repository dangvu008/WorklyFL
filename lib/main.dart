import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'providers/app_provider.dart';
import 'providers/shift_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/notes_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Initialize services
  await StorageService.instance.init();
  await NotificationService.instance.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const WorklyApp());
}

class WorklyApp extends StatelessWidget {
  const WorklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Workly',
            debugShowCheckedModeBanner: false,
            
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            locale: const Locale('vi', 'VN'),
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            
            // Routes
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
            },
            
            // Error handling
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    appProvider.textScale.clamp(0.8, 1.4),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
