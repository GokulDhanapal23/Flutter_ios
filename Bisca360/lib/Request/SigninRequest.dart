class SigninRequest {
  late int mobileNumber;
  late int ownerId;
  late String password;

  SigninRequest(this.mobileNumber, this.ownerId, this.password);

  // Convert a JSON map to a SigninRequest instance
  factory SigninRequest.fromJson(Map<String, dynamic> json) {
    return SigninRequest(
      json['mobileNumber'] as int,
      json['ownerId'] as int,
      json['password'] as String,
    );
  }

  // Convert a SigninRequest instance to a JSON map
  Map<String, dynamic> toJson() => {
    'mobileNumber': mobileNumber,
    'ownerId': ownerId,
    'password': password,
  };
}
