class RequestOtp {
  late String mobileNumber;
  late var ownerId;

  RequestOtp({required this.mobileNumber, required this.ownerId});


  Map<String, dynamic> toJson() {
    return {
      'mobileNumber': mobileNumber,
      'ownerId': ownerId,
    };
  }

  factory RequestOtp.fromJson(Map<String, dynamic> json) {
    return RequestOtp(
      mobileNumber: json['mobileNumber'],
      ownerId: json['ownerId'],
    );
  }

  @override
  String toString() {
    return 'RequestOtp{mobileNumber: $mobileNumber, ownerId: $ownerId}';
  }
}
