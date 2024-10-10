class ProcessStatusResponse {
  late var id;
  late String statusName;
  late String statusCode;
  late String description;
  late bool active;

  // Named constructor
  ProcessStatusResponse.name(
      this.id, this.statusName, this.statusCode, this.description, this.active);

  // Factory constructor for creating a new ProcessStatusResponse instance from a map
  factory ProcessStatusResponse.fromJson(Map<String, dynamic> json) {
    return ProcessStatusResponse.name(
      json['id'],
      json['statusName'],
      json['statusCode'],
      json['description'],
      json['active'],
    );
  }

  // Method for converting a ProcessStatusResponse instance to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statusName': statusName,
      'statusCode': statusCode,
      'description': description,
      'active': active,
    };
  }

  @override
  String toString() {
    return 'ProcessStatusResponse{id: $id, statusName: $statusName, statusCode: $statusCode, description: $description, active: $active}';
  }
}
