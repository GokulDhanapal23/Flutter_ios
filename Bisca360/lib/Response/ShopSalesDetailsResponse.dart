import 'dart:convert';

class ShopSalesDetailsResponse {
  late String shopName;
  late String paymentType;
  late String dateAndTime;
  late Object listSellingData; // Consider using a more specific type if possible
  late double totalPrice;
  late double totalTax;
  late String billNumber;
  late double netTotalPrice;
  late String customerName;
  late double discountPrice;
  late double grandTotalPrice;
  late int id;
  late String status;
  late String closedStatus;

  // Updated constructor
  ShopSalesDetailsResponse({
    required this.shopName,
    required this.paymentType,
    required this.dateAndTime,
    required this.listSellingData,
    required this.totalPrice,
    required this.totalTax,
    required this.billNumber,
    required this.netTotalPrice,
    required this.customerName,
    required this.discountPrice,
    required this.grandTotalPrice,
    required this.id,
    required this.status,
    required this.closedStatus,
  });

  // Updated fromJson factory
  factory ShopSalesDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopSalesDetailsResponse(
      shopName: json['shopName'] as String,
      paymentType: json['paymentType'] as String,
      dateAndTime: json['dateAndTime'] as String,
      listSellingData: json['listSellingData'] as Object,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      billNumber: json['billNumber'] as String,
      netTotalPrice: (json['netTotalPrice'] as num).toDouble(),
      customerName: json['customerName'] as String,
      discountPrice: (json['discountPrice'] as num).toDouble(),
      grandTotalPrice: (json['grandTotalPrice'] as num).toDouble(),
      id: json['id'] as int,
      status: json['status'] as String,
      closedStatus: json['closedStatus'] as String,
    );
  }

  // Updated toJson method
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
      'customerName': customerName,
      'discountPrice': discountPrice,
      'grandTotalPrice': grandTotalPrice,
      'id': id,
      'status': status,
      'closedStatus': closedStatus,
    };
  }

  @override
  String toString() {
    return '{shopName: $shopName, paymentType: $paymentType, dateAndTime: $dateAndTime, listSellingData: $listSellingData, totalPrice: $totalPrice, totalTax: $totalTax, billNumber: $billNumber, netTotalPrice: $netTotalPrice, customerName: $customerName, discountPrice: $discountPrice, grandTotalPrice: $grandTotalPrice, id: $id, status: $status, closedStatus: $closedStatus}';
  }
}
