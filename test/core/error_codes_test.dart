import 'package:flutter_test/flutter_test.dart';
import 'package:soon/core/errors/error_codes.dart';

void main() {
  group('ErrorCode', () {
    test('all error codes have messages', () {
      for (final code in ErrorCode.values) {
        expect(code.message, isNotEmpty);
        expect(code.code, equals(code.name.toUpperCase()));
      }
    });

    test('storage errors are defined', () {
      expect(ErrorCode.storageNotFound.message, contains('Storage'));
      expect(ErrorCode.storageWriteFailed.message, contains('save'));
      expect(ErrorCode.storageReadFailed.message, contains('read'));
      expect(ErrorCode.storageDeleteFailed.message, contains('delete'));
      expect(ErrorCode.storageCorrupted.message, contains('corrupted'));
      expect(ErrorCode.storageMigrationFailed.message, contains('migrate'));
    });

    test('event errors are defined', () {
      expect(ErrorCode.eventNotFound.message, contains('Event'));
      expect(ErrorCode.eventCreateFailed.message, contains('create'));
      expect(ErrorCode.eventUpdateFailed.message, contains('update'));
      expect(ErrorCode.eventDeleteFailed.message, contains('delete'));
      expect(ErrorCode.eventInvalidDate.message, contains('date'));
      expect(ErrorCode.eventDuplicate.message, contains('exists'));
      expect(ErrorCode.eventValidationFailed.message, contains('validation'));
    });

    test('notification errors are defined', () {
      expect(ErrorCode.notificationPermissionDenied.message, contains('permission'));
      expect(ErrorCode.notificationScheduleFailed.message, contains('schedule'));
      expect(ErrorCode.notificationCancelFailed.message, contains('cancel'));
      expect(ErrorCode.notificationNotAvailable.message, contains('available'));
    });
  });

  group('AppException', () {
    test('creates exception with code only', () {
      final exception = AppException(ErrorCode.eventNotFound);
      
      expect(exception.code, equals(ErrorCode.eventNotFound));
      expect(exception.details, isNull);
      expect(exception.cause, isNull);
      expect(exception.toString(), contains('EVENT_NOT_FOUND'));
    });

    test('creates exception with code and details', () {
      final exception = AppException(
        ErrorCode.eventCreateFailed,
        details: 'Title is required',
      );
      
      expect(exception.code, equals(ErrorCode.eventCreateFailed));
      expect(exception.details, equals('Title is required'));
      expect(exception.toString(), contains('Title is required'));
    });

    test('creates exception with cause', () {
      final cause = Exception('Underlying error');
      final exception = AppException(
        ErrorCode.storageWriteFailed,
        cause: cause,
      );
      
      expect(exception.cause, equals(cause));
    });

    test('toString includes code and message', () {
      final exception = AppException(ErrorCode.unknown);
      final stringRep = exception.toString();
      
      expect(stringRep, contains('UNKNOWN'));
      expect(stringRep, contains('unexpected error'));
    });
  });
}
