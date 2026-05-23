import 'package:flutter/material.dart';

/// Demonstrates WTNavigatorObserver auto-tracking with plain Flutter Navigator.
///
/// Each scenario shows a different route configuration and what WTNavigatorObserver
/// resolves as the screen name.
class PlainNavDemoScreen extends StatelessWidget {
  const PlainNavDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plain Navigator Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(
            'WTNavigatorObserver is active on the root MaterialApp. '
            'Every push below is tracked automatically — check the hub screen '
            'log or your device console for the event.',
          ),
          const SizedBox(height: 12),

          // ── 1. Simple named route ──────────────────────────────────
          _ScenarioCard(
            icon: '🏷️',
            title: 'Named Route',
            tracked: "name: 'products'",
            description:
                "RouteSettings(name: '/products')\n"
                "→ WTNavigatorObserver strips leading '/' → screenName: 'products'",
            button: _DemoButton(
              label: 'Push /products',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/products'),
                      builder:
                          (_) => const _DemoScreen(
                            title: 'Products',
                            detail:
                                "RouteSettings(name: '/products')\n"
                                "→ screenName: 'products'\n"
                                "→ displayName: 'Products'",
                          ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 2. Named route + URI query params ─────────────────────
          _ScenarioCard(
            icon: '🔗',
            title: 'Named Route + URI Query Params',
            tracked: "name: 'products', params: {category, sort}",
            description:
                "RouteSettings(name: '/products?category=electronics&sort=price')\n"
                "→ URI parsed: screenName: 'products'\n"
                "→ screenParams: {category: 'electronics', sort: 'price'}",
            button: _DemoButton(
              label: 'Push /products?category=electronics&sort=price',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: '/products?category=electronics&sort=price',
                      ),
                      builder:
                          (_) => const _DemoScreen(
                            title: 'Electronics',
                            detail:
                                "RouteSettings(name: '/products?category=electronics&sort=price')\n"
                                "→ screenName: 'products'\n"
                                "→ params: {category: 'electronics', sort: 'price'}",
                          ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 3. Path with ID segment ────────────────────────────────
          _ScenarioCard(
            icon: '🔢',
            title: 'Path with ID Segment',
            tracked: "name: 'user/42/profile', displayName: 'Profile'",
            description:
                "RouteSettings(name: '/user/42/profile')\n"
                "→ screenName: 'user/42/profile'\n"
                "→ displayName: 'Profile' (last meaningful non-ID segment)",
            button: _DemoButton(
              label: 'Push /user/42/profile',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/user/42/profile'),
                      builder:
                          (_) => const _DemoScreen(
                            title: 'User Profile',
                            detail:
                                "RouteSettings(name: '/user/42/profile')\n"
                                "→ screenName: 'user/42/profile'\n"
                                "→ displayName: 'Profile'",
                          ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 4. Unnamed route (class name fallback) ────────────────
          _ScenarioCard(
            icon: '📄',
            title: 'Unnamed Route — Class Name Fallback',
            tracked: "name: '_ProductDetailPage' (widget class name)",
            description:
                "No RouteSettings.name set.\n"
                "→ WTNavigatorObserver extracts widget class name from runtimeType:\n"
                "   MaterialPageRoute<_ProductDetailPage> → '_ProductDetailPage'",
            button: _DemoButton(
              label: 'Push unnamed (no RouteSettings)',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      // No settings.name — triggers class-name fallback
                      builder: (_) => const _ProductDetailPage(),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 5. Route with Map arguments ───────────────────────────
          _ScenarioCard(
            icon: '📦',
            title: 'Route with Map Arguments',
            tracked: "name: 'order-summary', params from args map",
            description:
                "RouteSettings(name: '/order-summary', arguments: {'user_id': '42', ...})\n"
                "→ Map arguments extracted as screenParams automatically.",
            button: _DemoButton(
              label: 'Push /order-summary with Map args',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: '/order-summary',
                        arguments: {
                          'user_id': '42',
                          'promo': true,
                          'amount': 120.0,
                        },
                      ),
                      builder:
                          (_) => const _DemoScreen(
                            title: 'Order Summary',
                            detail:
                                "RouteSettings arguments: {user_id: '42', promo: true, amount: 120.0}\n"
                                "→ Extracted as screenParams automatically.",
                          ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 6. Dialog (PopupRoute) ─────────────────────────────────
          _ScenarioCard(
            icon: '💬',
            title: 'Dialog — PopupRoute (trackDialogs: true)',
            tracked: "type: dialog (WTScreenType.dialog)",
            description:
                "showDialog() → Flutter creates a PopupRoute.\n"
                "WTNavigatorObserver detects PopupRoute and sets type = dialog.\n"
                "Requires trackDialogs: true in WTScreenTrackingConfig.",
            button: _DemoButton(
              label: 'Show Dialog',
              onTap:
                  () => showDialog(
                    context: context,
                    routeSettings: const RouteSettings(name: '/confirm-dialog'),
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Confirm Purchase'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'This dialog is tracked as WTScreenType.dialog.',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Route name: '/confirm-dialog'\n"
                                "Type: dialog\n"
                                "trackDialogs must be true",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 7. Modal bottom sheet ──────────────────────────────────
          _ScenarioCard(
            icon: '📋',
            title: 'Modal Bottom Sheet',
            tracked: "type: bottomSheet (WTScreenType.bottomSheet)",
            description:
                "showModalBottomSheet() → Flutter creates a ModalBottomSheetRoute.\n"
                "WTNavigatorObserver automatically detects this and sets type = bottomSheet.",
            button: _DemoButton(
              label: 'Show Bottom Sheet',
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    routeSettings: const RouteSettings(name: '/filter-sheet'),
                    builder: (_) => const _FilterSheet(),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 8. excludedScreens ────────────────────────────────────
          _ScenarioCard(
            icon: '🚫',
            title: 'excludedScreens — Suppressed Route',
            tracked: "NOT tracked (name is in excludedScreens set)",
            description:
                "RouteSettings(name: '/internal/debug')\n"
                "→ If '/internal/debug' is in excludedScreens config,\n"
                "   WTNavigatorObserver skips it silently.",
            button: _DemoButton(
              label: 'Push /internal/debug (excluded)',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/internal/debug'),
                      builder:
                          (_) => const _DemoScreen(
                            title: 'Internal Debug',
                            detail:
                                "This route is in excludedScreens → NOT tracked.\n"
                                "Add '/internal/debug' to WTScreenTrackingConfig.excludedScreens.",
                          ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // ── 9. screenDataProvider override ────────────────────────
          _ScenarioCard(
            icon: '⚙️',
            title: 'screenDataProvider — Custom Name Override',
            tracked: "name: 'product_detail' (overridden from '/secret/123')",
            description:
                "Configure WTScreenTrackingConfig.screenDataProvider callback.\n"
                "Return a WTScreenDataProvider to override name/displayName/params\n"
                "for any route — highest priority in resolution chain.",
            button: _DemoButton(
              label: 'Push /secret/123 (see screenDataProvider example)',
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/secret/123'),
                      builder:
                          (_) => const _DemoScreen(
                            title: 'Product Detail (overridden)',
                            detail:
                                "Raw route: '/secret/123'\n"
                                "With screenDataProvider:\n"
                                "  return WTScreenDataProvider(\n"
                                "    screenName: 'product_detail',\n"
                                "    screenDisplayName: 'Product Detail',\n"
                                "    screenParams: {'id': '123'},\n"
                                "  );",
                          ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Internal demo screens ───────────────────────────────────────────────────

class _DemoScreen extends StatelessWidget {
  final String title;
  final String detail;

  const _DemoScreen({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'This screen view was auto-tracked by WTNavigatorObserver.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('← Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Named class so WTNavigatorObserver can extract the class name as fallback
class _ProductDetailPage extends StatelessWidget {
  const _ProductDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No RouteSettings.name was set.\n\n'
                  'WTNavigatorObserver falls back to runtimeType:\n'
                  'MaterialPageRoute<_ProductDetailPage>\n'
                  '→ screenName: "_ProductDetailPage"',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('← Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'type: bottomSheet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "route: '/filter-sheet'\ntracked as WTScreenType.bottomSheet",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const Divider(height: 24),
          const Text('• Price Range'),
          const SizedBox(height: 4),
          const Text('• Rating (4★ and above)'),
          const SizedBox(height: 4),
          const Text('• In Stock Only'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade800,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String icon;
  final String title;
  final String tracked;
  final String description;
  final Widget button;

  const _ScenarioCard({
    required this.icon,
    required this.title,
    required this.tracked,
    required this.description,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Tracked → $tracked',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade800,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            button,
          ],
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DemoButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
