import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';

/// Demonstrates WTScreenTrackMixin — per-widget screen tracking via RouteAware.
///
/// Setup (done once in main.dart):
/// ```dart
/// final wtRouteObserver = RouteObserver<ModalRoute<void>>();
/// WTScreenTrackMixin.routeObserver = wtRouteObserver;
///
/// MaterialApp(
///   navigatorObservers: [wtRouteObserver],
///   ...
/// )
/// ```
///
/// Then in any StatefulWidget:
/// ```dart
/// class _MyState extends State<MyScreen> with RouteAware, WTScreenTrackMixin {
///   @override String get screenName => 'my_screen';
/// }
/// ```
class MixinDemoScreen extends StatefulWidget {
  const MixinDemoScreen({super.key});

  @override
  State<MixinDemoScreen> createState() => _MixinDemoScreenState();
}

// Apply RouteAware first, then WTScreenTrackMixin.
class _MixinDemoScreenState extends State<MixinDemoScreen>
    with RouteAware, WTScreenTrackMixin {
  int _popNextCount = 0;

  // ── WTScreenTrackMixin overrides ──────────────────────────────────────────

  @override
  String get screenName => 'mixin_demo';

  @override
  String? get screenDisplayName => 'Mixin Demo';

  @override
  Map<String, WTParam>? get screenParams => {
    'source': WTParam.string('route_aware'),
    'pop_next_count': WTParam.number(_popNextCount),
  };

  // ── RouteAware lifecycle (called by WTScreenTrackMixin) ───────────────────

  // didPush → fires when this screen is first pushed — mixin calls trackScreen()
  // didPopNext → fires when popping back to this screen — mixin calls trackScreen() again

  @override
  void didPopNext() {
    setState(() => _popNextCount++);
    super.didPopNext(); // important: mixin uses this to call trackScreen()
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WTScreenTrackMixin Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Code snippet
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'class _MyState extends State<MyScreen>\n'
              '    with RouteAware, WTScreenTrackMixin {\n\n'
              '  @override\n'
              "  String get screenName => 'my_screen';\n\n"
              '  @override\n'
              "  String? get screenDisplayName => 'My Screen';\n\n"
              '  @override\n'
              '  Map<String, WTParam>? get screenParams => {\n'
              "    'user_id': WTParam.string('42'),\n"
              '  };\n'
              '}',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Current state
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This screen\'s tracking config',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow('screenName', "'mixin_demo'"),
                  _InfoRow('screenDisplayName', "'Mixin Demo'"),
                  _InfoRow(
                    'screenParams',
                    "{source: 'route_aware', pop_next_count: $_popNextCount}",
                  ),
                  _InfoRow('isAuto', 'false'),
                  const Divider(height: 20),
                  const Text(
                    'Lifecycle events:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  _LifecycleRow(
                    event: 'didPush',
                    description:
                        'Fires once when screen is pushed → trackScreen() called',
                    fired: true,
                  ),
                  const SizedBox(height: 4),
                  _LifecycleRow(
                    event: 'didPopNext',
                    description:
                        'Fires when returning to this screen → trackScreen() re-called',
                    fired: _popNextCount > 0,
                    count: _popNextCount,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action
          OutlinedButton(
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _AnotherScreen()),
                ),
            child: const Text('Push another screen, then pop back'),
          ),
          const SizedBox(height: 8),
          Text(
            'After popping back here, didPopNext fires and trackScreen is '
            'called again with updated pop_next_count.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnotherScreen extends StatelessWidget {
  const _AnotherScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Another Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Pop back to the Mixin Demo screen to trigger '
                'WTScreenTrackMixin.didPopNext().',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('← Pop Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecycleRow extends StatelessWidget {
  final String event;
  final String description;
  final bool fired;
  final int count;

  const _LifecycleRow({
    required this.event,
    required this.description,
    required this.fired,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fired ? '✅' : '⬜', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event + (count > 0 ? ' (×$count)' : ''),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
