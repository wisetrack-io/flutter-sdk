import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';
import 'package:wisetrack_example/tracking_observer.dart';
import 'package:wisetrack_example/widgets/button.dart';

import 'go_router_demo.dart';
import 'mixin_demo.dart';
import 'plain_nav_demo.dart';

class ScreenTrackingHubScreen extends StatefulWidget {
  const ScreenTrackingHubScreen({super.key});

  @override
  State<ScreenTrackingHubScreen> createState() =>
      _ScreenTrackingHubScreenState();
}

class _ScreenTrackingHubScreenState extends State<ScreenTrackingHubScreen> {
  final _manualLog = ValueNotifier<List<String>>([]);

  void _trackManual(
    String name,
    WTScreenType type, {
    String? displayName,
    Map<String, WTParam>? params,
  }) {
    WiseTrack.instance.trackScreen(
      WTScreen(name, type, displayName: displayName, params: params),
    );
    _manualLog.value = ['✅ $name (${type.name})', ..._manualLog.value.take(9)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Tracking Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Live auto-track log ─────────────────────────────────────
          _SectionCard(
            title: '📋 Auto-Tracked Events',
            subtitle:
                'Events recorded by WTNavigatorObserver added to MaterialApp '
                'in main.dart. Navigate to any screen to see it here.',
            child: ValueListenableBuilder<List<String>>(
              valueListenable: screenEventLog,
              builder: (_, events, __) {
                if (events.isEmpty) {
                  return const Text(
                    'No events yet — navigate to screens below.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      events
                          .take(8)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          )
                          .toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Auto tracking — Plain Navigator ────────────────────────
          _SectionCard(
            title: '🤖 Auto Tracking — Plain Navigator',
            subtitle:
                'WTNavigatorObserver intercepts push/pop/replace automatically '
                'without any per-screen setup. Demonstrates named routes, URI '
                'query params, unnamed routes (class-name fallback), Map args, '
                'dialogs, and bottom sheets.',
            child: OutlineButton(
              title: 'Open Plain Navigator Demo',
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: '/screen-tracking/plain-nav',
                      ),
                      builder: (_) => const PlainNavDemoScreen(),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Auto tracking — Go Router ──────────────────────────────
          _SectionCard(
            title: '🔀 Auto Tracking — Go Router',
            subtitle:
                'Pass WTNavigatorObserver to GoRouter(observers: [...]). '
                'Works transparently — route names are parsed as URIs, '
                'path segments and query params are extracted automatically.',
            child: OutlineButton(
              title: 'Open Go Router Demo',
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: '/screen-tracking/go-router',
                      ),
                      builder: (_) => const GoRouterDemoApp(),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Manual Tracking ────────────────────────────────────────
          _SectionCard(
            title: '✋ Manual Tracking',
            subtitle:
                'Call WiseTrack.instance.trackScreen(WTScreen(...)) directly. '
                'Full control over name, type, displayName, and params.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                OutlineButton(
                  title: 'Track "home" — page',
                  onPressed:
                      () => _trackManual(
                        'home',
                        WTScreenType.page,
                        displayName: 'Home',
                      ),
                ),
                const SizedBox(height: 8),
                OutlineButton(
                  title: 'Track "checkout" — page + params',
                  onPressed:
                      () => _trackManual(
                        'checkout',
                        WTScreenType.page,
                        displayName: 'Checkout',
                        params: {
                          'items': WTParam.number(3),
                          'promo': WTParam.boolean(true),
                          'currency': WTParam.string('USD'),
                        },
                      ),
                ),
                const SizedBox(height: 8),
                OutlineButton(
                  title: 'Track "confirm_dialog" — dialog',
                  onPressed:
                      () => _trackManual(
                        'confirm_dialog',
                        WTScreenType.dialog,
                        displayName: 'Confirm Purchase',
                      ),
                ),
                const SizedBox(height: 8),
                OutlineButton(
                  title: 'Track "filter_sheet" — bottomSheet + params',
                  onPressed:
                      () => _trackManual(
                        'filter_sheet',
                        WTScreenType.bottomSheet,
                        displayName: 'Filter Options',
                        params: {'tab': WTParam.string('price')},
                      ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<List<String>>(
                  valueListenable: _manualLog,
                  builder: (_, log, __) {
                    if (log.isEmpty) {
                      return const Text(
                        'Tap buttons above to send manual track events.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          log
                              .map(
                                (e) => Text(
                                  e,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )
                              .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── WTScreenTrackMixin ─────────────────────────────────────
          _SectionCard(
            title: '🧩 WTScreenTrackMixin',
            subtitle:
                'Per-widget tracking via RouteAware. Override screenName, '
                'screenDisplayName, and screenParams. Fires on didPush and '
                'didPopNext automatically — no observer required per-screen.',
            child: OutlineButton(
              title: 'Open Mixin Demo Screen',
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MixinDemoScreen()),
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
