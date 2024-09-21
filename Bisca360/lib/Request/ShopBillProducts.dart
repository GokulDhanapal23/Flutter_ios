class ShopBillProducts{

  late String items;
  late String units;
  late double price;
  late int quantity;
  late double totalPriceList;

  ShopBillProducts(
      this.items, this.units, this.price, this.quantity, this.totalPriceList);

  // @override
  // String toString() {
  //   return '{items: $items, units: $units, price: $price, quantity: $quantity, totalPriceList: $totalPriceList}';
  // }
  factory ShopBillProducts.fromJson(Map<String, dynamic> json) {
    return ShopBillProducts(
      json['items'],
      json['units'],
      (json['price']),
      (json['quantity']),
      (json['totalPriceList']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'units': units,
      'price': price,
      'quantity': quantity,
      'totalPriceList': totalPriceList,
    };
  }
}