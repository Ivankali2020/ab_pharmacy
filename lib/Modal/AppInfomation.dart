class AppInfomation {
  AppInfomation({
    required this.name,
    required this.email,
    required this.phone,
    required this.messagerId,
    required this.pageId,
    required this.address,
  });
  late final String name;
  late final String email;
  late final String? phone;
  late final String? messagerId;
  late final String? pageId;
  late final String? address;

  AppInfomation.fromJson(Map<String, dynamic> json){
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    messagerId = json['messager_id'];
    pageId = json['page_id'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['email'] = email;
    _data['phone'] = phone;
    _data['messager_id'] = messagerId;
    _data['page_id'] = pageId;
    _data['address'] = address;
    return _data;
  }
}