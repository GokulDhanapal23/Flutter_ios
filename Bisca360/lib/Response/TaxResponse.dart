class TaxResponse {
  late int id;
  late String taxType;
  late String taxLabel;

  TaxResponse({
    required this.id,
    required this.taxType,
    required this.taxLabel,
  });

  @override
  String toString() {
    return 'TaxResponse{id: $id, taxType: $taxType, taxLabel: $taxLabel}';
  }

  factory TaxResponse.fromJson(Map<String, dynamic> json) {
    return TaxResponse(
      id: json['id'] as int, // Ensure correct type casting
      taxType: json['taxType'] as String,
      taxLabel: json['taxLabel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taxType': taxType,
      'taxLabel': taxLabel,
    };
  }
}
