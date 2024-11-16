import 'dart:convert';

import 'package:bisca360/Request/SigninRequest.dart';
import 'package:bisca360/Service/LoginService.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Response/SigninResponse.dart';

class Apis {
  static http.Client client = http.Client();
  static String TOKEN = "";
  static final storage = FlutterSecureStorage();

  static setClient(http.Client clientData) {
    client = clientData;
  }

  static getClient() {
    return client;
  }

  static getHeaders() {
    final token = getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $TOKEN',
    };
  }

  static getHeaderNoToken() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static String checkMobileNumber =
      '${dotenv.env['BASE_URL'] ?? ""}/user/check/mobilenumber';
  // static String checkMobileNumber = 'http://192.168.0.15:9092/user/check/mobilenumber';
  static String login = '${dotenv.env['BASE_URL'] ?? ""}/user/signin';
  static String signInWithMobile =
      '${dotenv.env['BASE_URL'] ?? ""}/user/signinwithmobile';
  static String setUpMPIN = '${dotenv.env['BASE_URL'] ?? ""}/user/setmpin';
  static String refreshToken = '${dotenv.env['BASE_URL'] ?? ""}/user/refresh';
  static String getAllShop = '${dotenv.env['BASE_URL'] ?? ""}/shop/get';
  static String getAllMeasurements =
      '${dotenv.env['BASE_URL'] ?? ""}/measurements/get';
  static String saveMeasurement =
      '${dotenv.env['BASE_URL'] ?? ""}/measurements/save';
  static String changeMeasurementsStatus =
      '${dotenv.env['BASE_URL'] ?? ""}/measurements/set/status';
  static String getSupplierAndChairNo =
      '${dotenv.env['BASE_URL'] ?? ""}/shop/get/employee/seating';
  static String getActiveShop =
      '${dotenv.env['BASE_URL'] ?? ""}/shop/get/active';
  static String saveShop = '${dotenv.env['BASE_URL'] ?? ""}/shop/save';
  static String saveShopProduct =
      '${dotenv.env['BASE_URL'] ?? ""}/shop/product/save';
  static String getShopProduct =
      '${dotenv.env['BASE_URL'] ?? ""}/shop/product/get/';
  static String getChangeProductStatus =
      '${dotenv.env['BASE_URL'] ?? ""}/shop/product/status/change';
  static String getShopCustomer =
      '${dotenv.env['BASE_URL'] ?? ""}/shopcustomer/getby/shopname';
  static String getAllCategory =
      '${dotenv.env['BASE_URL'] ?? ""}/category/getCategoryAll/';
  static String getAllSubCategory =
      '${dotenv.env['BASE_URL'] ?? ""}/subCategory/getsubCategoryAll/';
  static String saveShopSales =
      '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/save';
  static String getAllBillByDate =
      '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/bydate';
  static String getUnits = '${dotenv.env['BASE_URL'] ?? ""}/measurements/get';
  static String getTax = '${dotenv.env['BASE_URL'] ?? ""}/tax/get';
  static String imageLoad = '${dotenv.env['BASE_URL'] ?? ""}/file/load/';
  static String shopInvoicePdf =
      '${dotenv.env['BASE_URL'] ?? ""}/report/customer/invoice/pdf';
  static String shopBillPdf =
      '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/bill/invoice';
  static String shopSalesSearch =
      '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/shopSales/search';
  static String shopSummary =
      '${dotenv.env['BASE_URL'] ?? ""}/report/customer/billing/';
  static String getLastBillNo =
      '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/last/bill';
  static String getDeleteRemarks =
      '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/bill/delete/remarks';
  static String deleteLastBill =
      '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/bill/delete';
  static String getProject = '${dotenv.env['BASE_URL'] ?? ""}/site-details/get';
  static String saveProject =
      '${dotenv.env['BASE_URL'] ?? ""}/site-details/save';
  static String getAllProcessStatus =
      '${dotenv.env['BASE_URL'] ?? ""}/process/status/list/all/active';
  static String requestOTP = '${dotenv.env['BASE_URL'] ?? ""}/otp/get';
  static String validateOTP = '${dotenv.env['BASE_URL'] ?? ""}/otp/validate';
  static String saveShopOrder =
      '${dotenv.env['BASE_URL'] ?? ""}/shoporder/save';
  static String getShopOrderStatus =
      '${dotenv.env['BASE_URL'] ?? ""}/shoporder/get/status';
  static String getShopOrderDetails =
      '${dotenv.env['BASE_URL'] ?? ""}/shoporder/get/details';
  static String updateShopOrderStatus =
      '${dotenv.env['BASE_URL'] ?? ""}/shoporder/get/update/status';
  static String shopOrderBill =
      '${dotenv.env['BASE_URL'] ?? ""}/shoporder/get/bill/invoice';

  static BuildContext? get context => null;

  static Future<void> getToken() async {
    SigninResponse? signInResponse = await getSignInResponse();
    String? accessToken = await getAccessToken();

    if (accessToken != null) {
      if (isTokenExpired(accessToken)) {
        SigninRequest? request = await retrieveUserData();
        if (request != null) {
          await LoginService.refreshLoginWithMPIN(request);
        }
        accessToken = await getAccessToken();
        if (accessToken != null) {
          TOKEN = accessToken; // Update the global TOKEN variable
        } else {
          print('Failed to retrieve access token after refresh.');
        }
      } else {
        TOKEN = accessToken; // Token is valid
      }
    } else {
      print('No sign-in response or access token found in SharedPreferences.');
    }
  }

  static Future<SigninRequest?> retrieveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      // Decode the JSON string to a Map
      Map<String, dynamic> userData = jsonDecode(userDataString);

      // Create a SigninRequest instance from the decoded data
      SigninRequest request = SigninRequest.fromJson(userData);

      print('Mobile Number: ${request.mobileNumber}');
      print('Owner ID: ${request.ownerId}');
      return request;
    } else {
      return null;
      print('No user data found');
    }
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  static bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  static Future<SigninResponse?> getSignInResponse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('signIn');
    if (jsonString != null) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return SigninResponse.fromJson(jsonMap);
    } else {
      print('No SigninResponse found in SharedPreferences');
      return null;
    }
  }
}
