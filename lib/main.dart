import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/tokens/app_tokens.dart';
import 'features/events/data/event_repository.dart';
import 'features/events/data/hive_event_repository.dart';
import 'features/events/logic/event_book.dart';
import 'features/anticipate/data/alarm_scheduler.dart';
import 'features/anticipate/logic/permission_manager.dart';
import 'features/soon/ui/soon_screen.dart';

/// Main entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Open boxes
  final eventsBox = await Hive.openBox('events');
  final permissionsBox = await Hive.openBox('permissions');

  // Create repository and scheduler
  final repository = HiveEventRepository(eventsBox);
  final scheduler = FakeAlarmScheduler();
  final permissionManager = PermissionManager(permissionsBox);

  // Create EventBook
  final eventBook = EventBook(repository, scheduler);

  runApp(
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(repository),
        eventBookProvider.overrideWithValue(eventBook),
      ],
      child: const SoonApp(
        permissionManager: permissionManager,
        repository: repository,
      ),
    ),
  );
}

class SoonApp extends StatelessWidget {
  final PermissionManager permissionManager;
  final EventRepository repository;

  const SoonApp({
    Key? key,
    required this.permissionManager,
    required this.repository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOON',
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
      home: const SoonScreen(),
    );
  }
}
