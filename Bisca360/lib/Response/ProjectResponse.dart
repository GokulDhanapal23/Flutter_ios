class ProjectResponse{
  late int id;
  late String siteName;
  late String siteOwner;
  late String siteArea;
  late int ownerMobileNumber;
  late bool contract;
  late double contractAmount;
  late double advanceAmount;
  late double contractBalance;
  late double siteExpenses;
  late String siteStatusCode;
  late String siteStatusName;
  late double availableBalance;
  late String description;
  late double latitude;
  late double longitude;
  late String locationInfo;

  ProjectResponse({
    required this.id,
    required this.siteName,
    required this.siteOwner,
    required this.siteArea,
    required this.ownerMobileNumber,
    required this.contract,
    required this.contractAmount,
    required this.advanceAmount,
    required this.contractBalance,
    required this.siteExpenses,
    required this.siteStatusCode,
    required this.siteStatusName,
    required this.availableBalance,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationInfo,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      id: json['id'] ?? 0,
      siteName: json['siteName'] ?? '',
      siteOwner: json['siteOwner'] ?? '',
      siteArea: json['siteArea'] ?? '',
      ownerMobileNumber: json['ownerMobileNumber'] ?? 0,
      contract: json['contract'] ?? false,
      contractAmount: json['contractAmount'] ?? 0.0,
      advanceAmount: json['advanceAmount'] ?? 0.0,
      contractBalance: json['contractBalance'] ?? 0.0,
      siteExpenses: json['siteExpenses'] ?? 0.0,
      siteStatusCode: json['siteStatusCode'] ?? '',
      siteStatusName: json['siteStatusName'] ?? '',
      availableBalance: json['availableBalance'] ?? 0.0,
      description: json['description'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      locationInfo: json['locationInfo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteName': siteName,
      'siteOwner': siteOwner,
      'siteArea': siteArea,
      'ownerMobileNumber': ownerMobileNumber,
      'contract': contract,
      'contractAmount': contractAmount,
      'advanceAmount': advanceAmount,
      'contractBalance': contractBalance,
      'siteExpenses': siteExpenses,
      'siteStatusCode': siteStatusCode,
      'siteStatusName': siteStatusName,
      'availableBalance': availableBalance,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'locationInfo': locationInfo,
    };
  }

  @override
  String toString() {
    return 'ProjectResponse{id: $id, siteName: $siteName, siteOwner: $siteOwner, siteArea: $siteArea, ownerMobileNumber: $ownerMobileNumber, contract: $contract, contractAmount: $contractAmount, advanceAmount: $advanceAmount, contractBalance: $contractBalance, siteExpenses: $siteExpenses, siteStatusCode: $siteStatusCode, siteStatusName: $siteStatusName, availableBalance: $availableBalance, description: $description, latitude: $latitude, longitude: $longitude, locationInfo: $locationInfo}';
  }

}