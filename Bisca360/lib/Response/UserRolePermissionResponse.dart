import 'ComponentPermissionsResponse.dart';

class UserRolePermissionResponse{
  late int id;

  UserRolePermissionResponse(
      this.id, this.pageCode, this.pageName, this.componentPermissions);

  late String pageCode;
  late String pageName;
  late List<ComponentPermissionsResponse> componentPermissions;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageCode': pageCode,
      'pageName': pageName,
      'componentPermissions': componentPermissions
          .map((e) => e.toJson())
          .toList(),
    };
  }
  UserRolePermissionResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        pageCode = json['pageCode'] ?? '',
        pageName = json['pageName'] ?? '',
        componentPermissions = (json['componentPermissions'] as List<dynamic>?)
            ?.map((e) => ComponentPermissionsResponse.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
}