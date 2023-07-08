class Product {
  Product({
    required this.id,
    required this.name,
    required this.sellingUnit,
    required this.MOQ,
    required this.packingSize,
    required this.madeIn,
    required this.weight,
    required this.code,
    required this.price,
    required this.discountPrice,
    required this.discountPercentage,
    required this.stock,
    required this.detail,
    required this.categoryName,
    required this.brandName,
    required this.brandId,
    required this.categoryId,
    required this.photos,
  });
  late final int id;
  late final String name;
  late final String sellingUnit;
  late final int MOQ;
  late final String packingSize;
  late final String madeIn;
  late final String weight;
  late final String code;
  late final int price;
  late final int discountPrice;
  late final int discountPercentage;
  late final int stock;
  late final String detail;
  late final String categoryName;
  late final String brandName;
  late final int brandId;
  late final int categoryId;
  late final List<String> photos;

  Product.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    sellingUnit = json['selling_unit'];
    MOQ = json['MOQ'];
    packingSize = json['packing_size'];
    madeIn = json['made_in'];
    weight = json['weight'];
    code = json['code'];
    price = json['price'];
    discountPrice = json['discount_price'];
    discountPercentage = json['discount_percentage'];
    stock = json['stock'];
    detail = json['detail'];
    categoryName = json['category_name'];
    brandName = json['brand_name'];
    brandId = json['brand_id'];
    categoryId = json['category_id'];
    photos = List.castFrom<dynamic, String>(json['photos']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['selling_unit'] = sellingUnit;
    _data['MOQ'] = MOQ;
    _data['packing_size'] = packingSize;
    _data['made_in'] = madeIn;
    _data['weight'] = weight;
    _data['code'] = code;
    _data['price'] = price;
    _data['discount_price'] = discountPrice;
    _data['discount_percentage'] = discountPercentage;
    _data['stock'] = stock;
    _data['detail'] = detail;
    _data['category_name'] = categoryName;
    _data['brand_name'] = brandName;
    _data['brand_id'] = brandId;
    _data['category_id'] = categoryId;
    _data['photos'] = photos;
    return _data;
  }
}