import 'MenuResponse.dart';
import 'UserRolePermissionResponse.dart';

class UserComponentPermissionResponse{

  late List<UserRolePermissionResponse> listRolePermissionResponses;
  late Map<String, List<MenuResponse>> userMenus;

  @override
  String toString() {
    return 'UserComponentPermissionResponse{listRolePermissionResponses: $listRolePermissionResponses, userMenus: $userMenus}';
  }
  UserComponentPermissionResponse.fromJson(Map<String, dynamic> json)
      : listRolePermissionResponses = (json['listRolePermissionResponses'] as List<dynamic>?)
      ?.map((e) => UserRolePermissionResponse.fromJson(e as Map<String, dynamic>))
      .toList() ?? [],
        userMenus = (json['userMenus'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, (v as List<dynamic>)
            .map((e) => MenuResponse.fromJson(e as Map<String, dynamic>))
            .toList())) ?? {};

  Map<String, dynamic> toJson() {
    return {
      'listRolePermissionResponses': listRolePermissionResponses
          .map((e) => e.toJson())
          .toList(),
      'userMenus': userMenus.map((k, v) => MapEntry(
        k,
        v.map((r) => r.toJson()).toList(),
      )),
    };
  }
  UserComponentPermissionResponse(
      this.listRolePermissionResponses, this.userMenus);
}