class OrderDetail {
  OrderDetail({
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryFees,
    required this.shippingAddress,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.couponAmount,
    required this.userPaymentSlip,
    required this.paymentMethod,
    required this.cancelRefund,
    required this.totalPrice,
    required this.quantity,
    required this.date,
     this.note,
    required this.products,
  });
  late final String deliveryName;
  late final String deliveryPhone;
  late final int deliveryFees;
  late final String shippingAddress;
  late final String status;
  late final String latitude;
  late final String longitude;
  late final int couponAmount;
  late final String userPaymentSlip;
  late final PaymentMethod paymentMethod;
  late final CancelRefund cancelRefund;
  late final int totalPrice;
  late final int quantity;
  late final String date;
  late final Null note;
  late final List<Products> products;

  OrderDetail.fromJson(Map<String, dynamic> json){
    deliveryName = json['delivery_name'];
    deliveryPhone = json['delivery_phone'];
    deliveryFees = json['delivery_fees'];
    shippingAddress = json['shipping_address'];
    status = json['status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    couponAmount = json['coupon_amount'];
    userPaymentSlip = json['user_payment_slip'];
    paymentMethod = PaymentMethod.fromJson(json['payment_method']);
    cancelRefund = CancelRefund.fromJson(json['cancel_refund']);
    totalPrice = json['total_price'];
    quantity = json['quantity'];
    date = json['date'];
    note = null;
    products = List.from(json['products']).map((e)=>Products.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['delivery_name'] = deliveryName;
    _data['delivery_phone'] = deliveryPhone;
    _data['delivery_fees'] = deliveryFees;
    _data['shipping_address'] = shippingAddress;
    _data['status'] = status;
    _data['latitude'] = latitude;
    _data['longitude'] = longitude;
    _data['coupon_amount'] = couponAmount;
    _data['user_payment_slip'] = userPaymentSlip;
    _data['payment_method'] = paymentMethod.toJson();
    _data['cancel_refund'] = cancelRefund.toJson();
    _data['total_price'] = totalPrice;
    _data['quantity'] = quantity;
    _data['date'] = date;
    _data['note'] = note;
    _data['products'] = products.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class PaymentMethod {
  PaymentMethod({
     this.name,
     this.photo,
  });
  late final String? name;
  late final String? photo;

  PaymentMethod.fromJson(Map<String, dynamic> json){
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['photo'] = photo;
    return _data;
  }
}

class CancelRefund {
  CancelRefund({
     this.message,
     this.photo,
  });
  late final String? message;
  late final String? photo;

  CancelRefund.fromJson(Map<String, dynamic> json){
    message = json['message'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['photo'] = photo;
    return _data;
  }
}

class Products {
  Products({
    required this.name,
    required this.photo,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.price,
    required this.discountPrice,
    required this.discountPercentage,
    required this.totalPrice,
  });
  late final String name;
  late final String photo;
  late final String brand;
  late final String category;
  late final int quantity;
  late final int price;
  late final int discountPrice;
  late final int discountPercentage;
  late final int totalPrice;

  Products.fromJson(Map<String, dynamic> json){
    name = json['name'];
    photo = json['photo'];
    brand = json['brand'];
    category = json['category'];
    quantity = json['quantity'];
    price = json['price'];
    discountPrice = json['discount_price'];
    discountPercentage = json['discount_percentage'];
    totalPrice = json['total_price'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['photo'] = photo;
    _data['brand'] = brand;
    _data['category'] = category;
    _data['quantity'] = quantity;
    _data['price'] = price;
    _data['discount_price'] = discountPrice;
    _data['discount_percentage'] = discountPercentage;
    _data['total_price'] = totalPrice;
    return _data;
  }
}