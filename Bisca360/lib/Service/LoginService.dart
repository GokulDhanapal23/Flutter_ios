import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:bisca360/Request/SigninRequest.dart';
import 'package:bisca360/Response/RefreshResponse.dart';
import 'package:bisca360/Response/SigninResponse.dart';
import 'package:bisca360/Screen/UserAccounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../ApiService/Apis.dart';
import '../Response/CheckMobileNumberResponse.dart';
import '../Screen/Home.dart';
import '../Screen/Login.dart';
import 'NavigationHelper.dart';

class LoginService {
  // static late CheckMobileNumberResponse saveDateRes;
  static late SigninResponse signinResponse;

  static final List<Flushbar> flushBars = [];
  static final storage = FlutterSecureStorage();

  static Future<void> signIn(var data, BuildContext context) async {
    try {
      final res = await Apis.getClient().post(Uri.parse(Apis.checkMobileNumber),
          body: data, headers: {"Content-Type": "application/json"});
      final response = jsonDecode(res.body);
      print('Data: ${response}');
      if (response['status'] == "OK") {
        saveDateRes = CheckMobileNumberResponse.fromJson(response);
        NavigationHelper.navigateWithFadeSlide(
          context,
          UserAccounts(saveDateRes),
        );
        print('Data: ${saveDateRes.toString()}');
      } else {
        showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Data: ${res.statusCode}');
        // showBlurredSnackBar(context);
      }
    } catch (e) {
      print('Error: $e');
      showBlurredSnackBar(context, e.toString(), type: SnackBarType.error);
      // showBlurredSnackBar(context);
    }
  }

  static Future<void> signInWithMobile(var data, BuildContext context) async {
    try {
      final res = await Apis.getClient().post(Uri.parse(Apis.signInWithMobile),
          body: data, headers: {"Content-Type": "application/json"});
      final response = jsonDecode(res.body);
      print('Data: ${response}');
      if (response['status'] == "OK") {
        showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
        final signinResponse = SigninResponse.fromJson(response);
        storeSigninResponse(signinResponse);
        storeLoginSession(signinResponse);
        await storage.write(
            key: 'access_token', value: signinResponse.accessToken);
        print('Access Token : ${signinResponse.accessToken}');
        NavigationHelper.navigateWithFadeSlide(
          context,
          Home(signinResponse: signinResponse),
        );
      } else {
        showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Data: ${res.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      showBlurredSnackBar(context, e.toString(), type: SnackBarType.error);
    }
  }

  static Future<void> storeSigninResponse(SigninResponse response) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('signin_response', jsonEncode(response.toJson()));
    print('login session UserLogin: ${prefs.get('signin_response')}');
  }

  static Future<SigninResponse?> getSigninResponse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('signin_response');
    if (jsonString != null) {
      return SigninResponse.fromJson(jsonDecode(jsonString));
    }
    return null; // Or handle as needed
  }

  static storeLoginSession(SigninResponse signIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('signIn', jsonEncode(signIn));
    var box = await Hive.openBox('login_box');
    box.put('signIn', json.encode(jsonEncode(signIn)));
    print('login session UserLogin: ${box.get('signIn')}');
  }

