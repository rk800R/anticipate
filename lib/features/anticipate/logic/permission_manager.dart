import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

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
  /// Note: Real implementation requires flutter_local_notifications and platform code.
  Future<bool> requestPermission() async {
    // For now, just mark as neverAsked since we can't actually request on desktop
    // The real implementation comes later when testing on phone
    if (_box == null) return false;
    
    // Store that we've asked (simulating "never asked" -> still never asked for fake impl)
    await _box!.put(_statusKey, PermissionStatus.neverAsked.index);
    return false; // Can't grant on desktop
  }

  /// Persist a permission status.
  Future<void> persistStatus(PermissionStatus status) async {
    if (_box == null) return;
    await _box!.put(_statusKey, status.index);
  }
}
