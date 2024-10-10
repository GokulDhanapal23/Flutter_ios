class ProjectRequest {
  int? id;
  double advanceAmount;
  bool contract;
  double contractAmount;
  String description;
  double latitude;
  String locationInfo;
  double longitude;
  String? ownerMobileNumber;
  String siteArea;
  String siteName;
  String siteOwner;
  String siteStatusCode;

  // Constructor
  ProjectRequest({
    this.id,
    required this.advanceAmount,
    required this.contract,
    required this.contractAmount,
    required this.description,
    required this.latitude,
    required this.locationInfo,
    required this.longitude,
    required this.ownerMobileNumber,
    required this.siteArea,
    required this.siteName,
    required this.siteOwner,
    required this.siteStatusCode,
  });

  // From JSON
  factory ProjectRequest.fromJson(Map<String, dynamic> json) {
    return ProjectRequest(
      id: json['id'] as int?,
      advanceAmount: (json['advanceAmount'] as num).toDouble(),
      contract: json['contract'] as bool,
      contractAmount: (json['contractAmount'] as num).toDouble(),
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      locationInfo: json['locationInfo'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      ownerMobileNumber: json['ownerMobileNumber'] as String?,
      siteArea: json['siteArea'] as String,
      siteName: json['siteName'] as String,
      siteOwner: json['siteOwner'] as String,
      siteStatusCode: json['siteStatusCode'] as String,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advanceAmount': advanceAmount,
      'contract': contract,
      'contractAmount': contractAmount,
      'description': description,
      'latitude': latitude,
      'locationInfo': locationInfo,
      'longitude': longitude,
      'ownerMobileNumber': ownerMobileNumber,
      'siteArea': siteArea,
      'siteName': siteName,
      'siteOwner': siteOwner,
      'siteStatusCode': siteStatusCode,
    };
  }

  @override
  String toString() {
    return 'ProjectRequest{id: $id, advanceAmount: $advanceAmount, contract: $contract, contractAmount: $contractAmount, description: $description, latitude: $latitude, locationInfo: $locationInfo, longitude: $longitude, ownerMobileNumber: $ownerMobileNumber, siteArea: $siteArea, siteName: $siteName, siteOwner: $siteOwner, siteStatusCode: $siteStatusCode}';
  }
}