  static getStoredAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('signIn');
    if (userJson != null) {
      SigninResponse user = SigninResponse.fromJson(jsonDecode(userJson));
      return user.accessToken.toString();
    }
    return null;
  }

  static Future<void> loginWithMPIN(
      SigninRequest signInRequest, BuildContext context) async {
    var data = jsonEncode(signInRequest.toJson());
    print('data: $data');
    try {
      final res = await Apis.getClient().post(Uri.parse(Apis.login),
          body: data, headers: {"Content-Type": "application/json"});
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {

        final signinResponse = SigninResponse.fromJson(response);
        storeSigninResponse(signinResponse);
        storeLoginSession(signinResponse);
        await storage.write(
            key: 'access_token', value: signinResponse.accessToken);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(signInRequest.toJson()));
        NavigationHelper.navigateWithFadeSlide(
          context,
          Home(signinResponse: signinResponse),
        );
        showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
      } else {
        showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

    static Future<void> refreshLoginWithMPIN(SigninRequest signInRequest) async {
      var data = jsonEncode(signInRequest.toJson());
      try {
        final res = await Apis.getClient().post(Uri.parse(Apis.login),
            body: data, headers: {"Content-Type": "application/json"});
        final response = jsonDecode(res.body);
        if (response['status'] == "OK") {
          final signinResponse = SigninResponse.fromJson(response);
          storeSigninResponse(signinResponse);
          storeLoginSession(signinResponse);
          await storage.write(
              key: 'access_token', value: signinResponse.accessToken);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(signInRequest.toJson()));
        } else {
          print('Failed to load data');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

  static Future<void> refreshToken() async {
    try {
      final url = Uri.parse(Apis.refreshToken);

      // Await the headers
      final headers = await Apis.getHeaders();

      final res = await Apis.getClient().get(url, headers: headers);
      final response = jsonDecode(res.body);

      if (response['status'] == "OK") {
        await storage.delete(key: 'access_token');
        final refreshResponse = RefreshResponse.fromJson(response);
        await storage.write(
            key: 'access_token', value: refreshResponse.accessToken);
        print('Refresh Response: $refreshResponse');
      } else {
        print('Failed to load Refresh Response');
      }
    } catch (e) {
      print('Error fetching Refresh Response: $e');
    }
  }

  static Future<void> setUpMPIN(var data, BuildContext context) async {
    print('data: $data');
    try {
      final res = await Apis.getClient().post(Uri.parse(Apis.setUpMPIN),
          body: data, headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
        Navigator.pop(context);
      } else {
        showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<File?> imageLoad(var doctype, var id) async {
    final response = await Apis.getClient().get(
      Uri.parse(Apis.imageLoad),
      headers: Apis.getHeaderNoToken(),
    );
    return null;
  }

  static Future<void> loadSignInResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('signinResponse');
    if (jsonString != null) {
      signinResponse = SigninResponse.fromJson(jsonDecode(jsonString));
      print(' SigninResponse: $signinResponse');
    } else {
      print('No SigninResponse found in Shared Preferences');
    }
  }

  static void showBlurredSnackBar(BuildContext context, String message,
      {required SnackBarType type}) {
    // Define colors, icons, and titles for different types of messages
    Color backgroundColor;
    Color borderColor;
    Icon icon;
    String title;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.white;
        borderColor = Colors.teal;
        icon = Icon(Icons.check_circle, size: 32, color: Colors.teal);
        title = "Success";
        break;
      case SnackBarType.error:
        backgroundColor = Colors.white;
        borderColor = Colors.red;
        icon = Icon(Icons.error, size: 32, color: Colors.red);
        title = "Error";
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.white;
        borderColor = Colors.orange;
        icon = Icon(Icons.warning, size: 32, color: Colors.orange);
        title = "Warning";
        break;
      default:
        backgroundColor = Colors.black.withOpacity(0.5);
        borderColor = Colors.white;
        icon = Icon(Icons.info, size: 32, color: Colors.white);
        title = "Info";
    }

    show(
        context,
        Flushbar(
          icon: icon,
          shouldIconPulse: false,
          title: title, // Add the title here
          message: message,
          titleColor: Colors.black,
          messageColor: Colors.black,
          padding: EdgeInsets.all(24),
          flushbarPosition: FlushbarPosition.TOP,
          margin: EdgeInsets.fromLTRB(8, kToolbarHeight + 8, 8, 0),
          duration: Duration(seconds: 3), // Increased duration for visibility
          barBlur: 20,
          borderRadius: BorderRadius.circular(20.0),
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          boxShadows: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(0, 4), // changes position of shadow
            ),
            BoxShadow(
              color: borderColor.withOpacity(0.1),
              blurRadius: 20.0,
              spreadRadius: 0.0,
              offset: Offset(0, 8), // changes position of shadow
            ),
          ],
          // border: Border.all(color: borderColor, width: 2), // Add border color
        ));
  }

  static Future<void> show(BuildContext context, Flushbar newFlushBar) async {
    await Future.wait(flushBars.map((flushBar) => flushBar.dismiss()).toList());
    flushBars.clear();

    newFlushBar.show(context);
    flushBars.add(newFlushBar);
  }

  static void showBlurredSnackBarFile(
      BuildContext context, String message, String filePath,
      {required SnackBarType type}) {
    // Define colors and icons for different types of messages
    Color backgroundColor;
    Color borderColor;
    Icon icon;
    String title;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.white;
        borderColor = Colors.teal;
        icon = Icon(Icons.check_circle, size: 32, color: Colors.teal);
        title = "Success";
        break;
      case SnackBarType.error:
        backgroundColor = Colors.white;
        borderColor = Colors.red;
        icon = Icon(Icons.error, size: 32, color: Colors.red);
        title = "Error";
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.white;
        borderColor = Colors.orange;
        icon = Icon(Icons.warning, size: 32, color: Colors.orange);
        title = "Warning";
        break;
      default:
        backgroundColor = Colors.black.withOpacity(0.5);
        borderColor = Colors.white;
        icon = Icon(Icons.info, size: 32, color: Colors.white);
        title = "Info";
    }

    Flushbar? flushbar;
    flushbar = Flushbar(
      icon: icon,
      shouldIconPulse: false,
      title: title, // Add the title here
      message: message,
      titleColor: Colors.black,
      messageColor: Colors.black,
      padding: EdgeInsets.all(24),
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.fromLTRB(8, kToolbarHeight + 8, 8, 0),
      duration: Duration(seconds: 3), // Increased duration for visibility
      barBlur: 20,
      borderRadius: BorderRadius.circular(20.0),
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      boxShadows: [
        BoxShadow(
          color: borderColor.withOpacity(0.2),
          blurRadius: 10.0,
          spreadRadius: 2.0,
          offset: Offset(0, 4), // changes position of shadow
        ),
        BoxShadow(
          color: borderColor.withOpacity(0.1),
          blurRadius: 20.0,
          spreadRadius: 0.0,
          offset: Offset(0, 8), // changes position of shadow
        ),
      ],
      mainButton: Row(
        children: [
          TextButton(
            onPressed: () {
              _openFile(context, filePath);
            },
            child: Text(
              'VIEW',
              style: TextStyle(color: borderColor),
            ),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: () {
              // Dismiss the specific Flushbar instance
              flushbar?.dismiss(true); // true will remove it with animation
            },
            child: Text(
              'CLEAR',
              style: TextStyle(color: borderColor),
            ),
          ),
        ],
      ),
    )..show(context);
  }

  static final Map<String, String> types = {
    '.pdf': 'application/pdf',
    '.doc': 'application/msword',
    '.docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.xls': 'application/vnd.ms-excel',
    '.xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.ppt': 'application/vnd.ms-powerpoint',
    '.pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    '.txt': 'text/plain',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    // Add more types as needed
  };

  static Future<void> _openFile(BuildContext context, String filePath) async {
    // Implement the logic to open the file using a package like url_launcher or open_file
    try {
      // Assuming you're using open_file package
      // final extension = path.extension(filePath);//import 'package:path/path.dart' as path;
      // await OpenFile.open(filePath, type: types[extension]);
      await OpenFile.open(filePath);
    } catch (e) {
      // Handle error
      print('Could not open file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open file: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

enum SnackBarType { success, error, warning }
