class MeasurementRequest {
  late var id;
  late String measurementCode;
  late String measurementName;
  late String description;
  late bool active;

  MeasurementRequest( {
    required this.id,
    required this.measurementCode,
    required this.measurementName,
    required this.description,
    required this.active
});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'measurementCode': measurementCode,
      'measurementName': measurementName,
      'description': description,
      'active': active,
    };
  }

  factory MeasurementRequest.fromJson(Map<String, dynamic> json) {
    return MeasurementRequest(
      id: json['id'],
      measurementCode: json['measurementCode'],
      measurementName: json['measurementName'],
      description: json['description'],
      active: json['active'],
    );
  }

  @override
  String toString() {
    return 'MeasurementRequest{id: $id, measurementCode: $measurementCode, measurementName: $measurementName, description: $description, active: $active}';
  }
}