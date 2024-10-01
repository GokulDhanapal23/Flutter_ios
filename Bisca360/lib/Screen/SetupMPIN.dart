import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../Request/SigninRequest.dart';
import '../Service/LoginService.dart';

class SetUpMPIN extends StatefulWidget {
  const SetUpMPIN({super.key});

  @override
  State<SetUpMPIN> createState() => _SetUpMPINState();
}

class _SetUpMPINState extends State<SetUpMPIN> {

  late String _pin = '';
  late String _conformPin = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        centerTitle: true,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      onPressed: () {
                        // Validate the PIN length
                        // if (_pin.length == 4) {
                        //   SigninRequest signInRequest = SigninRequest(
                        //     widget.usersAccountsResponse.mobileNumber,
                        //     widget.usersAccountsResponse.ownerId,
                        //     _pin,
                        //   );
                        //
                        //   var data = jsonEncode(signInRequest.toJson());
                        //   print('sigInData: $data');
                        //   LoginService.loginWithMPIN(data, context);
                        //   print('Entered PIN: $_pin');
                        // } else {
                        //   // Show an error message
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: const Text('Please enter a valid 4-digit MPIN')),
                        //   );
                        // }
                      },
                      child: const Text("Setup MPIN", style: TextStyle(color: Colors.white)),
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
