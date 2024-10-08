class CategoryResponse {
  late var id;
  late String categoryName;
  late List<String> productName;

  CategoryResponse(this.id, this.categoryName, [this.productName = const []]);

  @override
  String toString() {
    return 'CategoryResponse{id: $id, categoryName: $categoryName, productName: $productName}';
  }

  CategoryResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        categoryName = json['categoryName'] ?? '',
        productName = List<String>.from(json['productName'] ?? []);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'productName': productName,
    };
  }
}
