import 'package:ab_pharmacy/Modal/Products.dart';

class Cart {
  Cart({
    required this.id,
    required this.quantity,
    required this.totalPrice,
    required this.product,
  });
  late final int id;
  late int quantity;
  late int totalPrice;
  late final Product product;

  late bool isLoading = false;

  void updateLoading(bool status) {
    isLoading = status;
  }

  void updateQuantity(int increment) {
    if (increment == 1) {
      quantity++;
    } else {
      quantity--;
    }

    if(product.discountPrice == 0) {
      print(quantity);
      totalPrice = quantity * product.price;
    }else if(product.discountPrice != 0){
      totalPrice = quantity * product.discountPrice;
    }
  }

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    quantity = json['quantity'];
    totalPrice = json['totalPrice'];
    product = Product.fromJson(json['product']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['quantity'] = quantity;
    _data['totalPrice'] = totalPrice;
    _data['product'] = product.toJson();
    return _data;
  }
}
