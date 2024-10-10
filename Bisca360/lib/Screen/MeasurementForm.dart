import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Widget/AppTextFormField.dart';

class MeasurementForm extends StatefulWidget {
  @override
  _MeasurementFormState createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<MeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  final _measurementNameController = TextEditingController();
  final _measurementCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isChecked = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppTextFieldForm(
              _measurementCodeController,
              "Measurements Code",
              const Icon(Icons.home_work_outlined, color: Colors.green),
              TextInputAction.next,
              TextInputType.text,
              true,
              true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
            ),
            const SizedBox(height: 10),
            AppTextFieldForm(
              _measurementNameController,
              "Measurement Name",
              const Icon(Icons.map, color: Colors.green),
              TextInputAction.next,
              TextInputType.phone,
              true,
              true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
            ),
            const SizedBox(height: 10),
            AppTextFieldForm(
              _descriptionController,
              "Description",
              const Icon(Icons.person, color: Colors.green),
              TextInputAction.next,
              TextInputType.text,
              true,
              false,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
            ),
          ],
        ),
      ),
    );
  }

  void _saveForm() {
    setState(() {
      _isLoading = true;
    });

    // Simulate a save operation
    Future.delayed(Duration(seconds: 2), () {
      // After saving, you can close the dialog
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    });
  }
}