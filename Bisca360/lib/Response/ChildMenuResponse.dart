class ChildMenuResponse{
  late int id;
  late String name;
  late String link;
  late String icon;
  late String permission;
  late bool parent;
  late int parentId;
  late String type;
  late int position;

  ChildMenuResponse(
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
      this.menuKey);

  late String title;
  late String menuComponents;
  late String menuKey;

  ChildMenuResponse.fromJson(Map<String, dynamic> json)
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
        menuKey = json['menuKey'] ?? '';

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
    };
  }
}