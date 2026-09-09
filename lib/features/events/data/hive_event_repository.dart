import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models.dart';
import 'event_repository.dart';
import 'event_dto.dart';

/// Hive implementation of EventRepository.
/// All Hive imports stay in this file.
class HiveEventRepository implements EventRepository {
  final Box<dynamic> _box;
  final StreamController<List<CalEvent>> _controller = StreamController<List<CalEvent>>.broadcast();

  HiveEventRepository(this._box) {
    // Listen to Hive changes and broadcast to stream
    _box.watch().listen((event) {
      _emitAll();
    });
  }

  Box<dynamic> get box => _box;

  void _emitAll() {
    final events = _getAllEvents();
    if (!_controller.isClosed) {
      _controller.add(events);
    }
  }

  List<CalEvent> _getAllEvents() {
    return _box.values.map((value) {
      final raw = value as Map<dynamic, dynamic>;
      final migrated = EventDto.migrate(raw);
      return EventDto(
        id: migrated['id'] as String,
        title: migrated['title'] as String,
        dateMillis: migrated['dateMillis'] as int,
        kindIndex: migrated['kindIndex'] as int,
        colorValue: migrated['colorValue'] as int,
        schemaVersion: migrated['schemaVersion'] as int,
      ).toModel();
    }).toList();
  }

  @override
  Stream<List<CalEvent>> watchAll() {
    _emitAll(); // Emit current state immediately
    return _controller.stream;
  }

  @override
  Future<CalEvent?> getById(String id) async {
    final value = _box.get(id);
    if (value == null) return null;
    
    final raw = value as Map<dynamic, dynamic>;
    final migrated = EventDto.migrate(raw);
    return EventDto(
      id: migrated['id'] as String,
      title: migrated['title'] as String,
      dateMillis: migrated['dateMillis'] as int,
      kindIndex: migrated['kindIndex'] as int,
      colorValue: migrated['colorValue'] as int,
      schemaVersion: migrated['schemaVersion'] as int,
    ).toModel();
  }

  @override
  Future<void> save(CalEvent e) async {
    final dto = EventDto.fromModel(e);
    await _box.put(e.id, {
      'id': dto.id,
      'title': dto.title,
      'dateMillis': dto.dateMillis,
      'kindIndex': dto.kindIndex,
      'colorValue': dto.colorValue,
      'schemaVersion': dto.schemaVersion,
    });
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  void dispose() {
    _controller.close();
  }
}
