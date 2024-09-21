import 'dart:convert';
import 'ShopBillProducts.dart';

class ShopSalesDetailsRequest {
  late int id;
  late String shopName;
  late String paymentType;
  late List<ShopBillProducts> listSellingData;
  late double totalPrice;
  late double totalTax;
  late double netTotalPrice;
  late String billDate;
  late String dayTime;
  late String customerName;
  late int mobileNumber;
  late int shopCustomerId;

  ShopSalesDetailsRequest(
      this.id,
      this.shopName,
      this.paymentType,
      this.listSellingData,
      this.totalPrice,
      this.totalTax,
      this.netTotalPrice,
      this.billDate,
      this.dayTime,
      this.customerName,
      this.mobileNumber,
      this.shopCustomerId,
      );

  factory ShopSalesDetailsRequest.fromJson(Map<String, dynamic> json) {
    return ShopSalesDetailsRequest(
      json['id'] as int,
      json['shopName'] as String,
      json['paymentType'] as String,
      (json['listSellingData'] as List<dynamic>)
          .map((item) => ShopBillProducts.fromJson(item as Map<String, dynamic>))
          .toList(),
      (json['totalPrice'] as num).toDouble(),
      (json['totalTax'] as num).toDouble(),
      (json['netTotalPrice'] as num).toDouble(),
      json['billDate'] as String,
      json['dayTime'] as String,
      json['customerName'] as String,
      json['mobileNumber'] as int,
      json['shopCustomerId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'paymentType': paymentType,
      'listSellingData': listSellingData.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'totalTax': totalTax,
      'netTotalPrice': netTotalPrice,
      'billDate': billDate,
      'dayTime': dayTime,
      'customerName': customerName,
      'mobileNumber': mobileNumber,  // Ensure this is an int
      'shopCustomerId': shopCustomerId,
    };
  }

  @override
  String toString() {
    return '{id: $id, shopName: $shopName, paymentType: $paymentType, listSellingData: $listSellingData, totalPrice: $totalPrice, totalTax: $totalTax, netTotalPrice: $netTotalPrice, billDate: $billDate, dayTime: $dayTime, customerName: $customerName, mobileNumber: $mobileNumber, shopCustomerId: $shopCustomerId}';
  }
}
