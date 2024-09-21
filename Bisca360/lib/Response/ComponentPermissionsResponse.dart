class ComponentPermissionsResponse{
  late int id;
  late String mobileComponent;
  late String mobileComponentdesc;
  late String desktopComponent;
  late String desktopComponentdesc;
  late String permissionCode;
  late String permissionName;

  ComponentPermissionsResponse(
      this.id,
      this.mobileComponent,
      this.mobileComponentdesc,
      this.desktopComponent,
      this.desktopComponentdesc,
      this.permissionCode,
      this.permissionName);

  ComponentPermissionsResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        mobileComponent = json['mobileComponent'] ?? '',
        mobileComponentdesc = json['mobileComponentdesc'] ?? '',
        desktopComponent = json['desktopComponent'] ?? '',
        desktopComponentdesc = json['desktopComponentdesc'] ?? '',
        permissionCode = json['permissionCode'] ?? '',
        permissionName = json['permissionName'] ?? '';
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileComponent': mobileComponent,
      'mobileComponentdesc': mobileComponentdesc,
      'desktopComponent': desktopComponent,
      'desktopComponentdesc': desktopComponentdesc,
      'permissionCode': permissionCode,
      'permissionName': permissionName,
    };
  }
}