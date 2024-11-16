import 'dart:convert';

import 'package:bisca360/Response/UsersAccountsResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ApiService/Apis.dart';
import '../Request/SigninRequest.dart';
import '../Response/SigninResponse.dart';
import '../Service/LoginService.dart';

class SetUpMPIN extends StatefulWidget {
  const SetUpMPIN({super.key});
  @override
  State<SetUpMPIN> createState() => _SetUpMPINState();
}

class _SetUpMPINState extends State<SetUpMPIN> {
  @override
  void initState() {
    getSigninResponse();
    super.initState();
  }

  late String _pin = '';
  late String _conformPin = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SigninResponse signinResponse;

  Future<void> setUpMPIN(var data, BuildContext context) async {
    print('data: $data');
    try {
      final res = await Apis.getClient().post(Uri.parse(Apis.setUpMPIN),
          body: data, headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
        Navigator.of(context).pop();
      } else {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getSigninResponse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('signin_response');
    if (jsonString != null) {
      signinResponse = SigninResponse.fromJson(jsonDecode(jsonString));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 45,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text('Setup MPIN', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 25, right: 25),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                    child: RichText(
                      text: const TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Setup Your MPIN ',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Enter MPIN",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Pinput(
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: Colors.green),
                          ),
                        ),
                        onCompleted: (pin) {
                          setState(() {
                            _pin = pin;
                          });
                          debugPrint(pin);
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     _isObscured ? Icons.visibility_off : Icons.visibility,
                      //     color: Colors.black,
                      //   ),
                      //   onPressed: () {
                      //     setState(() {
                      //       _isObscured = !_isObscured;
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Conform MPIN",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Pinput(
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: Colors.green),
                          ),
                        ),
                        onCompleted: (pin) {
                          setState(() {
                            _conformPin = pin;
                          });
                          debugPrint(pin);
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     _isObscured ? Icons.visibility_off : Icons.visibility,
                      //     color: Colors.black,
                      //   ),
                      //   onPressed: () {
                      //     setState(() {
                      //       _isObscured = !_isObscured;
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        if (_pin.length == 4) {
                          var dataMpin = {
                            "mpin": _pin,
                            "userId": signinResponse.id,
                          };
                          var data = jsonEncode(dataMpin);
                          print('MPINData: $data');
                          setUpMPIN(data, context);
                          print('Entered PIN: $_pin');
                        } else {
                          // Show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: const Text(
                                    'Please enter a valid 4-digit MPIN')),
                          );
                        }
                      },
                      child: const Text("Setup MPIN",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
