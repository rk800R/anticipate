import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/tokens/app_tokens.dart';
import '../../core/format/app_formatters.dart';
import '../events/domain/models.dart';
import '../events/logic/event_book.dart';
import '../events/ui/event_form_sheet.dart';
import '../grid/grid_widget.dart';
import 'countdown_widget.dart';
import '../../anticipate/logic/permission_manager.dart';
import 'logic/milestones.dart';
import 'ui/milestone_card.dart';

/// Provider for loading state.
final loadingProvider = StateProvider<bool>((ref) => true);

/// Provider for events stream.
final eventsStreamProvider = StreamProvider<List<CalEvent>>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return repository.watchAll();
});

/// Provider for EventBook - will be overridden in main.dart.
final eventBookProvider = Provider<EventBook>((ref) {
  throw UnimplementedError('EventBook not initialized');
});

/// Provider for EventRepository - will be overridden in main.dart.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  throw UnimplementedError('EventRepository not initialized');
});

/// Provider for PermissionManager - will be overridden in main.dart.
final permissionManagerProvider = Provider<PermissionManager>((ref) {
  throw UnimplementedError('PermissionManager not initialized');
});

/// Main SOON screen with three states: loading, empty, data.
class SoonScreen extends ConsumerStatefulWidget {
  const SoonScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SoonScreen> createState() => _SoonScreenState();
}

class _SoonScreenState extends ConsumerState<SoonScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading complete after brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(loadingProvider.notifier).state = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final eventsAsync = ref.watch(eventsStreamProvider);

    if (isLoading) {
      return _buildLoading();
    }

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmpty();
        }
        return _buildData(events);
      },
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppTokens.backgroundPrimary,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTokens.accent),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Scaffold(
      backgroundColor: AppTokens.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 80,
                color: AppTokens.textSecondary,
              ),
              const SizedBox(height: AppTokens.spacingLg),
              Text(
                'Nothing on the horizon',
                style: AppTokens.headlineMedium,
              ),
              const SizedBox(height: AppTokens.spacingSm),
              Text(
                'Add your first event to start anticipating',
                style: AppTokens.bodyMedium,
              ),
              const SizedBox(height: AppTokens.spacingLg),
              ElevatedButton.icon(
                onPressed: () => _openFormSheet(),
                icon: const Icon(Icons.add),
                label: const Text('Add Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildData(List<CalEvent> events) {
    // Compute occurrences
    final eventBook = ref.read(eventBookProvider);
    final occurrences = eventBook.nextOccurrences(events);

    if (occurrences.isEmpty) {
      return _buildEmpty();
    }

    final nearest = occurrences.first;
    
    // Compute milestones for yearly/birthday events
    final milestones = Milestones.compute(events);

    return Scaffold(
      backgroundColor: AppTokens.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppTokens.backgroundPrimary,
        elevation: 0,
        title: const Text('SOON'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () => _navigateToGrid(events),
            tooltip: 'Grid View',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero: nearest event with big live countdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTokens.spacingLg),
                decoration: BoxDecoration(
                  color: AppTokens.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppTokens.spacingMd),
                ),
                child: Column(
                  children: [
                    Text(
                      nearest.event.title,
                      style: AppTokens.displayLarge.copyWith(
                        color: nearest.event.colorValue,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spacingSm),
                    Text(
                      AppFormatters.dateShort(nearest.occurrenceDate ?? DateTime.now()),
                      style: AppTokens.bodyMedium,
                    ),
                    const SizedBox(height: AppTokens.spacingLg),
                    CountdownWidget(occurrence: nearest),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.spacingXl),
              // Milestones section
              if (milestones.isNotEmpty) ...[
                Text(
                  'Milestones',
                  style: AppTokens.headlineMedium,
                ),
                const SizedBox(height: AppTokens.spacingMd),
                ...milestones.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.spacingSm),
                  child: MilestoneCard(
                    milestone: m,
                    onTap: () {
                      // Could open edit sheet here
                    },
                  ),
                )),
                const SizedBox(height: AppTokens.spacingXl),
              ],
              // Feed sorted by daysUntil
              Text(
                'Upcoming',
                style: AppTokens.headlineMedium,
              ),
              const SizedBox(height: AppTokens.spacingMd),
              ...occurrences.skip(1).map((occ) => _buildEventTile(occ)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFormSheet,
        backgroundColor: AppTokens.accent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventTile(UpcomingOccurrence occ) {
    final isPast = occ.daysUntil < 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.spacingSm),
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppTokens.spacingSm),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: occ.event.colorValue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occ.event.title,
                  style: AppTokens.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  isPast 
                      ? '${AppFormatters.days(-occ.daysUntil)} since'
                      : AppFormatters.days(occ.daysUntil),
                  style: AppTokens.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            AppFormatters.dateShort(occ.occurrenceDate ?? DateTime.now()),
            style: AppTokens.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _openFormSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventFormSheet(
        onSave: (CalEvent event) async {
          // Generate idempotency key
          final String idempotencyKey = const Uuid().v4();
          
          // Check permission status on first save
          final permissionManager = ref.read(permissionManagerProvider);
          if (permissionManager.status == PermissionStatus.neverAsked) {
            await permissionManager.requestPermission();
          }
          
          // Save the event
          final eventBook = ref.read(eventBookProvider);
          await eventBook.add(event, idempotencyKey);
          
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToGrid(List<CalEvent> events) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: AppTokens.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: AppTokens.backgroundPrimary,
            elevation: 0,
            title: const Text('Grid'),
          ),
          body: GridWidget(
            monthStart: DateTime.now(),
            events: events,
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Scaffold(
      backgroundColor: AppTokens.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTokens.errorColor,
            ),
            const SizedBox(height: AppTokens.spacingLg),
            Text(
              'Something went wrong',
              style: AppTokens.headlineMedium,
            ),
            const SizedBox(height: AppTokens.spacingSm),
            Text(
              error.toString(),
              style: AppTokens.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
