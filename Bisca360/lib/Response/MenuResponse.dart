import 'ChildMenuResponse.dart';

class MenuResponse{
  late int id;
  late String name;
  late String link;
  late String icon;
  late String permission;
  late bool parent;
  late int parentId;
  late String type;

  MenuResponse(
      this.id,
      this.name,
      this.link,
      this.icon,
      this.permission,
      this.parent,
      this.parentId,
      this.type,
      this.position,
      this.title,
      this.menuComponents,
      this.menuKey,
      this.children);

  MenuResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        name = json['name'] ?? '',
        link = json['link'] ?? '',
        icon = json['icon'] ?? '',
        permission = json['permission'] ?? '',
        parent = json['parent'] ?? false,
        parentId = json['parentId'] ?? 0,
        type = json['type'] ?? '',
        position = json['position'] ?? 0,
        title = json['title'] ?? '',
        menuComponents = json['menuComponents'] ?? '',
        menuKey = json['menuKey'] ?? '',
        children = (json['children'] as List<dynamic>?)
            ?.map((e) => ChildMenuResponse.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];

  late int position;
  late String title;
  late String menuComponents;
  late String menuKey;
  late List<ChildMenuResponse> children;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'link': link,
      'icon': icon,
      'permission': permission,
      'parent': parent,
      'parentId': parentId,
      'type': type,
      'position': position,
      'title': title,
      'menuComponents': menuComponents,
      'menuKey': menuKey,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }


}