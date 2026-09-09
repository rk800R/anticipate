import '../domain/models.dart';

/// Abstract repository interface for event storage.
/// All methods use domain models only - zero Hive types.
abstract class EventRepository {
  /// Watch all events as a stream.
  Stream<List<CalEvent>> watchAll();

  /// Get an event by ID.
  Future<CalEvent?> getById(String id);

  /// Save an event.
  Future<void> save(CalEvent e);

  /// Delete an event by ID.
  Future<void> delete(String id);
}
