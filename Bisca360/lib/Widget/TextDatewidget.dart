import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextFieldDateWidget extends StatelessWidget {
  TextEditingController datePickerController;

  String labelName;

  Icon prefixIcon;

  TextInputAction textInputAction;

  TextInputType textInputType;

  String actionType;

  TextFieldDateWidget(this.datePickerController, this.labelName, this.prefixIcon, this.textInputAction, this.textInputType, this.actionType, {super.key});

  onTabPastDate({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(2023),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    datePickerController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }

  onTabFeatureDate({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2035),
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    datePickerController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelName';
        }
        return null;
      },
      controller: datePickerController,
      style: const TextStyle(
        fontSize: 15,
      ),
      textInputAction: textInputAction,
      keyboardType: textInputType,
      readOnly: true,
      onChanged: (value) => {if (value.isNotEmpty) {}},
      onTap: () => actionType == "PAST"
          ? onTabPastDate(context: context)
          : actionType == "FEATURE"
          ? onTabFeatureDate(context: context)
          : onTabFeatureDate(context: context),
      enableInteractiveSelection: false,
      decoration: InputDecoration(
          isDense: true,
          errorStyle: const TextStyle(
            fontSize: 10,
            color: Colors.redAccent,
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.0),
          ),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 1.0), gapPadding: 1),
          prefixIcon: prefixIcon,
          // suffixIcon: datePickerController.text.isNotEmpty
          //     ? IconButton(
          //   icon: const Icon(Icons.clear),
          //   splashRadius: 1,
          //   onPressed: () {
          //     datePickerController.clear();
          //   },
          // )
          //     : const Text(''),
          filled: true,
          fillColor: Colors.white,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          label: Text(
            labelName,
            style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
          )),
    );
  }
}