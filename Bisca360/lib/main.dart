import 'dart:io';

import 'package:http/io_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ApiService/Apis.dart';
import 'Environment.dart';
import 'Screen/LoginNew.dart';

class MyHttpOverrides extends HttpOverrides {
  ByteData data;
  ByteData key;

  MyHttpOverrides(this.data, this.key);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    context!.setClientAuthoritiesBytes(data.buffer.asUint8List());
    context!.usePrivateKeyBytes(key.buffer.asUint8List());

    // Allow self-signed certificates during development
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());

    return super.createHttpClient(context);
  }
  HttpClient createHttpClientWithOptions(SecurityContext? context) {
    HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Accept all certs
    return client;
  }
}

void main() async{

  const varName = String.fromEnvironment('env', defaultValue: 'prd');
  print('profile $varName');
  await dotenv.load(fileName: Environment.load(varName));
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await rootBundle.load('assets/cert/bisca.crt');
  ByteData key = await rootBundle.load('assets/cert/private.key');
  SecurityContext context = SecurityContext.defaultContext;
  HttpClient client=MyHttpOverrides(data, key).createHttpClient(context);
  IOClient clientData=  IOClient(client);
  Apis.setClient(clientData);
  runApp( MyApp());
}

  Future<void> requestStoragePermission() async {
    final status = await Permission.storage.request();
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.contacts,
      // Permission.manageExternalStorage,
      Permission.phone,
      Permission.storage,
    ].request();
    if (status.isGranted) {
      print('Storage permission granted');
    } else if (status.isDenied) {
      print('Storage permission denied');
      // openAppSettings();
    } else if (status.isPermanentlyDenied) {
      print('Storage permission permanently denied');
      openAppSettings(); // Prompt user to manually enable permission in settings
    }
  }


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      title: 'Bisca360',
      debugShowCheckedModeBanner: false,
      home: MyPhone(),
      // routes: {
      //   '/home': (context) => Home(),
      //   '/settings': (context) => Settings(),
      //   '/profile': (context) => UserProfile(),
      // },
    );
  }
}
