import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomToggleSwitch extends StatelessWidget {
  final String title;
  final Function(bool) onChanged;
  final bool? initialValue;
  const CustomToggleSwitch({
    required this.title,
    required this.onChanged,
    this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        // color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          CupertinoSwitch(
            value: initialValue ?? false,
            onChanged: onChanged,
            activeTrackColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
