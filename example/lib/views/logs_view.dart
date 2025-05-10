import 'dart:async';

import 'package:flutter/material.dart';

class LogsView extends StatelessWidget {
  final List<String> logs;
  final StreamController<List<String>> logStreamController;
  const LogsView({
    required this.logs,
    required this.logStreamController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<List<String>>(
                  stream: logStreamController.stream,
                  initialData: logs,
                  builder: (context, snapshot) {
                    final logs = snapshot.data ?? [];
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        return Text(
                          logs[index],
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                      separatorBuilder:
                          (_, __) => Divider(color: Colors.grey.shade300),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
