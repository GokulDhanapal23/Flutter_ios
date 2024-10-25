import 'dart:convert';

import 'package:bisca360/Request/ProjectRequest.dart';
import 'package:bisca360/Response/ProcessStatusResponse.dart';
import 'package:bisca360/Response/ProjectResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

import '../ApiService/Apis.dart';
import '../Service/LoginService.dart';
import '../Widget/AppTextFormField.dart';
import '../Widget/CustomSearchfieldWidget.dart';

class CreateProject extends StatefulWidget {
  final ProjectResponse? projectResponse;
  const CreateProject({super.key, required this.projectResponse});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectAreaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _projectOwnerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _projectStatusController = TextEditingController();
  final TextEditingController _contractAmtController = TextEditingController();
  final TextEditingController _advanceAmtController = TextEditingController();
  bool _isLoading = false;
  bool _isChecked = false;
  late List<ProcessStatusResponse> processStatusResponse = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<SearchFieldListItem<String>> get _projectAccessItems {
    return processStatusResponse
        .map((status) => SearchFieldListItem<String>(status.statusName))
        .toList();
  }

  Future<void> getAllProcessStatus() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getAllProcessStatus),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          processStatusResponse = data.map((item) => ProcessStatusResponse.fromJson(item)).toList();
        });
        print('ProcessStatusResponse : $processStatusResponse');
      } else {
        print('Failed to load ProcessStatusResponse');
      }
    } catch (e) {
      print('Error fetching ProcessStatusResponse: $e');
    }
  }
  Future<void> saveProject(ProjectRequest projectRequest, BuildContext context) async {
    try {
      var res = await Apis.getClient().post(
          Uri.parse(Apis.saveProject),
          body :jsonEncode(projectRequest.toJson()),
          headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status']== "OK") {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.success);
        Navigator.of(context).pop();
        print("Success");
      } else {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String _getStatusCode() {
    String  statusCode = '';
    if (_projectStatusController.text.isNotEmpty) {
      for (ProcessStatusResponse processStatus in processStatusResponse) {
        if (_projectStatusController.text == processStatus.statusName) {
          statusCode = processStatus.statusCode;
          break;
        }
      }
    }
    return statusCode;
  }
  void _saveForm(){
    var id =0;
    if(widget.projectResponse != null) {
      id = widget.projectResponse!.id;
    }
    bool contract = _isChecked;
    double advanceAmount;
    double contractAmount;
    if(contract){
       advanceAmount = _advanceAmtController.text.isNotEmpty ? double.parse(_advanceAmtController.text) : 0.0;
       contractAmount = _contractAmtController.text.isNotEmpty ? double.parse(_contractAmtController.text) : 0.0;
    }else{
      advanceAmount = 0.0;
      contractAmount = 0.0;
    }
    String description = _descriptionController.text.isNotEmpty ? _descriptionController.text : '';
    double latitude = 0;
    String locationInfo = _projectAreaController.text.isNotEmpty ? _projectAreaController.text : '';
    double longitude = 0;
    String? ownerMobileNumber = _mobileNumberController.text.isNotEmpty ? _mobileNumberController.text : '';
    String siteArea = _projectAreaController.text.isNotEmpty ? _projectAreaController.text : '';
    String siteName = _projectNameController.text.isNotEmpty ? _projectNameController.text : '';
    String siteOwner = _projectOwnerNameController.text.isNotEmpty ? _projectOwnerNameController.text : '';
    String siteStatusCode =_getStatusCode();

    ProjectRequest projectRequest = ProjectRequest(
      id: id,
        advanceAmount: advanceAmount,
        contract: contract,
        contractAmount: contractAmount,
        description: description,
        latitude: latitude,
        locationInfo: locationInfo,
        longitude: longitude,
        siteArea: siteArea,
        siteName: siteName,
        siteOwner: siteOwner,
        siteStatusCode: siteStatusCode,
        ownerMobileNumber: ownerMobileNumber);
    saveProject(projectRequest,context);
  }

  @override
  void initState() {
    if(widget.projectResponse != null){
      _projectNameController.text = widget.projectResponse!.siteName;
      _projectAreaController.text = widget.projectResponse!.siteArea;
      _descriptionController.text = widget.projectResponse!.description;
      _projectOwnerNameController.text = widget.projectResponse!.siteOwner;
      _mobileNumberController.text = widget.projectResponse!.ownerMobileNumber.toString();
      _projectStatusController.text = widget.projectResponse!.siteStatusName;
    }
    getAllProcessStatus();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.green,
        title:  Text(widget.projectResponse != null ? 'Update Project' : 'Create Project', style: TextStyle(color: Colors.white)),
        elevation: 1,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                AppTextFieldForm(
                  _projectNameController,
                  "Project Name",
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
                  _projectAreaController,
                  "Project Area",
                  const Icon(Icons.map, color: Colors.green),
                  TextInputAction.next,
                  TextInputType.text,
                  true,
                  true,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 10),
                AppTextFieldForm(
                  _projectOwnerNameController,
                  "Project Owner Name",
                  const Icon(Icons.person, color: Colors.green),
                  TextInputAction.next,
                  TextInputType.text,
                  true,
                  true,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                ),
              const SizedBox(height: 10),
                AppTextFieldForm(
                  _mobileNumberController,
                  "Mobile Number",
                  const Icon(Icons.phone_android, color: Colors.green),
                  TextInputAction.next,
                  TextInputType.number,
                  true,
                  false,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                ),

                Row(
                  children: [
                    Text('Contract:  '),
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                if(_isChecked)...[ Row(
                  children: [
                    Expanded(
                      child: AppTextFieldForm(
                        _contractAmtController,
                        "Contract Amount",
                        const Icon(Icons.credit_card, color: Colors.green),
                        TextInputAction.next,
                        TextInputType.number,
                        true,
                        _isChecked ? true : false,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.center,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: AppTextFieldForm(
                        _advanceAmtController,
                        "Advance Amount",
                        const Icon(Icons.credit_card, color: Colors.green),
                        TextInputAction.next,
                        TextInputType.number,
                        true,
                        false,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.center,
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 10),
                // CustomDropdownButton(
                //   textEditingController: _shopTypeController,
                //   hintText: 'Shop Type',
                //   prefixIcon: Icon(Icons.shop, color: Colors.green),
                //   items: _shopTypes,
                //   selectedValue: selectedValue,
                //   onSelect: handleSelect,
                //   validate: true, // Set true if you want validation
                // ),

                CustomSearchField.buildSearchField(_projectStatusController, 'Select Project Status', Icons.shop, _projectAccessItems, (String value) {},true,true,widget.projectResponse == null? true:false,true),
                const SizedBox(height: 10),
                AppTextFieldForm(
                  _descriptionController,
                  "Description",
                  const Icon(Icons.description, color: Colors.green),
                  TextInputAction.done,
                  TextInputType.text,
                  true,
                  false,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          _saveForm();
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields correctly')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        widget.projectResponse == null ? 'Create' : 'Update',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
