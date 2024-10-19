class ShopOrderClosedBill {
  late var id;
  late var shopId;
  late String orderNumber;
  late String tableNo;

  ShopOrderClosedBill({
    required this.id,
    required this.shopId,
    required this.orderNumber,
    required this.tableNo,
  });

  factory ShopOrderClosedBill.fromJson(Map<String, dynamic> json) {
    return ShopOrderClosedBill(
      id: json['id'],
      shopId: json['shopId'],
      orderNumber: json['orderNumber'],
      tableNo: json['tableNo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'orderNumber': orderNumber,
      'tableNo': tableNo,
    };
  }

  @override
  String toString() {
    return 'ShopOrderClosedBill{id: $id, shopId: $shopId, orderNumber: $orderNumber, tableNo: $tableNo}';
  }
}
