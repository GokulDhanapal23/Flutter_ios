import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  ToastUtil({
    required this.message,
    this.backgroundColor = Colors.black, // Default background color
    this.textColor = Colors.white, // Default text color
  });

  void show() {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: backgroundColor,
      textColor: textColor,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
  }
}
