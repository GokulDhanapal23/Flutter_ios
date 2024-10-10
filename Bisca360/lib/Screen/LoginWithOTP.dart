import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:bisca360/Request/SigninRequest.dart';
import 'package:bisca360/Request/ValidateOTP.dart';
import 'package:bisca360/Response/UsersAccountsResponse.dart';
import 'package:bisca360/Service/LoginService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../ApiService/Apis.dart';
import '../Request/requestOTP.dart';
import '../Service/NavigationHelper.dart';
import 'LoginNew.dart';

class LoginWithOTP extends StatefulWidget {
  final UsersAccountsResponse usersAccountsResponse;

  const LoginWithOTP({super.key, required this.usersAccountsResponse});

  @override
  State<LoginWithOTP> createState() => _LoginWithOTPState();
}

class _LoginWithOTPState extends State<LoginWithOTP> {
  late String _otp = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _timer;
  int _start = 120; // Timer duration in seconds
  bool _canResendOtp = false;

  Future<void> requestOTP(var data, BuildContext context) async {
    try {
      print(data);
      var res = await Apis.getClient().post(
          Uri.parse(Apis.requestOTP),
          body :jsonEncode(data.toJson()),
          headers: Apis.getHeaderNoToken());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        print(response);
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.success);
      } else {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> validateOTP(var data, BuildContext context) async {
    try {
      print(data);
      var res = await Apis.getClient().post(
          Uri.parse(Apis.validateOTP),
          body :jsonEncode(data.toJson()),
          headers: Apis.getHeaderNoToken());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        var signInData = {
          "mobileNumber": widget.usersAccountsResponse.mobileNumber, "ownerId": widget.usersAccountsResponse.ownerId,
        };
        await LoginService.signInWithMobile(jsonEncode(signInData), context);
        print(response);
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.success);

      } else {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _canResendOtp = false;
    _start = 120; // Reset timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResendOtp = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  void resendOtp() {
    RequestOtp otp = RequestOtp(mobileNumber: widget.usersAccountsResponse.mobileNumber.toString(), ownerId: widget.usersAccountsResponse.ownerId);
    requestOTP(otp,context);
    startTimer();
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
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          onPressed: () {
            NavigationHelper.navigateWithFadeSlide(
              context,
              MyPhone(),
            );
          },
          icon: const Icon(Icons.clear, color: Colors.black),
        ),
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
                  Image.asset(
                    'assets/otp_msg.png',
                    width: 130,
                    height: 130,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                    child: RichText(
                      text: const TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'OTP VERIFICATION',
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
                  const SizedBox(height: 10),
                  Text(
                       "Mobile Number is +91********${widget.usersAccountsResponse.mobileNumber.toString().substring(widget.usersAccountsResponse.mobileNumber.toString().length - 4)}",
            style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Resend OTP in $_start seconds',style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _canResendOtp ? resendOtp : null,
                    child: Text('Resend OTP'),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Enter 6-Digit OTP",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: Colors.green),
                      ),
                    ),
                    onCompleted: (pin) {
                      setState(() {
                        _otp = pin;
                      });
                      debugPrint(pin);
                    },
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
                        if (_otp.length == 6) {
                        ValidateOTP otp = new ValidateOTP(code: _otp, mobileNumber: widget.usersAccountsResponse.mobileNumber);
                          validateOTP(otp, context);
                          print('Entered OTP: $_otp');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Please enter a valid 6-digit OTP')),
                          );
                        }
                      },
                      child: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
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
