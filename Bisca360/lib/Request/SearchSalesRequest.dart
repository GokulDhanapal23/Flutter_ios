class SearchSalesRequest {
  late String reportFor;
  late String reportType;
  late String fromDate;
  late String toDate;
  late String month;
  late String year;
  late int customerId;
  late String shopName;
  late String date;
  late int ownerId;

  // Constructor
  SearchSalesRequest({
    required this.reportFor,
    required this.reportType,
    required this.fromDate,
    required this.toDate,
    required this.month,
    required this.year,
    required this.customerId,
    required this.shopName,
    required this.date,
    required this.ownerId,
  });

  // FromJson method
  factory SearchSalesRequest.fromJson(Map<String, dynamic> json) {
    return SearchSalesRequest(
      reportFor: json['reportFor'] as String,
      reportType: json['reportType'] as String,
      fromDate: json['fromDate'] as String,
      toDate: json['toDate'] as String,
      month: json['month'] as String,
      year: json['year'] as String,
      customerId: json['customerId'] as int,
      shopName: json['shopName'] as String,
      date: json['date'] as String,
      ownerId: json['ownerId'] as int,
    );
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'reportFor': reportFor,
      'reportType': reportType,
      'fromDate': fromDate,
      'toDate': toDate,
      'month': month,
      'year': year,
      'customerId': customerId,
      'shopName': shopName,
      'date': date,
      'ownerId': ownerId,
    };
  }
}
