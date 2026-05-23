import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wisetrack/wisetrack.dart';
import 'package:wisetrack_example/tracking_observer.dart';

/// Self-contained app demonstrating WTNavigatorObserver integration with go_router.
///
/// Key setup:
/// ```dart
/// final router = GoRouter(
///   observers: [WTNavigatorObserver(config: WTScreenTrackingConfig(...))],
///   routes: [...],
/// );
/// MaterialApp.router(routerConfig: router);
/// ```
class GoRouterDemoApp extends StatefulWidget {
  const GoRouterDemoApp({super.key});

  @override
  State<GoRouterDemoApp> createState() => _GoRouterDemoAppState();
}

class _GoRouterDemoAppState extends State<GoRouterDemoApp> {
  bool _initialized = false;
  late final NavigatorState _outerNav;
  late final ValueNotifier<List<String>> _log;
  late final WTDemoNavigatorObserver _observer;
  late final GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _outerNav = Navigator.of(context);
      _log = ValueNotifier<List<String>>([]);
      _observer = WTDemoNavigatorObserver(
        log: _log,
        config: const WTScreenTrackingConfig(
          enabled: true,
          trackDialogs: true,
          deduplicationWindowMs: 300,
        ),
      );
      _router = GoRouter(
        observers: [_observer],
        routes: [
          GoRoute(
            path: '/',
            builder:
                (ctx, state) =>
                    _GoRouterHomeScreen(log: _log, onClose: _outerNav.pop),
          ),
          GoRoute(
            path: '/category/:id',
            builder:
                (ctx, state) => _GoRouterCategoryScreen(
                  categoryId: state.pathParameters['id']!,
                  log: _log,
                ),
          ),
          GoRoute(
            path: '/category/:id/product/:productId',
            builder:
                (ctx, state) => _GoRouterProductScreen(
                  categoryId: state.pathParameters['id']!,
                  productId: state.pathParameters['productId']!,
                ),
          ),
          GoRoute(
            path: '/search',
            builder:
                (ctx, state) => _GoRouterSearchScreen(
                  query: state.uri.queryParameters['q'] ?? '',
                ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _router.dispose();
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context),
    );
  }
}

// ── Screens ─────────────────────────────────────────────────────────────────

class _GoRouterHomeScreen extends StatelessWidget {
  final ValueNotifier<List<String>> log;
  final VoidCallback onClose;

  const _GoRouterHomeScreen({required this.log, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
          tooltip: 'Back to main app',
        ),
        title: const Text('Go Router Demo'),
      ),
      body: Column(
        children: [
          // Setup code snippet
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'final router = GoRouter(\n'
              '  observers: [\n'
              '    WTNavigatorObserver(\n'
              '      config: WTScreenTrackingConfig(\n'
              '        enabled: true,\n'
              '        trackDialogs: true,\n'
              '      ),\n'
              '    ),\n'
              '  ],\n'
              '  routes: [...],\n'
              ');\n'
              'MaterialApp.router(routerConfig: router)',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),

          // Live log
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tracked events (go_router observer):',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<List<String>>(
                  valueListenable: log,
                  builder: (_, events, __) {
                    if (events.isEmpty) {
                      return const Text(
                        'Navigate to a route to see events.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          events
                              .take(6)
                              .map(
                                (e) => Text(
                                  e,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              )
                              .toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Navigation buttons
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RouteButton(
                  label: 'Push /category/electronics',
                  tracked: "screenName: 'category/electronics'",
                  onTap: () => context.push('/category/electronics'),
                ),
                const SizedBox(height: 8),
                _RouteButton(
                  label: 'Push /category/books',
                  tracked: "screenName: 'category/books'",
                  onTap: () => context.push('/category/books'),
                ),
                const SizedBox(height: 8),
                _RouteButton(
                  label: 'Push /search?q=flutter',
                  tracked: "screenName: 'search', params: {q: 'flutter'}",
                  onTap: () => context.push('/search?q=flutter'),
                ),
                const SizedBox(height: 8),
                _RouteButton(
                  label: 'Show Dialog (trackDialogs: true)',
                  tracked: "type: dialog",
                  onTap:
                      () => showDialog(
                        context: context,
                        routeSettings: const RouteSettings(name: '/confirm'),
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Go Router Dialog'),
                              content: const Text(
                                'Tracked as WTScreenType.dialog '
                                'because trackDialogs is true.',
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                      ),
                ),
                const SizedBox(height: 8),
                _RouteButton(
                  label: 'Show Bottom Sheet',
                  tracked: "type: bottomSheet",
                  onTap:
                      () => showModalBottomSheet(
                        context: context,
                        routeSettings: const RouteSettings(name: '/sort-sheet'),
                        builder:
                            (_) => Container(
                              height: 220,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sort Options',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "route: '/sort-sheet' → type: bottomSheet",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Divider(height: 20),
                                  const Text('• Price: Low to High'),
                                  const SizedBox(height: 4),
                                  const Text('• Price: High to Low'),
                                  const SizedBox(height: 4),
                                  const Text('• Newest First'),
                                ],
                              ),
                            ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoRouterCategoryScreen extends StatelessWidget {
  final String categoryId;
  final ValueNotifier<List<String>> log;

  const _GoRouterCategoryScreen({required this.categoryId, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category: $categoryId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoBox(
              "Route: /category/$categoryId\n"
              "→ screenName: 'category/$categoryId'\n"
              "→ displayName: '${categoryId[0].toUpperCase()}${categoryId.substring(1)}'",
            ),
            const SizedBox(height: 16),
            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _RouteButton(
              label: 'Push /category/$categoryId/product/p-001',
              tracked: "screenName: 'category/$categoryId/product/p-001'",
              onTap: () => context.push('/category/$categoryId/product/p-001'),
            ),
            const SizedBox(height: 8),
            _RouteButton(
              label: 'Push /category/$categoryId/product/p-002',
              tracked: "screenName: 'category/$categoryId/product/p-002'",
              onTap: () => context.push('/category/$categoryId/product/p-002'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoRouterProductScreen extends StatelessWidget {
  final String categoryId;
  final String productId;

  const _GoRouterProductScreen({
    required this.categoryId,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product: $productId')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoBox(
                "Route: /category/$categoryId/product/$productId\n"
                "→ screenName: 'category/$categoryId/product/$productId'\n"
                "→ displayName: '${productId[0].toUpperCase()}${productId.substring(1)}'",
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('← Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoRouterSearchScreen extends StatelessWidget {
  final String query;

  const _GoRouterSearchScreen({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search: "$query"')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoBox(
                "Route: /search?q=$query\n"
                "→ screenName: 'search'\n"
                "→ screenParams: {q: '$query'} (URI query extracted)",
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('← Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          height: 1.6,
        ),
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  final String label;
  final String tracked;
  final VoidCallback onTap;

  const _RouteButton({
    required this.label,
    required this.tracked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onTap,
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 2),
          child: Text(
            '→ $tracked',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green.shade700,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
