import 'dart:convert';


class ShopSalesDetailsResponse {
  late String shopName;
  late String paymentType;
  late String dateAndTime;
  late Object listSellingData;
  late double totalPrice;
  late double totalTax;
  late String billNumber;
  late double netTotalPrice;

  ShopSalesDetailsResponse(
      this.shopName,
      this.paymentType,
      this.dateAndTime,
      this.listSellingData,
      this.totalPrice,
      this.totalTax,
      this.billNumber,
      this.netTotalPrice);

  factory ShopSalesDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopSalesDetailsResponse(
      json['shopName'] as String,
      json['paymentType'] as String,
      json['dateAndTime'] as String,
      json['listSellingData'] as Object,
      (json['totalPrice'] as num).toDouble(),
      (json['totalTax'] as num).toDouble(),
      json['billNumber'] as String,
      (json['netTotalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'paymentType': paymentType,
      'dateAndTime': dateAndTime,
      'listSellingData': listSellingData,
      'totalPrice': totalPrice,
      'totalTax': totalTax,
      'billNumber': billNumber,
      'netTotalPrice': netTotalPrice,
    };
  }

  @override
  String toString() {
    return '{shopName: $shopName, paymentType: $paymentType, dateAndTime: $dateAndTime, listSellingData: $listSellingData, totalPrice: $totalPrice, totalTax: $totalTax, billNumber: $billNumber, netTotalPrice: $netTotalPrice}';
  }
}
