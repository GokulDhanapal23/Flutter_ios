class MeasurementResponse {
  late var id;
  late String measurementCode;
  late String measurementName;
  late String description;
  late bool active;
  late var ownerId;

  MeasurementResponse({
    required this.id,
    required this.measurementCode,
    required this.measurementName,
    required this.description,
    required this.active,
    required this.ownerId,
  });

  // Convert a JSON map into an instance of MeasurementResponse
  factory MeasurementResponse.fromJson(Map<String, dynamic> json) {
    return MeasurementResponse(
      id: json['id'],
      measurementCode: json['measurementCode'],
      measurementName: json['measurementName'],
      description: json['description'],
      active: json['active'],
      ownerId: json['ownerId'],
    );
  }

  // Convert an instance of MeasurementResponse into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'measurementCode': measurementCode,
      'measurementName': measurementName,
      'description': description,
      'active': active,
      'ownerId': ownerId,
    };
  }

  @override
  String toString() {
    return 'MeasurementResponse{id: $id, measurementCode: $measurementCode, measurementName: $measurementName, description: $description, active: $active, ownerId: $ownerId}';
  }
}
