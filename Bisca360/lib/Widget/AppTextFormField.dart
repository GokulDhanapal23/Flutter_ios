import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFieldForm extends StatelessWidget {
  final TextEditingController textEditingController;
  final String labelName;
  final Icon prefixIcon;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final bool enabled;
  final bool validation;
  // final int maxLines;
  final TextAlignVertical textAlignVertical;

  AppTextFieldForm(this.textEditingController, this.labelName, this.prefixIcon, this.textInputAction, this.textInputType, this.enabled,this.validation, {super.key, required maxLines, required this.textAlignVertical});

  @override
  Widget build(BuildContext context) {
    // Define the border radius
    final borderRadius = BorderRadius.circular(25); // Adjust the radius as needed

    return TextFormField(
      validator: (value) {
        if (validation) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelName';
          } else {
            // return Validator.validate(labelName, value,textInputType);
          }
        } else {
          return null;
        }
      },
      enabled: enabled,
      controller: textEditingController,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      cursorColor: Colors.black,
      maxLines: null,
      textAlignVertical: textAlignVertical,
      decoration: InputDecoration(
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
        prefixIcon: prefixIcon,
        suffixIcon: textEditingController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          splashRadius: 1,
          onPressed: () {
            textEditingController.clear();
          },
        )
            : const Text(''),
        filled: true,
        fillColor: Colors.white,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        label: Text(
          labelName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
