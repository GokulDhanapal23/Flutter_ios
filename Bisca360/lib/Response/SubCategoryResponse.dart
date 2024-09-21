class SubCategoryResponse {
  late var id;
  late String subCategoryName;

  SubCategoryResponse(this.id, this.subCategoryName);

  @override
  String toString() {
    return 'SubCategoryResponse{id: $id, subCategoryName: $subCategoryName}';
  }

  SubCategoryResponse.fromJson(Map<String,dynamic> json)
      :id = json['id'] ?? 0,
        subCategoryName = json['subCategoryName'] ?? '';

  Map<String,dynamic> toJson() {
    return {
      'id': id,
      'subCategoryName' : subCategoryName
    };
  }
}