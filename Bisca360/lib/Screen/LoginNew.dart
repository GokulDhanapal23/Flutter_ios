import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ApiService/Apis.dart';
import '../Response/CheckMobileNumberResponse.dart';
import '../Service/LoginService.dart';
import '../Util/Validator.dart';
import '../Widget/FlushBarType.dart';
import '../Widget/FlushBarWidget.dart';
import 'UserAccounts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({Key? key}) : super(key: key);

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  final TextEditingController countryController = TextEditingController(text: "+91");
  final TextEditingController loginMobileNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;


  Future<void> checkAccessPermission(BuildContext context) async {
    // Define the permissions you want to request
    List<Permission> permissions = [
      // Permission.manageExternalStorage,
      Permission.storage,
      Permission.phone,
      Permission.camera,
      Permission.contacts,
    ];

    // Request permissions
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      Fluttertoast.showToast(msg: "All permissions are granted", toastLength: Toast.LENGTH_SHORT);
      // You can navigate to the next screen or perform any action here
    } else {
      // Show a warning if not all permissions are granted
      Fluttertoast.showToast(msg: "Please provide all permissions", toastLength: Toast.LENGTH_SHORT);
    }
  }
  Future<void> checkInternetPermission(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      Fluttertoast.showToast(msg: "Internet Success", toastLength: Toast.LENGTH_SHORT);
    } else {
      Fluttertoast.showToast(msg: "Failed internet", toastLength: Toast.LENGTH_SHORT);
    }
  }
  @override
  void initState(){
    super.initState();
    checkAccessPermission(context);
    checkInternetPermission(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 25, right: 25),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/loginGreen.png',
                    width: 170,
                    height: 170,
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Welcome",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Thank you for choosing our app. We're excited to have you on board!",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 370,
                    child: TextFormField(
                      controller: loginMobileNumberController,
                      validator: (value) {
                        return Validator.validate('mobile', value!, TextInputType.text);
                      },
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Phone',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Icon(
                            Icons.mobile_friendly,
                            color: Colors.green,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true; // Show loader
                          });
                          var signInData = {
                            "mobileNumber": loginMobileNumberController.text,
                          };
                          await LoginService.signIn(jsonEncode(signInData), context);
                          setState(() {
                            _isLoading = false; // Hide loader
                          });
                        }
                      },
                      child: const Text("Continue", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
