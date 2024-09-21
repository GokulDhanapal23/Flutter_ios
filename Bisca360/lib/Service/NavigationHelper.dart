import 'package:flutter/material.dart';

class NavigationHelper {
  static void navigateWithFadeSlide(BuildContext context, Widget page,{bool popCurrent = false}) {
    if (popCurrent) {
      Navigator.of(context).pop(); // Pop the current route
    }
    Navigator.pushAndRemoveUntil (
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide animation
          const begin = Offset(1.0, 0.0); // Start from the right
          const end = Offset.zero; // End at original position
          const curve = Curves.easeInOut;

          var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // Fade animation
          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          // Combine both animations
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ), (Route<dynamic> route) => false,
    );
  }
}
