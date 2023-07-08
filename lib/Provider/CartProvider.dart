import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ab_pharmacy/Helper/Http.dart';
import 'package:ab_pharmacy/Modal/Cart.dart';
import 'package:ab_pharmacy/Modal/Products.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Cart> _carts = [];
  List<Cart> get carts {
    return [..._carts];
  }

  late int total = 0;
  late bool isLoading = false;

  Future<void> fetchCarts(String $token, {bool isRefresh = false}) async {
    if (!isRefresh && carts.isNotEmpty) {
      return;
    }
    _carts = [];
    isLoading = true;
    notifyListeners();
    final data = await Http.getDate('/cart', bearerToken: $token);
    if (data['status']) {
      final jsonList = data['data'] as List;
      jsonList.map((e) => _carts.add(Cart.fromJson(e))).toList();
      total = data['totalPrice'];
    }

    isLoading = false;
    notifyListeners();
  }

  Map<String, String> Header(String bearerToken) {
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    return customHeaders;
  }

  bool isAdding = false;
  Future<Map<String, dynamic>> addToCart(Product product, String token) async {
    isAdding = true;
    notifyListeners();

    final getUrl = Uri.parse('${Http.coreUrl}/cart');

    final carts =
        jsonEncode({"product_id": product.id, "quantity": product.MOQ});

    Map<String, String> customHeaders = Header(token);

    try {
      final data = await http.post(getUrl, headers: customHeaders, body: carts);
      final jsonDecodeData = jsonDecode(data.body);
      isAdding = false;
      notifyListeners();

      if (data.statusCode == 200 && jsonDecodeData['status']) {
        return {'status': true, 'message': 'Successfully Added!'};
      }

      return {
        'status': false,
        'message': jsonDecodeData['message'] ?? jsonDecodeData['data']
      };
    } catch (err) {
      return {'status': false, 'message': err.toString()};
    }
  }

  void calculateTotal() {
    total = 0;
    _carts.map((e) => total += e.totalPrice).toList();
    print(total);
    notifyListeners();
  }

  Future<bool> deleteCart(int cartId, String token) async {
    final getUrl = Uri.parse('${Http.coreUrl}/cart/delete/$cartId');

    var request = http.MultipartRequest('DELETE', getUrl);

    Map<String, String> customHeaders = Header(token);

    request.headers.addAll(customHeaders);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      _carts.removeWhere((element) => element.id == cartId);
      calculateTotal();
      notifyListeners();
    } else {
      print(response.reasonPhrase);
    }
    return false;
  }

  Future<void> updateCart(int cartId, int isIncrement, String token) async {
    final index = _carts.indexWhere((element) => element.id == cartId).toInt();

    _carts[_carts.indexWhere((element) => element.id == cartId).toInt()]
        .updateLoading(true);
    notifyListeners();

    final getUrl =
        Uri.parse('${Http.coreUrl}/cart/$cartId?is_increment=$isIncrement');

    var request = http.MultipartRequest('PATCH', getUrl);

    Map<String, String> customHeaders = Header(token);

    request.headers.addAll(customHeaders);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      _carts = _carts.map((element) {
        if (element.id == cartId) {
          element.updateQuantity(isIncrement);
          element.updateLoading(false);
        }
        return element;
      }).toList();
      calculateTotal();
      notifyListeners();
    } else {
      print(response.reasonPhrase);
    }
  }
}
