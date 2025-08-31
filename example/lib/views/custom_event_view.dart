import 'package:flutter/material.dart';
import 'package:wisetrack/wisetrack.dart';
import 'package:wisetrack_example/widgets/dropdown.dart';
import 'package:wisetrack_example/widgets/inputfield.dart';

import '../widgets/button.dart';

class CustomEventView extends StatefulWidget {
  const CustomEventView({super.key});

  @override
  State<CustomEventView> createState() => _CustomEventViewState();
}

class _CustomEventViewState extends State<CustomEventView> {
  final _formKey = GlobalKey<FormState>();
  String eventName = '';
  String eventParams = '';
  WTEventType selectedType = WTEventType.defaultEvent;

  void _onCreateEvent() {
    if (_formKey.currentState == null) return;
    if (!_formKey.currentState!.validate()) return;
    if (eventName.isEmpty) return;

    final paramTuples = eventParams.trim().split(',');
    final params = <String, EventParameter>{};
    for (var pt in paramTuples) {
      try {
        final keyValue = pt.trim().split('=');
        final key = keyValue[0];
        final value = keyValue[1];
        if (bool.tryParse(value) != null) {
          params[key] = EventParameter.boolean(bool.parse(value));
        } else if (int.tryParse(value) != null) {
          params[key] = EventParameter.number(int.parse(value));
        } else if (double.tryParse(value) != null) {
          params[key] = EventParameter.number(double.parse(value));
        } else {
          params[key] = EventParameter.dynamic(value);
        }
      } catch (_) {}
    }

    final event =
        selectedType == WTEventType.defaultEvent
            ? WTEvent.defaultEvent(
              name: eventName,
              params: params.isEmpty ? null : params,
            )
            : WTEvent.revenueEvent(
              name: eventName,
              currency: RevenueCurrency.USD,
              amount: 120000,
              params: params.isEmpty ? null : params,
            );

    WiseTrack.instance.logEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomInputField(
                  title: 'Event Name',
                  hint: 'Name ...',
                  onChanged: (p) => eventName = p,
                  validator:
                      (value) =>
                          (value ?? '').isEmpty
                              ? 'Event name is required'
                              : null,
                ),
              ),
              Expanded(
                child: CustomDropdown(
                  title: 'Event Type',
                  hint: 'Select Type..',
                  items: WTEventType.values,
                  initialItem: WTEventType.defaultEvent,
                  mapper: (et) => et.label.toUpperCase(),
                  onChanged: (p) => selectedType = p!,
                ),
              ),
            ],
          ),
          CustomInputField(
            title: 'Event Parameters',
            hint: 'key-1=123,\nkey-2=true,\nkey-3=salam',
            onChanged: (p) => eventParams = p,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),
          ContainedButton(
            title: '⚡️ Create Event',
            backgroundColor: Colors.deepPurpleAccent,
            onPressed: _onCreateEvent,
          ),
        ],
      ),
    );
  }
}
