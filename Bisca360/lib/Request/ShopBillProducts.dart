class ShopBillProducts{

  late String item;
  late String units;
  late double price;
  late int quantity;
  late double totalPriceList;

  ShopBillProducts(
      this.item, this.units, this.price, this.quantity, this.totalPriceList);

  // @override
  // String toString() {
  //   return '{items: $items, units: $units, price: $price, quantity: $quantity, totalPriceList: $totalPriceList}';
  // }
  factory ShopBillProducts.fromJson(Map<String, dynamic> json) {
    return ShopBillProducts(
      json['item'],
      json['units'],
      (json['price']),
      (json['quantity']),
      (json['totalPriceList']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'units': units,
      'price': price,
      'quantity': quantity,
      'totalPriceList': totalPriceList,
    };
  }
}