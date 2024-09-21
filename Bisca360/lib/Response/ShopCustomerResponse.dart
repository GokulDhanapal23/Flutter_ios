class ShopCustomerResponse{
  late int id;
  late String shopName;
  late String customerName;
  late int mobileNumber;
  late String gstNumber;

  ShopCustomerResponse({
    required this.id,
    required this.shopName,
    required this.customerName,
    required this.mobileNumber,
    required this.gstNumber,
  });

  @override
  String toString() {
    return 'ShopCustomerResponse{id: $id, shopName: $shopName, customerName: $customerName, mobileNumber: $mobileNumber, gstNumber: $gstNumber}';
  }

  factory ShopCustomerResponse.fromJson(Map<String, dynamic> json) {
    return ShopCustomerResponse(
      id: json['id'] ?? 0,
      shopName: json['shopName'] ?? '',
      customerName: json['customerName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? 0,
      gstNumber: json['gstNumber'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'gstNumber': gstNumber,
    };
  }

}