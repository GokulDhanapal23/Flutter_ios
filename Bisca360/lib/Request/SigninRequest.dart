class SigninRequest{
  late int mobileNumber;
  late int ownerId;
  late String password;

  SigninRequest(this.mobileNumber, this.ownerId, this.password);

  Map<String, dynamic> toJson() => {
    'mobileNumber': mobileNumber,
    'ownerId': ownerId,
    'password': password,
  };
}