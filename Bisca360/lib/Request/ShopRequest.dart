class ShopRequest{
  late var id;
  late String shopName;
  late bool active;
  late String address;
  late var contactNumber;
  late String shopType;
  late String description;
  late bool taxEnable;
  late String taxType;
  late var projectId;
  late String? projectName;
  late bool includedTax;
  late String usersPermissions;


  ShopRequest(
      this.id,
      this.shopName,
      this.active,
      this.address,
      this.contactNumber,
      this.shopType,
      this.description,
      this.taxEnable,
      this.taxType,
      this.gstNumber,
      this.panNumber,
      this.rounding,
      this.projectId,
      this.projectName,
      this.includedTax,
      this.usersPermissions,
      );

  @override
  String toString() {
    return '{id: $id, shopName: $shopName, active: $active, address: $address, contactNumber: $contactNumber, shopType: $shopType, description: $description, taxEnable: $taxEnable, taxType: $taxType, gstNumber: $gstNumber, panNumber: $panNumber, rounding: $rounding,projectId:$projectId, projectName:$projectName, includedTax:$includedTax, usersPermissions:$usersPermissions}';
  }

  late String? gstNumber;
  late String? panNumber;
  late String rounding;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'active': active,
      'address': address,
      'contactNumber': contactNumber,
      'shopType': shopType,
      'description': description,
      'taxEnable': taxEnable,
      'taxType': taxType,
      'gstNumber': gstNumber!.isNotEmpty ? gstNumber :'',
      'panNumber': panNumber!.isNotEmpty ? panNumber :'',
      'rounding': rounding,
      'projectId': projectId,
      'projectName': projectName!.isNotEmpty ? projectName :'',
      'includedTax': includedTax,
      'usersPermissions': usersPermissions,
    };
  }
}