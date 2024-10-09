// import 'package:bisca360/Response/ProjectResponse.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../Widget/AppTextFormField.dart';
// import '../Widget/CustomSearchfieldWidget.dart';
//
// class CreateProject extends StatefulWidget {
//   final ProjectResponse? projectResponse;
//   const CreateProject({super.key, required this.projectResponse});
//
//   @override
//   State<CreateProject> createState() => _CreateProjectState();
// }
//
// class _CreateProjectState extends State<CreateProject> {
//
//   final TextEditingController _projectNameController = TextEditingController();
//   final TextEditingController _projectAreaController = TextEditingController();
//   bool _isEditMode = false;
//   bool _isLoading = false;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         backgroundColor: Colors.green,
//         title:  Text(widget.projectResponse != null ? 'Update Project' : 'Create Project', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         elevation: 1,
//         actions: [
//           !_isEditMode
//               ?  Container(
//             margin: EdgeInsets.fromLTRB(0, 4, 10, 4),
//             child: ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _isEditMode =true;
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//               ),
//               child: _isLoading
//                   ? CircularProgressIndicator(color: Colors.green)
//                   : Text(
//                 _isEditMode ? '' : 'Edit',
//                 style: const TextStyle(color: Colors.green),
//               ),
//             ),
//           )
//               : Container(),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child:  Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 AppTextFieldForm(
//                   _projectNameController,
//                   "Project Name",
//                   const Icon(Icons.shop, color: Colors.green),
//                   TextInputAction.next,
//                   TextInputType.text,
//                   _isEditMode,
//                   true,
//                   maxLines: null,
//                   textAlignVertical: TextAlignVertical.center,
//                 ),
//                 const SizedBox(height: 10),
//                 AppTextFieldForm(
//                   _mobileNumberController,
//                   "Mobile Number",
//                   const Icon(Icons.phone_android, color: Colors.green),
//                   TextInputAction.next,
//                   TextInputType.phone,
//                   _isEditMode,
//                   true,
//                   maxLines: null,
//                   textAlignVertical: TextAlignVertical.center,
//                 ),
//                 const SizedBox(height: 10),
//                 AppTextFieldForm(
//                   _gstController,
//                   "GST Number",
//                   const Icon(Icons.numbers, color: Colors.green),
//                   TextInputAction.next,
//                   TextInputType.text,
//                   _isEditMode,
//                   false,
//                   maxLines: null,
//                   textAlignVertical: TextAlignVertical.center,
//                 ),
//                 const SizedBox(height: 10),
//                 // CustomDropdownButton(
//                 //   textEditingController: _shopTypeController,
//                 //   hintText: 'Shop Type',
//                 //   prefixIcon: Icon(Icons.shop, color: Colors.green),
//                 //   items: _shopTypes,
//                 //   selectedValue: selectedValue,
//                 //   onSelect: handleSelect,
//                 //   validate: true, // Set true if you want validation
//                 // ),
//
//                 CustomSearchField.buildSearchField(_shopTypeController, 'Shop Type', Icons.shop, _shopTypeItems, (String value) {},_isEditMode,true,widget.projectResponse == null? true:false,false),
//                 const SizedBox(height: 10),
//                 CustomSearchField.buildSearchField(_projectController, 'Project', Icons.plagiarism_rounded, _projectNames, (String value) {},_isEditMode,false,widget.projectResponse == null? true:false,false),
//                 const SizedBox(height: 10),
//                 CustomSearchField.buildSearchField(_priceRoundingController, 'Price Rounding', Icons.attach_money_outlined, _rounding, (String value) {},_isEditMode,true,widget.projectResponse == null? true:false,false),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     const Text('GST Enabled:', style: TextStyle(fontWeight: FontWeight.bold)),
//                     Expanded(
//                       child: RadioListTile<bool?>(
//                         title: const Text('Yes'),
//                         value: true,
//
//                         groupValue: _selectedBooleanValue,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _selectedBooleanValue = value;
//                           });
//                         },
//                       ),
//                     ),
//                     Expanded(
//                       child: RadioListTile<bool?>(
//                         title: const Text('No'),
//                         value: false,
//                         groupValue: _selectedBooleanValue,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _selectedBooleanValue = value;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 AppTextFieldForm(
//                   _addressController,
//                   "Address",
//                   const Icon(Icons.location_on, color: Colors.green),
//                   TextInputAction.next,
//                   TextInputType.text,
//                   _isEditMode,
//                   true,
//                   maxLines: null,
//                   textAlignVertical: TextAlignVertical.center,
//                 ),
//                 const SizedBox(height: 10),
//                 AppTextFieldForm(
//                   _descriptionController,
//                   "Description",
//                   const Icon(Icons.description, color: Colors.green),
//                   TextInputAction.done,
//                   TextInputType.text,
//                   _isEditMode,
//                   false,
//                   maxLines: null,
//                   textAlignVertical: TextAlignVertical.center,
//                 ),
//                 const SizedBox(height: 10),
//                 _isEditMode?
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                       child: const Text('Cancel', style: TextStyle(color: Colors.white)),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : () {
//                         if (_formKey.currentState!.validate()) {
//                           _saveForm();
//                         }else{
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Please fill in all fields correctly')),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                       ),
//                       child: _isLoading
//                           ? CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                         widget.shopResponse == null ? 'Save' : 'Update',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ): Row(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
