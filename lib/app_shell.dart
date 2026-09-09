import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/tokens/app_tokens.dart';
import 'features/events/domain/models.dart';
import 'features/soon/ui/soon_screen.dart';
import 'features/grid/grid_widget.dart';
import 'features/year/year_ring.dart';

/// Provider for current selected navigation level.
final navIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for events stream (shared across screens).
final allEventsProvider = StreamProvider<List<CalEvent>>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return repository.watchAll();
});

/// Main app shell with three-level navigation: SOON / GRID / YEAR.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(allEventsProvider);

    return Scaffold(
      backgroundColor: AppTokens.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppTokens.backgroundPrimary,
        elevation: 0,
        title: Text(
          ['SOON', 'GRID', 'YEAR'][_selectedIndex],
          style: AppTokens.headlineMedium.copyWith(
            color: _selectedIndex == 1 || _selectedIndex == 2 
                ? AppTokens.accent 
                : null,
          ),
        ),
        centerTitle: true,
      ),
      body: eventsAsync.when(
        data: (events) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildScreen(events, Key(_selectedIndex.toString())),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTokens.accent),
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: AppTokens.bodyMedium),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppTokens.backgroundSecondary,
        indicatorColor: AppTokens.accent.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'SOON',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on_outlined),
            selectedIcon: Icon(Icons.grid_on),
            label: 'GRID',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle),
            label: 'YEAR',
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(List<CalEvent> events, Key key) {
    switch (_selectedIndex) {
      case 0:
        return SoonScreen(key: key);
      case 1:
        return GridWidget(
          key: key,
          monthStart: DateTime.now(),
          events: events,
        );
      case 2:
        return YearRing(
          key: key,
          events: events,
        );
      default:
        return SoonScreen(key: key);
    }
  }
}
