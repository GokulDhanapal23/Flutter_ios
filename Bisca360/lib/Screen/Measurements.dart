import 'dart:convert';

import 'package:bisca360/Request/MeasurementRequest.dart';
import 'package:bisca360/Response/Measurementresponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ApiService/Apis.dart';
import '../Service/LoginService.dart';
import '../Widget/AppTextFormField.dart';

class Measurements extends StatefulWidget {
  const Measurements({super.key});

  @override
  State<Measurements> createState() => _MeasurementsState();
}

class _MeasurementsState extends State<Measurements> {
  late List<MeasurementResponse> measurements;
  late List<MeasurementResponse> shopUnits = [];
  late List<MeasurementResponse> filteredUnits = [];
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _measurementNameController = TextEditingController();
  final _measurementCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSearching = false;
  @override
  void initState() {
    measurements = [];
    getAllMeasurements();
    super.initState();
  }

  void _filterShops(String query) {
    final filtered = measurements.where((units) {
      return units.measurementName
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          units.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredUnits = filtered;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredUnits = measurements; // Reset to all shops
    });
  }

  void _saveForm(var id) {
    String measurementCode = _measurementCodeController.text.isNotEmpty
        ? _measurementCodeController.text
        : '';
    String measurementName = _measurementNameController.text.isNotEmpty
        ? _measurementNameController.text
        : '';
    String description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : '';
    bool active = true;
    MeasurementRequest measurementRequest = new MeasurementRequest(
        measurementCode: measurementCode,
        measurementName: measurementName,
        description: description,
        active: active,
        id: id);
    saveMeasurement(measurementRequest, context);
  }

  getAllMeasurements() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getAllMeasurements),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          measurements =
              data.map((item) => MeasurementResponse.fromJson(item)).toList();
          print('measurements: $measurements.toString');
        });
      } else {
        print('Failed to load measurements');
      }
    } catch (e) {
      print('Error fetching measurements: $e');
    }
  }

  Future<bool> getChangeMeasurementStatus(var id, bool status) async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(
            '${Apis.changeMeasurementsStatus}?measurementId=$id&status=$status'),
        headers: Apis.getHeaders(),
      );
      if (response.statusCode == 200) {
        LoginService.showBlurredSnackBar(
            context, 'Measurement Status Changed Successfully',
            type: SnackBarType.success);
        print('Success Change Measurement Status');
        return true;
      } else {
        LoginService.showBlurredSnackBar(
            context, 'Measurement to change Status',
            type: SnackBarType.error);
        print('Failed to Change Measurement Status ');
        return false;
      }
    } catch (e) {
      print('Error fetching Change Measurement Status: $e');
      return false;
    }
  }

  Future<void> saveMeasurement(
      MeasurementRequest request, BuildContext context) async {
    try {
      var res = await Apis.getClient().post(Uri.parse(Apis.saveMeasurement),
          body: jsonEncode(request.toJson()), headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
        Navigator.of(context).pop();
        clear();
        print("Success");
      } else {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void clear() {
    _measurementNameController.clear();
    _measurementCodeController.clear();
    _descriptionController.clear();
  }

  void _showAddMeasurementDialog(
      BuildContext context, MeasurementResponse? measurement) {
    var id = 0;
    if (measurement != null) {
      _measurementNameController.text = measurement.measurementName;
      _measurementCodeController.text = measurement.measurementCode;
      _descriptionController.text = measurement.description;
      id = measurement.id;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Add Measurement')),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppTextFieldForm(
                    _measurementCodeController,
                    "Measurements Code",
                    const Icon(Icons.abc, color: Colors.green),
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
                    const Icon(Icons.ad_units_outlined, color: Colors.green),
                    TextInputAction.next,
                    TextInputType.text,
                    true,
                    true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                  const SizedBox(height: 10),
                  AppTextFieldForm(
                    _descriptionController,
                    "Description",
                    const Icon(Icons.file_present, color: Colors.green),
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
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                clear();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child:
                  const Text('Submit', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _saveForm(id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill in all fields correctly')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        title: _isSearching
            ? TextField(
                textInputAction: TextInputAction.next,
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  _filterShops(value);
                },
              )
            : const Text(
                'Measurements',
                style: TextStyle(color: Colors.white),
              ),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: _stopSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _startSearch,
                ),
          IconButton(
              onPressed: () {
                _showAddMeasurementDialog(context, null);
              },
              icon: Icon(CupertinoIcons.plus_app_fill, color: Colors.white)),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showAddMeasurementDialog(context);
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      body: filteredUnits.isEmpty && measurements.isEmpty
          ? const Center(
              child: Text(
                'No Units',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    child: measurements.isEmpty
                        ? Center(child: Text('No Units'))
                        : ListView.builder(
                            itemCount: filteredUnits.isEmpty
                                ? measurements.length
                                : filteredUnits.length,
                            itemBuilder: (context, index) {
                              final unit = filteredUnits.isEmpty
                                  ? measurements[index]
                                  : filteredUnits[index];
                              bool isActive = unit.active;
                              return Card(
                                color: Colors.white,
                                shadowColor: Colors.green,
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(5),
                                  title: Text(
                                    '${index + 1}. Name: ${unit.measurementName}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Description: ${unit.description}',
                                          style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.indigoAccent),
                                        onPressed: () {
                                          _showAddMeasurementDialog(
                                              context, unit);
                                        },
                                      ),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          activeColor: Colors.indigoAccent,
                                          value: isActive,
                                          onChanged: (value) async {
                                            if (await getChangeMeasurementStatus(
                                                unit.id, value)) {
                                              setState(() {
                                                unit.active = value;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
