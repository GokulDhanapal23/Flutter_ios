import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

import '../Util/Validator.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final Icon prefixIcon;
  final bool enabled;
  final List<SearchFieldListItem<String>> suggestions;
  final SearchFieldListItem<String>? initialValue;
  final ValueChanged<String> onSelect;
  final double height; // Added height parameter
  final bool validate;
  final bool setInitialValue;
  final bool allowManualInput;

  CustomSearchField({
    required this.textEditingController,
    required this.hintText,
    required this.prefixIcon,
    required this.enabled,
    required this.suggestions,
    this.initialValue,
    required this.onSelect,
    this.height = 45.0, // Default height
    required this.validate,
    this.setInitialValue = false,
    this.allowManualInput = true,
    Key? key,
  }) : super(key: key) {
    // Set the initial value if provided
    //   if (setInitialValue && suggestions.isNotEmpty ) {
    //     textEditingController.text = suggestions.first.searchKey;
    //   }
  }

  static Widget buildSearchField(
      TextEditingController controller,
      String hintText,
      IconData? icon,
      List<SearchFieldListItem<String>> suggestions,
      Function(String) onSelect,
      bool enabled,
      bool validation,
      bool setInitialValue,
      bool allowManualInput,
      ) {
    return CustomSearchField(
      textEditingController: controller,
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.green),
      suggestions: suggestions,
      initialValue: suggestions.isNotEmpty &&  setInitialValue ? suggestions.first : null,
      enabled: enabled,
      onSelect: onSelect,
      validate: validation,
      setInitialValue: setInitialValue,
      allowManualInput: allowManualInput,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(25); // Adjust the radius as needed
    return Container(
      height: height, // Set the height of the container
      child: SearchField<String>(
        validator: (value) {
          if (validate) {
            if (value == null || value.isEmpty) {
              print('Please enter $hintText');
              return 'Please enter $hintText';
            }
          }
          return null;
        },
        controller: textEditingController,
        inputType: allowManualInput ? TextInputType.text : TextInputType.none,
        dynamicHeight: true,
        maxSuggestionBoxHeight: 200,
        initialValue: initialValue,
        suggestions: suggestions,
        suggestionState: Suggestion.expand,
        enabled: enabled,
        onSuggestionTap: (selectedItem) {
          if (selectedItem != null) {
            textEditingController.text = selectedItem.searchKey;
            textEditingController.selection = TextSelection.fromPosition(
              TextPosition(offset: textEditingController.text.length),
            );
            onSelect(selectedItem.searchKey);
            FocusScope.of(context).unfocus();
          }
        },
        textInputAction: TextInputAction.done,
        searchInputDecoration: SearchInputDecoration(
          labelText: hintText,
            prefixIcon: prefixIcon ?? null,
          contentPadding: prefixIcon != null
              ? const EdgeInsets.symmetric(vertical: 12, horizontal: 12)
              : const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.green),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          errorStyle: const TextStyle(
            fontSize: 10,
            color: Colors.redAccent,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: borderRadius,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            borderRadius: borderRadius,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            borderRadius: borderRadius,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          labelStyle: TextStyle(color: Colors.black),
          // contentPadding: EdgeInsets.symmetric(
          //   vertical: 12,
          //   horizontal: 12,
          // ),
        ),
      ),
    );
  }
}
