import 'dart:io';

import 'package:bisca360/Service/LoginService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/io_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ApiService/Apis.dart';
import 'Environment.dart';
import 'Response/SigninResponse.dart';
import 'Screen/Home.dart';
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
  // HttpClient createHttpClientWithOptions(SecurityContext? context) {
  //   HttpClient client = super.createHttpClient(context);
  //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Accept all certs
  //   return client;
  // }
}
class MyHttpOverrides1 extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host,
          int port) => true;
  }
}

void main() async {
  const varName = String.fromEnvironment('env', defaultValue: 'prd');
  print('profile $varName');
  await dotenv.load(fileName: Environment.load(varName));
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await rootBundle.load('assets/cert/cert.crt');
  ByteData key = await rootBundle.load('assets/cert/bisca.key');
  // if(kIsWeb) {
  //   HttpOverrides.global = MyHttpOverrides1();
  // }else{
    SecurityContext context = SecurityContext.defaultContext;
    HttpClient client = MyHttpOverrides(data, key).createHttpClient(context);
    IOClient clientData = IOClient(client);
    Apis.setClient(clientData);
  // }
    bool loggedIn = await isLoggedIn();
  SigninResponse? response = await someFunction();
  runApp(MyApp(
    initialRoute: loggedIn ? '/home' : '/login',
    dataLoggedIn: response,
  ));
}

Future<bool> isLoggedIn() async {
  final storage = FlutterSecureStorage();
  String? accessToken = await storage.read(key: 'access_token');
  return accessToken != null;
}

Future<SigninResponse?> someFunction() async {
  SigninResponse? signinResponse = await LoginService.getSigninResponse();
  if (signinResponse != null) {
    return signinResponse;
  } else {
    return null;
  }
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
  final String initialRoute;
  final SigninResponse? dataLoggedIn;

  MyApp({required this.initialRoute, required this.dataLoggedIn});

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> routes = {
      '/login': (context) => MyPhone(),
      if (dataLoggedIn != null) // Add the home route conditionally
        '/home': (context) => Home(signinResponse: dataLoggedIn),
    };

    return MaterialApp(
      title: 'Bisca360',
      debugShowCheckedModeBanner: false,
      // home: MyPhone(),
      initialRoute: initialRoute,
      routes: routes, // Use the constructed routes map
    );
  }
}
