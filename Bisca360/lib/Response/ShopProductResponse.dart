class ShoppProductResponse {
  late String categoryName;
  late String subcategoryName;
  late var categoryId;
  late var subcategoryId;
  late var id;
  late String shopName;
  late var ownerId;
  late String product;
  late var productUid;
  late String unit;
  late var price;
  late int quantity;
  late bool status;

  ShoppProductResponse(
      this.categoryName,
      this.subcategoryName,
      this.categoryId,
      this.subcategoryId,
      this.id,
      this.shopName,
      this.ownerId,
      this.product,
      this.productUid,
      this.unit,
      this.price,
      this.quantity,
      this.status,
      );

  @override
  String toString() {
    return 'ShoppProductResponse{categoryName: $categoryName, subcategoryName: $subcategoryName, categoryId: $categoryId, subcategoryId: $subcategoryId, id: $id, shopName: $shopName, ownerId: $ownerId, product: $product,, productUid: $productUid, unit: $unit, price: $price, quantity: $quantity, status: $status}';
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
      json['productUid'],
      json['unit'] as String,
      json['price'],
      json['quantity'] as int,
      json['status']
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
      'productUid': productUid,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'status': status,
    };
  }
}