import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For JSON operations

class TaxItem {
  final String taxType;
  double taxPercentage;

  TaxItem(this.taxType, this.taxPercentage);
}

class TaxDialog extends StatefulWidget {
  final List<String> taxTypeResponseList;
  final TextEditingController taxController;

  TaxDialog({required this.taxTypeResponseList, required this.taxController});

  @override
  _TaxDialogState createState() => _TaxDialogState();
}

class _TaxDialogState extends State<TaxDialog> {
  late List<bool> _checkedItems;
  late List<TaxItem> _loadedTaxItems;
  Map<String, double> _taxJson = {};

  @override
  void initState() {
    super.initState();
    _initializeCheckedItems();
  }

  void _initializeCheckedItems() {
    _checkedItems = List<bool>.filled(widget.taxTypeResponseList.length, false);
    _loadedTaxItems = [];

    if (widget.taxController.text.isNotEmpty) {
      try {
        Map<String, dynamic> json = jsonDecode(widget.taxController.text);
        for (int i = 0; i < widget.taxTypeResponseList.length; i++) {
          String key = widget.taxTypeResponseList[i];
          if (json.containsKey(key)) {
            _checkedItems[i] = true;
            _loadedTaxItems.add(TaxItem(key, json[key].toDouble()));
          }
        }
      } catch (e) {
        // Handle JSON parsing error
        print('Error parsing JSON: $e');
      }
    }
  }

  void showTaxDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Shop Tax'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: List.generate(widget.taxTypeResponseList.length, (index) {
                    String taxType = widget.taxTypeResponseList[index];
                    TextEditingController editTextController = TextEditingController(
                      text: _checkedItems[index] ? _loadedTaxItems.firstWhere((item) => item.taxType == taxType).taxPercentage.toString() : '',
                    );

                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(taxType),
                          value: _checkedItems[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _checkedItems[index] = value ?? false;
                              if (!_checkedItems[index]) {
                                _loadedTaxItems.removeWhere((item) => item.taxType == taxType);
                              } else {
                                _loadedTaxItems.add(TaxItem(taxType, double.tryParse(editTextController.text) ?? 0));
                              }
                            });
                          },
                        ),
                        Visibility(
                          visible: _checkedItems[index],
                          child: TextField(
                            controller: editTextController,
                            decoration: InputDecoration(
                              hintText: 'Value for $taxType',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              setState(() {
                                double taxValue = double.tryParse(text) ?? 0;
                                if (_loadedTaxItems.any((item) => item.taxType == taxType)) {
                                  _loadedTaxItems.firstWhere((item) => item.taxType == taxType).taxPercentage = taxValue;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the taxJson and taxController
                _taxJson = {};
                for (var item in _loadedTaxItems) {
                  if (item.taxPercentage != 0) {
                    _taxJson[item.taxType] = item.taxPercentage;
                  }
                }
                widget.taxController.text = jsonEncode(_taxJson);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showTaxDialog(context),
      child: Text('Select Tax'),
    );
  }
}
