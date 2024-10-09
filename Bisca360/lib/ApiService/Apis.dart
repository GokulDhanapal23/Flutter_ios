import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Response/SigninResponse.dart';

class Apis{
  static http.Client client = http.Client();
  static String TOKEN = "";

  static setClient(http.Client clientData) {
    client = clientData;
  }

  static getClient() {
    return client;
  }

  static getHeaders() {
    final  token= getToken();

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

  static String checkMobileNumber = '${dotenv.env['BASE_URL'] ?? ""}/user/check/mobilenumber';
  // static String checkMobileNumber = 'http://192.168.0.15:9092/user/check/mobilenumber';
  static String login = '${dotenv.env['BASE_URL'] ?? ""}/user/signin';

  static String getAllShop = '${dotenv.env['BASE_URL'] ?? ""}/shop/get';
  static String getAllMeasurements = '${dotenv.env['BASE_URL'] ?? ""}/measurements/get';

  static String getSupplierAndChairNo = '${dotenv.env['BASE_URL'] ?? ""}/shop/get/employee/seating';

  static String getActiveShop = '${dotenv.env['BASE_URL'] ?? ""}/shop/get/active';
  static String saveShop = '${dotenv.env['BASE_URL'] ?? ""}/shop/save';
  static String saveShopProduct = '${dotenv.env['BASE_URL'] ?? ""}/shop/product/save';

  static String getShopProduct = '${dotenv.env['BASE_URL'] ?? ""}/shop/product/get/';
  static String getChangeProductStatus = '${dotenv.env['BASE_URL'] ?? ""}/shop/product/status/change';
  static String getShopCustomer = '${dotenv.env['BASE_URL'] ?? ""}/shopcustomer/getby/shopname';

  static String getAllCategory = '${dotenv.env['BASE_URL'] ?? ""}/category/getCategoryAll/';
  static String getAllSubCategory = '${dotenv.env['BASE_URL'] ?? ""}/subCategory/getsubCategoryAll/';

  static String saveShopSales = '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/save';

  static String getAllBillByDate = '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/bydate';

  static String getUnits ='${dotenv.env['BASE_URL'] ?? ""}/measurements/get';

  static String getTax ='${dotenv.env['BASE_URL'] ?? ""}/tax/get';

  static String imageLoad = '${dotenv.env['BASE_URL'] ?? ""}/file/load/';

  static String shopInvoicePdf = '${dotenv.env['BASE_URL'] ?? ""}/report/customer/invoice/pdf';
  static String shopBillPdf = '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/bill/invoice';

  static String shopSalesSearch = '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/shopSales/search';

  static String shopSummary= '${dotenv.env['BASE_URL'] ?? ""}/report/customer/billing/';

  static String getLastBillNo = '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/get/last/bill';

  static String getDeleteRemarks = '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/bill/delete/remarks';

  static String deleteLastBill = '${dotenv.env['BASE_URL'] ?? ""}/shopsalesdetails/bill/delete';

  static String getProject = '${dotenv.env['BASE_URL'] ?? ""}/site-details/get';


  static Future<void> getToken() async {
    SigninResponse? signInResponse = await getSignInResponse();
    if (signInResponse != null) {
      TOKEN = signInResponse.accessToken;
      print('Token: $TOKEN');
    } else {
      print('No SigninResponse found in SharedPreferences');
    }
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