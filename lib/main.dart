import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/tokens/app_tokens.dart';
import 'features/events/data/event_repository.dart';
import 'features/events/data/hive_event_repository.dart';
import 'features/events/logic/event_book.dart';
import 'features/anticipate/data/alarm_scheduler.dart';
import 'features/anticipate/data/flutter_local_alarm_scheduler.dart';
import 'features/anticipate/logic/permission_manager.dart';
import 'app_shell.dart';

/// Main entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open boxes
  final eventsBox = await Hive.openBox('events');
  final permissionsBox = await Hive.openBox('permissions');

  // Initialize timezone and notifications
  tz_data.initializeTimeZones();
  final String timeZoneName = tz.local.timeZoneName;
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  const fln.AndroidInitializationSettings androidSettings =
      fln.AndroidInitializationSettings('@mipmap/ic_launcher');
  const fln.DarwinInitializationSettings iosSettings =
      fln.DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: false,
  );
  const fln.InitializationSettings initSettings = fln.InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await fln.FlutterLocalNotificationsPlugin().initialize(initSettings);

  // Create repository and scheduler
  final repository = HiveEventRepository(eventsBox);
  final scheduler = FlutterLocalAlarmScheduler();
  final permissionManager = PermissionManager(permissionsBox);

  // Create EventBook
  final eventBook = EventBook(repository, scheduler);

  runApp(
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(repository),
        eventBookProvider.overrideWithValue(eventBook),
        permissionManagerProvider.overrideWithValue(permissionManager),
      ],
      child: SoonApp(
        permissionManager: permissionManager,
        repository: repository,
        eventBook: eventBook,
      ),
    ),
  );
}

class SoonApp extends StatelessWidget {
  final PermissionManager permissionManager;
  final EventRepository repository;
  final EventBook eventBook;

  const SoonApp({
    Key? key,
    required this.permissionManager,
    required this.repository,
    required this.eventBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anticipate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTokens.backgroundPrimary,
        primaryColor: AppTokens.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppTokens.accent,
          secondary: AppTokens.todayPulse,
          surface: AppTokens.backgroundSecondary,
          error: AppTokens.errorColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTokens.backgroundPrimary,
          foregroundColor: AppTokens.textPrimary,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppTokens.accent,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTokens.backgroundTertiary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.spacingSm),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}
