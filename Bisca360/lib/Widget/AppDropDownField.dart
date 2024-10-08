import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdownButton extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final Icon prefixIcon;
  final bool enabled;
  final List<String> items; // Changed to a list of strings
  final String? selectedValue;
  final ValueChanged<String?> onSelect;
  final double height;
  final bool validate;

  CustomDropdownButton({
    required this.textEditingController,
    required this.hintText,
    required this.prefixIcon,
    this.enabled = true,
    required this.items,
    this.selectedValue,
    required this.onSelect,
    this.height = 45.0,
    this.validate = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(25);

    return Container(
      height: height,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Row(
            children: [
              prefixIcon,
              SizedBox(width: 8),
              Text(
                hintText,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 14),
            ),
          ))
              .toList(),
          value: selectedValue,
          onChanged: enabled
              ? (value) {
            textEditingController.text = value!;
            onSelect(value);
          }
              : null,
          buttonStyleData: ButtonStyleData(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: validate && (selectedValue == null)
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            // borderRadius: borderRadius,
            padding: EdgeInsets.zero,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
        ),
      ),
    );
  }
}
