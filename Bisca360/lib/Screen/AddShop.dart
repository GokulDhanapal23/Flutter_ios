import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bisca360/Response/ProjectResponse.dart';
import 'package:bisca360/Response/TaxResponse.dart';
import 'package:bisca360/Service/ImageService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:searchfield/searchfield.dart';
import '../Response/OwnerTaxResponse.dart';
import '../Service/ShopService.dart';
import '../Widget/AppDropDownField.dart';
import '../Widget/AppTextFormField.dart';
import '../Request/ShopRequest.dart';
import '../Response/ShopResponse.dart';
import '../Widget/CustomSearchfieldWidget.dart';
import '../ApiService/Apis.dart';

import 'package:flutter/foundation.dart';



class AddShop extends StatefulWidget {
  final Shopresponse? shopResponse;
  const AddShop({super.key, required this.shopResponse});

  @override
  State<AddShop> createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopTypeController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _priceRoundingController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late List<Shopresponse> shopResponses = [];
  late List<ProjectResponse> projectResponse = [];
  List<TaxResponse> taxResponse = [];
  late List<bool> _checkedItems;
  bool _isEditMode = true;
  File? imageFile;
  String? selectedValue;

  final List<String> _shopTypes = ['Hotel',  'Saloon','Hardware and Tools', 'Packing', 'Stationary'];
  final List<String> _PrRound = ['Round Up', 'Round Off'];
  String? _selectedValue;
  bool? _selectedBooleanValue = false;
  bool? _isIncludedBooleanValue = false;
  Uint8List? _imageData;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> getAllShops() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getAllShop),
        headers: Apis.getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopResponses = data.map((item) => Shopresponse.fromJson(item)).toList();
        });
      } else {
        print('Failed to load shops');
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    if (widget.shopResponse != null) {
      _loadImage(widget.shopResponse!.id!);
      _isEditMode =false;
      _shopNameController.text = widget.shopResponse!.shopName;
      _shopTypeController.text = widget.shopResponse!.shopType;
      _mobileNumberController.text = widget.shopResponse!.contactNumber.toString();
      _gstController.text = widget.shopResponse!.gstNumber;
      _priceRoundingController.text = widget.shopResponse!.rounding.toString();
      _addressController.text = widget.shopResponse!.address;
      _descriptionController.text = widget.shopResponse!.description;
      _selectedBooleanValue = widget.shopResponse!.taxEnable;
      _isIncludedBooleanValue= widget.shopResponse!.includedTax;
      if (widget.shopResponse != null) {
        _taxController.text = formatTaxRequest(widget.shopResponse!.listOwnerTaxResponse);
      }
    }
    getTax();
    getProjects();
  }
  String formatTaxResponses(List<OwnerTaxResponse>? taxResponses) {
    if (taxResponses == null || taxResponses.isEmpty) {
      return '';
    }
    String taxList = taxResponses
        .map((tax) => '${tax.taxType}: ${tax.taxPercentage}')
        .join(', ');
    return jsonEncode(taxList);
  }
  String formatTaxRequest(List<OwnerTaxResponse>? taxResponses) {
    if (taxResponses == null || taxResponses.isEmpty) {
      return '';
    }
    String taxList = taxResponses
        .map((tax) => '"${tax.taxType}": ${tax.taxPercentage}')
        .join(', ');
    String taxes = '{$taxList}';
    return taxes;
  }

  Future<void> _loadImage(int uid) async {
    String UID ='S$uid';
    final imageData = await ImageService.fetchImage(UID, 'profile');
    setState(() {
      _imageData = imageData;
    });
  }

  List<SearchFieldListItem<String>> get _shopTypeItems {
    return _shopTypes
        .map((shop) => SearchFieldListItem<String>(shop))
        .toList();
  }
  List<SearchFieldListItem<String>> get _rounding {
    return _PrRound
        .map((round) => SearchFieldListItem<String>(round))
        .toList();
  }
  List<SearchFieldListItem<String>> get _projectNames {
    return projectResponse.map((project) => SearchFieldListItem<String>(project.siteName)).toList();
  }
  int _getProjectId() {
    // getAllCategories(_shopNameController.text);
    int projectId = 0;
    if (_projectController.text.isNotEmpty) {
      for (ProjectResponse project in projectResponse) {
        if (_projectController.text == project.siteName) {
          projectId = project.id;
          break;
        }
      }
    }
    return projectId;
  }

  Future<void> getTax() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getTax),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(responseBody) as List<dynamic>;
          taxResponse = jsonList
              .map((json) => TaxResponse.fromJson(json as Map<String, dynamic>))
              .toList();
          print('Tax Response : $taxResponse');
        } else {
          print('Received empty response body.');
          taxResponse = []; // Set taxResponse to an empty list
        }
      } else {
        print('Failed to load tax: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching tax: $e');
    }
  }
  Future<void> getProjects( ) async {
    try {
      final url = Uri.parse(Apis.getProject);
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          projectResponse = data.map((item) => ProjectResponse.fromJson(item)).toList();
          print('projectResponse: $projectResponse');
        });
      } else {
        print('Failed to load Project Response');
      }
    } catch (e) {
      print('Error fetching Project Response: $e');
    }
  }


  void _saveForm() {
    setState(() {
      _isLoading = true;
    });
    String shopName = _shopNameController.text.isNotEmpty ? _shopNameController.text : '';
    String address = _addressController.text.isNotEmpty ? _addressController.text : '';
    String shopType = _shopTypeController.text.isNotEmpty ? _shopTypeController.text : '';
    String description = _descriptionController.text.isNotEmpty ? _descriptionController.text : '';
    String gst = _gstController.text.isNotEmpty ? _gstController.text : '';
    String rounding = _priceRoundingController.text.isNotEmpty ? _priceRoundingController.text : '';
    String taxes = '';
    var projectId = 0;
    if(_selectedBooleanValue==true){
      taxes = _taxController.text;
    }
    if(_projectController.text.isNotEmpty){
      projectId=_getProjectId();
    }
    ShopRequest shopRequest = ShopRequest(
        widget.shopResponse?.id ?? 0,
        _shopNameController.text,
        true,
        _addressController.text,
        int.tryParse(_mobileNumberController.text) ?? 0,
        _shopTypeController.text,
        _descriptionController.text,
        _selectedBooleanValue!,
        taxes,
        _gstController.text.isEmpty ? '' : _gstController.text,
        '',
        _priceRoundingController.text,
        projectId,
        '',
        _selectedBooleanValue! ? _isIncludedBooleanValue! : false,
        '[]'
    );
    ShopService.saveShop(shopRequest, context);

    setState(() {
      _isLoading = false;
    });

  }
  void handleSelect(String? value) {
    setState(() {
      selectedValue = value;
    });
    print('Selected: $value');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textSize = screenWidth * 0.03;
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
        title:  Text(widget.shopResponse != null ? 'Update Shop' : 'Add Shop', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 1,
        actions: [
          !_isEditMode
              ?  Container(
            margin: EdgeInsets.fromLTRB(0, 4, 10, 4),
                child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditMode =true;
                        });
                          },
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        ),
                        child: _isLoading
                          ? CircularProgressIndicator(color: Colors.green)
                          : Text(
                        _isEditMode ? '' : 'Edit',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
              )
              : Container(),
        ],
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
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _imageData != null
                            ? MemoryImage(_imageData!)
                            :const AssetImage('assets/user_png.png'),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                        iconSize: 24,
                          onPressed: () async {
                            Map<Permission, PermissionStatus> statuses = await [
                            Permission.storage, Permission.camera,
                          ].request();
                          if(statuses[Permission.camera]!.isGranted){
                            // _pickImage(context);
                          } else {
                          print('no permission provided');
                          }
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            AppTextFieldForm(
              _shopNameController,
              "Shop Name",
              const Icon(Icons.shop, color: Colors.green),
              TextInputAction.next,
              TextInputType.text,
              _isEditMode,
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
              TextInputType.phone,
              _isEditMode,
              true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
            ),
            const SizedBox(height: 10),
            AppTextFieldForm(
              _gstController,
              "GST Number",
              const Icon(Icons.numbers, color: Colors.green),
              TextInputAction.next,
              TextInputType.text,
              _isEditMode,
              false,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
            ),
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

            CustomSearchField.buildSearchField(_shopTypeController, 'Shop Type', Icons.shop, _shopTypeItems, (String value) {},_isEditMode,true,widget.shopResponse == null? true:false,false),
            const SizedBox(height: 10),
            CustomSearchField.buildSearchField(_projectController, 'Project', Icons.plagiarism_rounded, _projectNames, (String value) {},_isEditMode,false,widget.shopResponse == null? true:false,false),
            const SizedBox(height: 10),
            CustomSearchField.buildSearchField(_priceRoundingController, 'Price Rounding', Icons.attach_money_outlined, _rounding, (String value) {},_isEditMode,true,widget.shopResponse == null? true:false,false),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('GST Enabled:', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: RadioListTile<bool?>(
                    title:  Text('Yes',style: TextStyle(fontSize: textSize),),
                    value: true,

                    groupValue: _selectedBooleanValue,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedBooleanValue = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool?>(
                    title:  Text('No',style: TextStyle(fontSize: textSize),),
                    value: false,
                    groupValue: _selectedBooleanValue,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedBooleanValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            // Conditionally render the GST TextField
        if (_selectedBooleanValue == true) ...[
              const SizedBox(height: 5),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 10.0),
                          Icon(Icons.percent, color: Colors.green),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _taxController,
                              enabled: false,
                              decoration: const InputDecoration(
                                hintText: 'Select Shop Tax',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      if (taxResponse.isEmpty) {
                        getTax().then((_) {
                          _showTaxDialog(context);
                        });
                      } else {
                        _showTaxDialog(context);
                      }
                    },
                    iconSize: 24.0,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: 40.0, height: 60.0),
                  ),
                ],
              ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Included Tax Price', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: RadioListTile<bool?>(
                  title: const Text('Yes'),
                  value: true,
                  groupValue: _isIncludedBooleanValue,
                  onChanged: (bool? value) {
                    setState(() {
                      _isIncludedBooleanValue = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool?>(
                  title: const Text('No'),
                  value: false,
                  groupValue: _isIncludedBooleanValue,
                  onChanged: (bool? value) {
                    setState(() {
                      _isIncludedBooleanValue = value;
                    });
                  },
                ),
              ),
            ],
          ),
            ],
            const SizedBox(height: 10),
            AppTextFieldForm(
              _addressController,
              "Address",
              const Icon(Icons.location_on, color: Colors.green),
              TextInputAction.next,
              TextInputType.text,
              _isEditMode,
              true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
            ),
            const SizedBox(height: 10),
            AppTextFieldForm(
              _descriptionController,
              "Description",
              const Icon(Icons.description, color: Colors.green),
              TextInputAction.done,
              TextInputType.text,
              _isEditMode,
              false,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
            ),
            const SizedBox(height: 10),
            _isEditMode?
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
                    widget.shopResponse == null ? 'Save' : 'Update',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ): Row(),
          ],
        ),
    ),
      ),
    ),
    );
  }

  void _showTaxDialog(BuildContext context) {
    // Check if there's existing tax data in the shopResponse
    bool hasExistingData = widget.shopResponse != null && widget.shopResponse!.listOwnerTaxResponse.isNotEmpty;

    // Create a map of existing tax types and their values if available
    Map<String, String> existingTaxMap = {};
    if (hasExistingData) {
      for (var tax in widget.shopResponse!.listOwnerTaxResponse) {
        existingTaxMap[tax.taxType] = tax.taxPercentage.toString();
      }
    }

    // Use all tax types from taxResponse
    List<String> taxTypeResponseList = taxResponse
        .map((tax) => tax.taxType)
        .where((taxType) => taxType.isNotEmpty)
        .toList();

    // Initialize controllers and checked items
    Map<String, TextEditingController> controllers = {};
    List<bool> checkedItems = List<bool>.filled(taxTypeResponseList.length, false);

    // Populate controllers and checked items based on existing data
    for (int i = 0; i < taxTypeResponseList.length; i++) {
      String taxType = taxTypeResponseList[i];
      controllers[taxType] = TextEditingController();

      if (existingTaxMap.containsKey(taxType)) {
        controllers[taxType]?.text = existingTaxMap[taxType]!;
        checkedItems[i] = true; // Mark this taxType as checked
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Select Tax Type')),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(taxTypeResponseList.length, (index) {
                    String taxType = taxTypeResponseList[index];

                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(taxType),
                          value: checkedItems[index],
                          onChanged: (bool? value) {
                            setState(() {
                              checkedItems[index] = value ?? false;
                            });
                          },
                        ),
                        Visibility(
                          visible: checkedItems[index],
                          child: TextField(
                            controller: controllers[taxType],
                            decoration: InputDecoration(
                              hintText: 'Value for $taxType',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
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
                Map<String, String> selectedTaxesMap = {};
                for (int i = 0; i < taxTypeResponseList.length; i++) {
                  if (checkedItems[i]) {
                    String taxType = taxTypeResponseList[i];
                    String value = controllers[taxType]?.text ?? '';
                    selectedTaxesMap[taxType] = value;
                  }
                }
                String jsonString = jsonEncode(selectedTaxesMap);
                _taxController.text = jsonString;
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // final picker = ImagePicker();
  //
  // void showImagePicker(BuildContext context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (builder){
  //         return Card(
  //           child: Container(
  //               width: MediaQuery.of(context).size.width,
  //               height: MediaQuery.of(context).size.height/5.2,
  //               margin: const EdgeInsets.only(top: 8.0),
  //               padding: const EdgeInsets.all(12),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Expanded(
  //                       child: InkWell(
  //                         child: const Column(
  //                           children: [
  //                             Icon(Icons.image, size: 60.0,),
  //                             SizedBox(height: 12.0),
  //                             Text(
  //                               "Gallery",
  //                               textAlign: TextAlign.center,
  //                               style: TextStyle(fontSize: 16, color: Colors.black),
  //                             )
  //                           ],
  //                         ),
  //                         onTap: () {
  //                           _imgFromGallery();
  //                           Navigator.pop(context);
  //                         },
  //                       )),
  //                   Expanded(
  //                       child: InkWell(
  //                         child: const SizedBox(
  //                           child: Column(
  //                             children: [
  //                               Icon(Icons.camera_alt, size: 60.0,),
  //                               SizedBox(height: 12.0),
  //                               Text(
  //                                 "Camera",
  //                                 textAlign: TextAlign.center,
  //                                 style: TextStyle(fontSize: 16, color: Colors.black),
  //                               )
  //                             ],
  //                           ),
  //                         ),
  //                         onTap: () {
  //                           _imgFromCamera();
  //                           Navigator.pop(context);
  //                         },
  //                       ))
  //                 ],
  //               )),
  //         );
  //       }
  //   );
  // }
  // _imgFromGallery() async {
  //   await  picker.pickImage(
  //       source: ImageSource.gallery, imageQuality: 50
  //   ).then((value){
  //     if(value != null){
  //       _cropImage(File(value.path));
  //     }
  //   });
  // }
  //
  // _imgFromCamera() async {
  //   await picker.pickImage(
  //       source: ImageSource.camera, imageQuality: 50
  //   ).then((value){
  //     if(value != null){
  //       _cropImage(File(value.path));
  //     }
  //   });
  // }


  // _cropImage(File imgFile) async {
  //   try {
  //     final croppedFile = await ImageCropper().cropImage(
  //       sourcePath: imgFile.path,
  //       androidUiSettings: AndroidUiSettings(
  //         toolbarTitle: "Image Cropper",
  //         toolbarColor: Colors.deepOrange,
  //         toolbarWidgetColor: Colors.white,
  //         initAspectRatio: CropAspectRatioPreset.original,
  //         lockAspectRatio: false,
  //       ),
  //       iosUiSettings: IOSUiSettings(
  //         title: "Image Cropper",
  //       ),
  //     );
  //
  //     if (croppedFile != null) {
  //       imageCache.clear();
  //       setState(() {
  //         imageFile = File(croppedFile.path);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error cropping image: $e');
  //   }
  // }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Image Source'),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
              },
              child: const Text('Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
              },
              child: const Text('Camera'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (pickedFile != null) {
      // Use the picked file
      File imageFile = File(pickedFile.path);
      // Do something with the image file (e.g., display it)
    }
  }

  Widget buildImage(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 5.2,
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                child: const Column(
                  children: [
                    Icon(Icons.image, size: 60.0),
                    SizedBox(height: 12.0),
                    Text(
                      "Gallery",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                ),
                onTap: () {
                  _pickImage(context);
                },
              ),
            ),
            Expanded(
              child: InkWell(
                child: const Column(
                  children: [
                    Icon(Icons.camera_alt, size: 60.0),
                    SizedBox(height: 12.0),
                    Text(
                      "Camera",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                ),
                onTap: () {
                  _pickImage(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
