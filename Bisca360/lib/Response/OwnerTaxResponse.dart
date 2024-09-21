class OwnerTaxResponse {
  late String taxType;
  late double taxPercentage;

  OwnerTaxResponse(this.taxType, this.taxPercentage);

  @override
  String toString() {
    return 'OwnerTaxResponse{taxType: $taxType, taxPercentage: $taxPercentage}';
  }

  OwnerTaxResponse.fromJson(Map<String, dynamic> json)
      : taxType = json['taxType'] ?? '',
        taxPercentage = json['taxPercentage']?.toDouble() ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'taxType': taxType,
      'taxPercentage': taxPercentage,
    };
  }
}
