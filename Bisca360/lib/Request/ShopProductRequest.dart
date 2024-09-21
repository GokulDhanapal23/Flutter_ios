import 'dart:convert';
import 'package:bisca360/Request/ShopProducts.dart';

class ShopProductRequest {
  late String categoryName;
  late String subcategoryName;
  late var categoryId;
  late var subcategoryId;
  late String shopName;
  late var ownerId;
  late List<ShopProducts> productList;


  ShopProductRequest(this.categoryName, this.subcategoryName, this.categoryId,
      this.subcategoryId, this.shopName, this.ownerId, this.productList);

  factory ShopProductRequest.fromJson(Map<String, dynamic> json) {
    return ShopProductRequest(
      json['categoryName'] as String,
      json['subcategoryName'] as String,
      json['categoryId'],
      json['subcategoryId'],
      json['shopName'] as String,
      json['ownerId'],
      (json['productList'] as List<dynamic>)
          .map((item) => ShopProducts.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'subcategoryName': subcategoryName,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'shopName': shopName,
      'ownerId': ownerId,
      'productList': productList.map((product) => product.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ShopProductRequest{categoryName: $categoryName, subcategoryName: $subcategoryName, categoryId: $categoryId, subcategoryId: $subcategoryId, shopName: $shopName, ownerId: $ownerId, productList: $productList}';
  }
}
