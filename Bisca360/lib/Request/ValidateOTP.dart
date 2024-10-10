class ValidateOTP {
  late String code;
  late var mobileNumber;

  ValidateOTP({required this.code, required this.mobileNumber});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'mobileNumber': mobileNumber,
    };
  }

  factory ValidateOTP.fromJson(Map<String, dynamic> json) {
    return ValidateOTP(
      code: json['code'],
      mobileNumber: json['mobileNumber'],
    );
  }

  @override
  String toString() {
    return 'ValidateOTP{code: $code, mobileNumber: $mobileNumber}';
  }
}
