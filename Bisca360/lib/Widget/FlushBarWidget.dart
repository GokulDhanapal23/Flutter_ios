import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'FlushBarType.dart';

class MessageWidget {
  // Helper method to get icon and color based on message type
  static Icon _getIconAndColor(FlushBarType type) {
    switch (type) {
      case FlushBarType.success:
        return Icon(Icons.task_alt, size: 28.0, color: Colors.green);
      case FlushBarType.failed:
        return Icon(Icons.error, size: 28.0, color: Colors.red);
      case FlushBarType.warning:
        return Icon(Icons.warning, size: 28.0, color: Colors.orange);
      default:
        return Icon(Icons.info, size: 28.0, color: Colors.blue); // Default icon
    }
  }

  // Helper method to get background color based on message type
  static Color _getBackgroundColor(FlushBarType type) {
    switch (type) {
      case FlushBarType.success:
        return Colors.green.shade100;
      case FlushBarType.failed:
        return Colors.red;
      case FlushBarType.warning:
        return Colors.yellow.shade100;
      default:
        return Colors.blue.shade100; // Default background
    }
  }

  // Method to show a Flushbar with an icon on the right
  static void showFlushBar(
      BuildContext context,
      String message,
      FlushBarType type,
      ) {
    Flushbar(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: _getBackgroundColor(type),
      message: message,
      messageColor: Colors.black,
      mainButton: TextButton(
        onPressed: () {},
        child: _getIconAndColor(type),
      ),
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(16.0),
      padding: EdgeInsets.all(16),
      barBlur: 10,
    ).show(context);
  }

  // static void showQuickAlertSuccess(BuildContext context, String message) {
  //   return QuickAlert.show(
  //     context: context,
  //     autoCloseDuration: const Duration(milliseconds: 5000),
  //     type: QuickAlertType.success,
  //     confirmBtnText: "",
  //     text: message,
  //   );
  // }
  //
  // static void showQuickAlertWarning(BuildContext context, String message) {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Warning...!"),
  //         content: Text(message),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Ok'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // static void showBsAlert(BuildContext context, String message, MessageType messageType) {
  //   String type = messageType.name;
  //   return BsAlert(
  //     closeButton: true,
  //     margin: const EdgeInsets.only(bottom: 10.0),
  //     style: type == "SUCCESS"
  //         ? BsAlertStyle.success
  //         : type == 'WARNING'
  //         ? BsAlertStyle.warning
  //         : type == "INFO"
  //         ? BsAlertStyle.info
  //         : type == 'ERROR'
  //         ? BsAlertStyle.danger
  //         : type == 'PRIMARY'
  //         ? BsAlertStyle.primary
  //         : type == 'SECONDARY'
  //         ? BsAlertStyle.secondary
  //         : BsAlertStyle.primary,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(message),
  //       ],
  //     ),
  //   );
  // }
}


