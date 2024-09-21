import 'dart:convert';

import 'package:bisca360/Response/ShopResponse.dart';
import 'package:bisca360/Response/TaxResponse.dart';
import 'package:flutter/material.dart';

import '../ApiService/Apis.dart';
import '../Response/DefaultResponse.dart';
import 'LoginService.dart';

class ShopService{

  late List<Shopresponse> shopResponses;

 static late final DefaultResponse response;
  getAllShops() async {
    await Apis.getClient().get(Uri.parse(Apis.getAllShop), headers: Apis.getHeaders()).then((res) => {
    if(res.statusCode==200){
        setState(() {
        List<dynamic> info = json.decode(res.body).map((data) => Shopresponse.fromJson(data)).toList();
        shopResponses = info.cast<Shopresponse>();
      })
    }
    });
  }
  static Future<void> saveShop(var data, BuildContext context) async {
    try {
      var res = await Apis.getClient().post(
          Uri.parse(Apis.saveShop),
          body :jsonEncode(data.toJson()),
          headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status']== "OK") {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.success);
        Navigator.of(context).pop();
        print("Success");
      } else {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  static Future<void> saveShopProduct(var data, BuildContext context) async {
    try {
      var res = await Apis.getClient().post(
          Uri.parse(Apis.saveShopProduct),
          body : data,
          headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.success);
        Navigator.of(context).pop();
        print("Success");
      } else {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.error);
        print('Failed to product save');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  setState(Null Function() param0) {}
}