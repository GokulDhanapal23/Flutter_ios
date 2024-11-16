class RefreshResponse {
  late String accessToken;
  late String refreshToken;

  RefreshResponse({required this.accessToken, required this.refreshToken});

  // Factory method to create an instance from JSON
  RefreshResponse.fromJson(Map<String, dynamic> json) :
    accessToken = json['accessToken'] ?? '', // Provide default value if needed
    refreshToken = json['refreshToken'] ?? ''; // Provide default value if needed


  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
