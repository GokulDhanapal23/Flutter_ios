import '../Response/OwnerTaxResponse.dart';
import 'ShopBillProducts.dart';

class   ShopOrderRequest {
  late var id;
  late String shopName;
  late List<ShopBillProducts> orderItemData;
  late double totalPrice;
  late double totalTax;
  late String shopType;
  late double netTotalPrice;
  late String orderDate;
  late String dayTime;
  late String tableNo;
  late String orderNumber;
  late var shopId;
  late String orderStatus;
  late String supplier;
  late int customerCount;
  late bool taxEnable;
  late List<OwnerTaxResponse> listTaxResponse;
  late var includedTax;

  ShopOrderRequest({
    required this.id,
    required this.shopName,
    required this.orderItemData,
    required this.totalPrice,
    required this.totalTax,
    required this.shopType,
    required this.netTotalPrice,
    required this.orderDate,
    required this.dayTime,
    required this.tableNo,
    required this.orderNumber,
    required this.shopId,
    required this.orderStatus,
    required this.supplier,
    required this.customerCount,
    required this.taxEnable,
    required this.listTaxResponse,
    required this.includedTax,
  });

  factory ShopOrderRequest.fromJson(Map<String, dynamic> json) {
    return ShopOrderRequest(
      id: json['id'] ?? '',
      shopName: json['shopName'] ?? '',
      orderItemData: (json['orderItemData'] as List)
          .map((item) => ShopBillProducts.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      shopType: json['shopType'] ?? '',
      netTotalPrice: (json['netTotalPrice'] as num).toDouble(),
      orderDate: json['orderDate'] ?? '',
      dayTime: json['dayTime'] ?? '',
      tableNo: json['tableNo'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      shopId: json['shopId'],
      orderStatus: json['orderStatus'] ?? '',
      supplier: json['supplier'] ?? '',
      customerCount: (json['customerCount'] is int)
          ? json['customerCount']
          : (json['customerCount'] as double).toInt(),
      taxEnable: json['taxEnable'] ?? false,
      listTaxResponse: (json['listTaxResponse'] as List)
          .map((item) => OwnerTaxResponse.fromJson(item))
          .toList(),
      includedTax: json['includedTax'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'orderItemData': orderItemData.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'totalTax': totalTax,
      'shopType': shopType,
      'netTotalPrice': netTotalPrice,
      'orderDate': orderDate,
      'dayTime': dayTime,
      'tableNo': tableNo,
      'orderNumber': orderNumber,
      'shopId': shopId,
      'orderStatus': orderStatus,
      'supplier': supplier,
      'customerCount': customerCount,
      'taxEnable': taxEnable,
      'listTaxResponse': listTaxResponse.map((item) => item.toJson()).toList(),
      'includedTax': includedTax,
    };
  }
}