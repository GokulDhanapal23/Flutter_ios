import 'dart:io';

import 'UserComponentPermissionResponse.dart';

class SigninResponse{
   late int timestamp;
   late int id;
   late String accessToken;
   late String message;
   late String userName;
   late String employeeId;
   late String lastName;
   late String email;
   late int mobileNumber;
   late String companyName;
   late String profileUri;
   late String companyProfileUri;
   late String roleCode;
   late String roleName;
   late int ownerId;
   late bool owner;
   late bool accountActive;
   late bool passwordPresent;
   late bool storeEnabled;
   late UserComponentPermissionResponse userRolePermissions;
   late String status;

   SigninResponse(
       this.timestamp,
       this.id,
       this.accessToken,
       this.message,
       this.userName,
       this.employeeId,
       this.lastName,
       this.email,
       this.mobileNumber,
       this.companyName,
       this.profileUri,
       this.companyProfileUri,
       this.roleCode,
       this.roleName,
       this.ownerId,
       this.owner,
       this.accountActive,
       this.passwordPresent,
       this.storeEnabled,
       this.userRolePermissions,
       this.status);

   SigninResponse.fromJson(Map<String, dynamic> json)
   : timestamp = json['timestamp'] ?? "",
          id = json['id'] ?? "",
          accessToken = json['accessToken'] ?? "",
          message = json['message'] ?? "",
          userName = json['userName'] ?? "",
          employeeId = json['employeeId'] ?? "",
          lastName = json['lastName'] ?? "",
          email = json['email'] ?? "",
          mobileNumber = json['mobileNumber'] ?? "",
          companyName = json['companyName'] ?? "",
          profileUri = json['profileUri'] ?? "",
          companyProfileUri = json['companyProfileUri'] ?? "",
          roleCode = json['roleCode'] ?? "",
          roleName = json['roleName'] ?? "",
          ownerId = json['ownerId'] ?? "",
          owner = json['owner'] ?? "",
          accountActive = json['accountActive'] ?? "",
          passwordPresent = json['passwordPresent'] ?? "",
          storeEnabled = json['storeEnabled'] ?? "",
          userRolePermissions = json['userRolePermissions'] != null
              ? UserComponentPermissionResponse.fromJson(json['userRolePermissions'])
              : UserComponentPermissionResponse([], {}),
          status = json['status'] ?? "";


   Map<String, dynamic> toJson() {
      return {
         'timestamp': timestamp,
         'id': id,
         'accessToken': accessToken,
         'message': message,
         'userName': userName,
         'employeeId': employeeId,
         'lastName': lastName,
         'email': email,
         'mobileNumber': mobileNumber,
         'companyName': companyName,
         'profileUri': profileUri,
         'companyProfileUri': companyProfileUri,
         'roleCode': roleCode,
         'roleName': roleName,
         'ownerId': ownerId,
         'owner': owner,
         'accountActive': accountActive,
         'passwordPresent': passwordPresent,
         'storeEnabled': storeEnabled,
         'userRolePermissions': userRolePermissions.toJson(),
         'status': status,
      };
   }
   @override
   String toString() {
      return 'SigninResponse('
          'timestamp: $timestamp, '
          'id: $id, '
          'accessToken: $accessToken, '
          'message: $message, '
          'userName: $userName, '
          'employeeId: $employeeId, '
          'lastName: $lastName, '
          'email: $email, '
          'mobileNumber: $mobileNumber, '
          'companyName: $companyName, '
          'profileUri: $profileUri, '
          'companyProfileUri: $companyProfileUri, '
          'roleCode: $roleCode, '
          'roleName: $roleName, '
          'ownerId: $ownerId, '
          'owner: $owner, '
          'accountActive: $accountActive, '
          'passwordPresent: $passwordPresent, '
          'storeEnabled: $storeEnabled, '
          'userRolePermissions: $userRolePermissions, '
          'status: $status'
          ')';
   }
}