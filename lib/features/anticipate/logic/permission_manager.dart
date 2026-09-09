import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;

/// Permission status for notifications.
enum PermissionStatus {
  neverAsked,
  declined,
  granted,
}

/// Manages notification permissions with persistent storage.
class PermissionManager {
  static const String _boxName = 'permissions';
  static const String _statusKey = 'notification_status';
  
  final Box<dynamic>? _box;
  final fln.FlutterLocalNotificationsPlugin _notifications =
      fln.FlutterLocalNotificationsPlugin();

  PermissionManager(this._box);

  /// Get current permission status.
  PermissionStatus get status {
    if (_box == null) return PermissionStatus.neverAsked;
    
    final raw = _box!.get(_statusKey);
    if (raw == null) return PermissionStatus.neverAsked;
    
    return PermissionStatus.values[raw as int];
  }

  /// Request permission (only call once from event-save flow).
  /// Returns true if granted, false if declined or never asked.
  Future<bool> requestPermission() async {
    if (_box == null) return false;
    
    final currentStatus = status;
    if (currentStatus != PermissionStatus.neverAsked) {
      // Already asked, don't ask again
      return currentStatus == PermissionStatus.granted;
    }
    
    // Request permission from the platform
    final bool? granted = await _notifications
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    if (granted == true) {
      await persistStatus(PermissionStatus.granted);
      return true;
    } else {
      await persistStatus(PermissionStatus.declined);
      return false;
    }
  }

  /// Persist a permission status.
  Future<void> persistStatus(PermissionStatus status) async {
    if (_box == null) return;
    await _box!.put(_statusKey, status.index);
  }
}
