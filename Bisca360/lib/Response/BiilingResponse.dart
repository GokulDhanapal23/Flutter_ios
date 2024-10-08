import 'dart:convert';
import 'ShopSalesDetailsResponse.dart';

class BillingResponse {
  late List<ShopSalesDetailsResponse> listShopSalesDetailsResponse;
  late int billingCount;
  late int deletedCount;
  late double totalTax;
  late double totalPrice;
  late double netTotalPrice;
  late double grandTotalPrice;

  BillingResponse(
      this.listShopSalesDetailsResponse,
      this.billingCount,
      this.totalTax,
      this.totalPrice,
      this.netTotalPrice,
      this.deletedCount,
      this.grandTotalPrice,
      );

  factory BillingResponse.fromJson(Map<String, dynamic> json) {
    return BillingResponse(
      (json['listShopSalesDetailsResponse'] as List<dynamic>?)
          ?.map((item) => ShopSalesDetailsResponse.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      json['billingCount'] as int,
      (json['totalTax'] as num).toDouble(),
      (json['totalPrice'] as num).toDouble(),
      (json['netTotalPrice'] as num).toDouble(),
      json['deletedCount'] as int,
      json['grandTotalPrice'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listShopSalesDetailsResponse': listShopSalesDetailsResponse.map((item) => item.toJson()).toList(),
      'billingCount': billingCount,
      'totalTax': totalTax,
      'totalPrice': totalPrice,
      'netTotalPrice': netTotalPrice,
      'deletedCount': deletedCount,
      'grandTotalPrice': grandTotalPrice,
    };
  }

  @override
  String toString() {
    return '{listShopSalesDetailsResponse: $listShopSalesDetailsResponse, billingCount: $billingCount, totalTax: $totalTax, totalPrice: $totalPrice, netTotalPrice: $netTotalPrice, deletedCount: $deletedCount, grandTotalPrice: $grandTotalPrice}';
  }
}
