class ShoppProductResponse {
  late String categoryName;
  late String subcategoryName;
  late var categoryId;
  late var subcategoryId;
  late var id;
  late String shopName;
  late var ownerId;
  late String product;
  late String unit;
  late var price;
  late int quantity;

  ShoppProductResponse(
      this.categoryName,
      this.subcategoryName,
      this.categoryId,
      this.subcategoryId,
      this.id,
      this.shopName,
      this.ownerId,
      this.product,
      this.unit,
      this.price,
      this.quantity);

  @override
  String toString() {
    return 'ShoppProductResponse{categoryName: $categoryName, subcategoryName: $subcategoryName, categoryId: $categoryId, subcategoryId: $subcategoryId, id: $id, shopName: $shopName, ownerId: $ownerId, product: $product, unit: $unit, price: $price, quantity: $quantity}';
  }
  factory ShoppProductResponse.fromJson(Map<String, dynamic> json) {
    return ShoppProductResponse(
      json['categoryName'] as String,
      json['subcategoryName'] as String,
      json['categoryId'],
      json['subcategoryId'],
      json['id'],
      json['shopName'] as String,
      json['ownerId'],
      json['product'] as String,
      json['unit'] as String,
      json['price'],
      json['quantity'] as int,
    );
  }

  // Convert ShoppProductResponse object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'subcategoryName': subcategoryName,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'id': id,
      'shopName': shopName,
      'ownerId': ownerId,
      'product': product,
      'unit': unit,
      'price': price,
      'quantity': quantity,
    };
  }
}