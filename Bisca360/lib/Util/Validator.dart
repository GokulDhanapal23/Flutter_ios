import 'package:flutter/cupertino.dart';

class Validator{

  static String? validate(
      String type, String value, TextInputType textInputType){
    if (type.toLowerCase().contains("mobile")) {
      return validateMobileNumber(value);
    }
    return null;
  }


  static String? validateMobileNumber(String value) {
    if (value.isEmpty) {
      return "Please enter your mobile number";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Phone number must be exactly 10 digits";
    }
    return null; // Validation passed
  }
  static bool isEmailValid(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(p);
    return regex.hasMatch(email);
  }
  static bool isNotEmpty(String value) {
    return value.isNotEmpty;
  }
}