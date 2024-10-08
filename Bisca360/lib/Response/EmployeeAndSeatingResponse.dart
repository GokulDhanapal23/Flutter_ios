class EmployeeAndSeatingResponse {
  late List<String> employees;
  late List<String> seating;

  EmployeeAndSeatingResponse({
    required this.employees,
    required this.seating,
  });

  factory EmployeeAndSeatingResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAndSeatingResponse(
      employees: List<String>.from(json['employees'] ?? []),
      seating: List<String>.from(json['seating'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employees': employees,
      'seating': seating,
    };
  }

  @override
  String toString() {
    return 'EmployeeAndSeatingResponse{employees: $employees, seating: $seating}';
  }
}
