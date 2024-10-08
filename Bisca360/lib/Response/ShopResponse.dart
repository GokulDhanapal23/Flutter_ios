import 'OwnerTaxResponse.dart';

class Shopresponse{
  late int id;
  late String shopName;
  late int ownerId;
  late bool active;
  late int contactNumber;
  late String profileUri;
  late String address;
  late String shopType;
  late String description;
  late bool taxEnable;
  late bool includedTax;
  late List<OwnerTaxResponse> listOwnerTaxResponse;
  late String gstNumber;
  late var projectId;
  late String? projectName;

  Shopresponse(
      this.id,
      this.shopName,
      this.ownerId,
      this.active,
      this.contactNumber,
      this.profileUri,
      this.address,
      this.shopType,
      this.description,
      this.taxEnable,
      this.includedTax,
      this.listOwnerTaxResponse,
      this.gstNumber,
      this.panNumber,
      this.rounding,
      this.projectId,
      this.projectName);

  @override
  String toString() {
    return 'Shopresponse{id: $id, shopName: $shopName, ownerId: $ownerId, active: $active, contactNumber: $contactNumber, profileUri: $profileUri, address: $address, shopType: $shopType, description: $description, taxEnable: $taxEnable, includedTax: $includedTax, listOwnerTaxResponse: $listOwnerTaxResponse, gstNumber: $gstNumber, panNumber: $panNumber, rounding: $rounding, projectId: $projectId, projectName: $projectName}';
  }

  Shopresponse.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        shopName = json['shopName'] ?? '',
        ownerId = json['ownerId'] ?? 0,
        active = json['active'] ?? false,
        contactNumber = json['contactNumber'] ?? 0,
        profileUri = json['profileUri'] ?? '',
        address = json['address'] ?? '',
        shopType = json['shopType'] ?? '',
        description = json['description'] ?? '',
        taxEnable = json['taxEnable'] ?? false,
        includedTax = json['includedTax'] ?? false,
        listOwnerTaxResponse = (json['listOwnerTaxResponse'] as List<dynamic>?)
            ?.map((e) => OwnerTaxResponse.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        gstNumber = json['gstNumber'] ?? '',
        panNumber = json['panNumber'] ?? '',
        rounding = json['rounding'] ?? '',
        projectId = json['projectId'] ?? '',
         projectName = json['projectName'] ?? '';
  late String panNumber;

  late String rounding;
}