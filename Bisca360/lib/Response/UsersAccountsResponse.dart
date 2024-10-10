

import 'dart:core';

class UsersAccountsResponse{
  late String userName;

  @override
  String toString() {
    return 'UsersAccountsResponse{userName: $userName, organizationName: $organizationName, mpinEnabled: $mpinEnabled, roleName: $roleName, id: $id, mobileNumber: $mobileNumber, ownerId: $ownerId, owner: $owner}';
  }

  late String organizationName;
  late bool mpinEnabled;
  late String roleName;
  late int id;
  late var mobileNumber;
  late int ownerId;
  late bool owner;

  UsersAccountsResponse(this.userName, this.organizationName, this.mpinEnabled,
      this.roleName, this.id, this.mobileNumber, this.ownerId, this.owner);

  UsersAccountsResponse.fromJson(Map<String, dynamic> json)
  : userName = json['userName'] ?? "",
        organizationName = json['organizationName'] ?? "",
        mpinEnabled = json['mpinEnabled'] ?? "",
        roleName = json['roleName'] ?? "",
        id = json['id'] ?? "",
        mobileNumber = json['mobileNumber'] ?? "",
        ownerId = json['ownerId'] ?? "",
        owner = json['owner'] ?? "";
}