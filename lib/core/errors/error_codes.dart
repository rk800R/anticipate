/// Error codes for SOON.
/// All errors are represented as codes, not strings.
/// This enables consistent error handling, localization, and testing.

enum ErrorCode {
  // General errors
  unknown,
  
  // Storage errors
  storageNotFound,
  storageWriteFailed,
  storageReadFailed,
  storageDeleteFailed,
  storageCorrupted,
  storageMigrationFailed,
  
  // Event errors
  eventNotFound,
  eventCreateFailed,
  eventUpdateFailed,
  eventDeleteFailed,
  eventInvalidDate,
  eventDuplicate,
  eventValidationFailed,
  
  // Notification errors
  notificationPermissionDenied,
  notificationScheduleFailed,
  notificationCancelFailed,
  notificationNotAvailable,
  
  // Import/Export errors
  importFailed,
  exportFailed,
  importInvalidFormat,
  importDataCorrupted,
  
  // Permission errors
  permissionNotGranted,
  permissionPermanentlyDenied,
}

/// Extension to get human-readable messages for errors.
/// In production, these would be localized.
extension ErrorCodeMessage on ErrorCode {
  String get message {
    switch (this) {
      case ErrorCode.unknown:
        return 'An unexpected error occurred';
      
      // Storage errors
      case ErrorCode.storageNotFound:
        return 'Storage not found';
      case ErrorCode.storageWriteFailed:
        return 'Failed to save data';
      case ErrorCode.storageReadFailed:
        return 'Failed to read data';
      case ErrorCode.storageDeleteFailed:
        return 'Failed to delete data';
      case ErrorCode.storageCorrupted:
        return 'Data is corrupted';
      case ErrorCode.storageMigrationFailed:
        return 'Failed to migrate data';
      
      // Event errors
      case ErrorCode.eventNotFound:
        return 'Event not found';
      case ErrorCode.eventCreateFailed:
        return 'Failed to create event';
      case ErrorCode.eventUpdateFailed:
        return 'Failed to update event';
      case ErrorCode.eventDeleteFailed:
        return 'Failed to delete event';
      case ErrorCode.eventInvalidDate:
        return 'Invalid date specified';
      case ErrorCode.eventDuplicate:
        return 'Event already exists';
      case ErrorCode.eventValidationFailed:
        return 'Event validation failed';
      
      // Notification errors
      case ErrorCode.notificationPermissionDenied:
        return 'Notification permission denied';
      case ErrorCode.notificationScheduleFailed:
        return 'Failed to schedule notification';
      case ErrorCode.notificationCancelFailed:
        return 'Failed to cancel notification';
      case ErrorCode.notificationNotAvailable:
        return 'Notifications not available';
      
      // Import/Export errors
      case ErrorCode.importFailed:
        return 'Import failed';
      case ErrorCode.exportFailed:
        return 'Export failed';
      case ErrorCode.importInvalidFormat:
        return 'Invalid import format';
      case ErrorCode.importDataCorrupted:
        return 'Import data is corrupted';
      
      // Permission errors
      case ErrorCode.permissionNotGranted:
        return 'Permission not granted';
      case ErrorCode.permissionPermanentlyDenied:
        return 'Permission permanently denied';
    }
  }
  
  /// Get a short code for logging/debugging
  String get code => name.toUpperCase();
}

/// Application exception with error code.
class AppException implements Exception {
  final ErrorCode code;
  final String? details;
  final Object? cause;
  
  const AppException(this.code, {this.details, this.cause});
  
  @override
  String toString() {
    if (details != null) {
      return 'AppException(${code.code}): $details';
    }
    return 'AppException(${code.code}): ${code.message}';
  }
}
