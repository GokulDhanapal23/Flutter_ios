import 'dart:convert';
import 'dart:io';

import 'UsersAccountsResponse.dart';

class CheckMobileNumberResponse{
  late int timestamp;
  late String message;
  late List<UsersAccountsResponse> usersAccounts;
  late String status;

  CheckMobileNumberResponse(this.timestamp,this.message,this.usersAccounts,this.status);

  CheckMobileNumberResponse.fromJson(Map<String, dynamic> json)
  : timestamp = json['timestamp'] ?? "",
        message = json['message'] ?? "",
        usersAccounts = List<dynamic>.from(json['usersAccounts']).map((i) => UsersAccountsResponse.fromJson(i)).toList() ?? [],
        status = json['status'] ?? "";

  @override
  String toString() {
    return 'CheckMobileNumberResponse{timestamp: $timestamp, message: $message, usersAccounts: $usersAccounts, status: $status}';
  }
}

