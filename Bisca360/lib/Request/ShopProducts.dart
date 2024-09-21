class ShopProducts{
  late var id;
  late String product;
  late String unit;
  late var price;
  late var quantity;

  ShopProducts(this.id, this.product, this.unit, this.price, this.quantity);

  @override
  String toString() {
    return 'ShopProducts{id: $id, product: $product, unit: $unit, price: $price, quantity: $quantity}';
  }

  factory ShopProducts.fromJson(Map<String, dynamic> json) {
    return ShopProducts(
      json['id'],
      json['product'] ,
      json['unit'],
      json['price'],
      json['quantity'],
    );
  }

  // Convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'unit': unit,
      'price': price,
      'quantity': quantity,
    };
  }


}