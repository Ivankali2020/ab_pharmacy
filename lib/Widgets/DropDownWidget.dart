import 'package:flutter/material.dart';

class DropDownWidget<T> extends StatelessWidget {
  final T value;
  final List<T> options;
  final Function(T?) change;
  final String hint;
  final Widget Function(T) itemBuilder;

  DropDownWidget({
    required this.value,
    required this.options,
    required this.change,
    required this.hint,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          borderRadius: BorderRadius.circular(8),
          dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
          value: value,
          hint: Text(hint),
          onChanged: change,
          items: options.map((T option) {
            return DropdownMenuItem<T>(
              value: option,
              child: itemBuilder(option),
            );
          }).toList(),
        ),
      ),
    );
  }
}
