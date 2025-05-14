import 'package:animated_custom_dropdown/custom_dropdown.dart' as c;
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? initialItem;
  final String Function(T) mapper;
  final String? hint;
  final void Function(T?)? onChanged;

  const CustomDropdown({
    required this.title,
    required this.items,
    required this.mapper,
    this.initialItem,
    this.hint,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        c.CustomDropdown<T>(
          hintText: hint ?? 'Select item',
          items: items,
          listItemBuilder: (context, item, isSelected, onItemSelect) =>
              Text(mapper(item)),
          headerBuilder: (context, selectedItem, enabled) =>
              Text(mapper(selectedItem)),
          initialItem: initialItem,
          onChanged: onChanged,
          decoration: c.CustomDropdownDecoration(
            closedFillColor: Theme.of(context).inputDecorationTheme.fillColor,
            expandedFillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
        ),
      ],
    );
  }
}
