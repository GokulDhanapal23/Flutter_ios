class BillInvoiceTaxResponse {
  late String taxType;
  late double amount;
  late double taxPercentage; // Fixed typo from `taxPersentage` to `taxPercentage`
  late double taxPrice;

  BillInvoiceTaxResponse({
    required this.taxType,
    required this.amount,
    required this.taxPercentage,
    required this.taxPrice,
  });

  factory BillInvoiceTaxResponse.fromJson(Map<String, dynamic> json) {
    return BillInvoiceTaxResponse(
      taxType: json['taxType'],
      amount: json['amount'].toDouble(),
      taxPercentage: json['taxPercentage'].toDouble(),
      taxPrice: json['taxPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taxType': taxType,
      'amount': amount,
      'taxPercentage': taxPercentage,
      'taxPrice': taxPrice,
    };
  }
}
