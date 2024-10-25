class ShopBillProducts {
  late String item;
  late String units;
  late double price;
  late int quantity;
  late double totalPriceList;
  late String status;

  ShopBillProducts(
      this.item, this.units, this.price, this.quantity, this.totalPriceList, this.status);

  @override
  String toString() {
    return '{item: $item, units: $units, price: $price, quantity: $quantity, totalPriceList: $totalPriceList, status: $status}';
  }

  factory ShopBillProducts.fromJson(Map<String, dynamic> json) {
    return ShopBillProducts(
      json['item'] ?? '',
      json['units'] ?? '',
      (json['price'] as num).toDouble(),
      (json['quantity'] is int)
          ? json['quantity']
          : (json['quantity'] as double).toInt(),
      (json['totalPriceList'] as num).toDouble(),
      json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'units': units,
      'price': price,
      'quantity': quantity,
      'totalPriceList': totalPriceList,
      'status': status,
    };
  }
}