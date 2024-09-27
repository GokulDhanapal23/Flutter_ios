import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:searchfield/searchfield.dart';

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
  CustomSearchField({
    required this.textEditingController,
    required this.hintText,
    required this.prefixIcon,
    this.enabled = true,
    required this.suggestions,
    this.initialValue,
    required this.onSelect,
    this.height = 45.0, // Default height
    this.validate = false,
    Key? key, required TextStyle hintTextStyle, required Icon suffixIcon,
  }) : super(key: key);

  static Widget buildSearchField(TextEditingController controller, String hintText, IconData? icon, List<SearchFieldListItem<String>> suggestions, Function(String) onSelect,bool validation) {
    return CustomSearchField(
      textEditingController: controller,
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.green),
      suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.green),
      suggestions: suggestions,
      initialValue: suggestions.isNotEmpty ? suggestions.first : null,
      onSelect: onSelect,
      hintTextStyle: TextStyle(color: Colors.black),
      validate: validation,
    );
  }
  @override
  Widget build(BuildContext context) {
    // Define the border radius
    final borderRadius = BorderRadius.circular(25); // Adjust the radius as needed
    return Container(
      height: height, // Set the height of the container
      child: SearchField<String>(
        validator: (value) {
          if (validate) {
            if (value == null || value.isEmpty) {
              return 'Please enter $hintText';
            }
          }
          return null; // No validation error
        },
        controller: textEditingController,
        // hint: hintText,
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
          prefixIcon: prefixIcon,
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
          // hintText: hintText,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          labelStyle: TextStyle(color: Colors.black),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12, // Adjust this value to give enough height
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}
