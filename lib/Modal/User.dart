class User {
  User({
    required this.id,
    required this.name,
    required this.credentials,
    required this.photo,
  });
  late final int id;
  late final String name;
  late final String credentials;
  late final String photo;

  User.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    credentials = json['credentials'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['credentials'] = credentials;
    _data['photo'] = photo;
    return _data;
  }
}