class CategoryResponse{
  late var id;
  late String categoryName;

  CategoryResponse(this.id, this.categoryName);

  @override
  String toString() {
    return 'CategoryResponse{id: $id, categoryName: $categoryName}';
  }
  CategoryResponse.fromJson(Map<String,dynamic> json)
  :id = json['id'] ?? 0,
  categoryName = json['categoryName'] ?? '';

  Map<String,dynamic> toJson() {
    return {
      'id': id,
      'categoryName' : categoryName
    };
  }
}