class Payment {
  Payment({
    required this.id,
    required this.name,
    required this.account,
    required this.photo,
  });
  late final int id;
  late final String name;
  late final String account;
  late final String photo;

  Payment.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    account = json['account'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['account'] = account;
    _data['photo'] = photo;
    return _data;
  }
}