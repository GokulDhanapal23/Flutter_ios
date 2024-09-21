class DefaultResponse{
  late String message;
  late String roleName;
  late String status;
  late String shopBillNo;
  late int timestamp;
  late int uid;
  late String userName;

  DefaultResponse.response(this.message, this.status, this.timestamp, this.uid);
  DefaultResponse.response1(this.timestamp, this.message, this.shopBillNo, this.status);

  factory DefaultResponse.fromJson(Map<String, dynamic> json) {
    return DefaultResponse.response(
      json['message'] as String,
      json['status'] as String,
      json['timestamp'] as int,
      json['uid'] as int,
    );
  }
  factory DefaultResponse.fromJson1(Map<String, dynamic> json) {
    return DefaultResponse.response(
      json['timestamp'],
      json['message'] ,
      json['shopBillNo'],
      json['status'] ,
    );
  }
}