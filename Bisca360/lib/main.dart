
import 'package:flutter/material.dart';

import 'Screen/Login.dart';


void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      title: 'Bisca360',
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
