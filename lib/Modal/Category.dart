class Category {
  Category({
    required this.id,
    required this.name,
    required this.photo,
    required this.subCategories,
  });
  late final int id;
  late final String name;
  late final String photo;
  late final List<SubCategories> subCategories;

  Category.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    photo = json['photo'];
    subCategories = List.from(json['subCategories']).map((e)=>SubCategories.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['photo'] = photo;
    _data['subCategories'] = subCategories.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class SubCategories {
  SubCategories({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  SubCategories.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}