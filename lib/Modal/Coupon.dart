class Coupon {
 late final  int id;
 late final  String code;
 late final  int amount;

  Coupon({required this.id, required this.code, required this.amount});

  Coupon.fromJson(Map<String, dynamic> json){
    id = json['id'];
    code = json['code'];
    amount = json['amount'];
  }
}
