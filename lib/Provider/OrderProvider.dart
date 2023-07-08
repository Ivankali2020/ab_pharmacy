import 'dart:convert';
import 'dart:io';

import 'package:ab_pharmacy/Helper/Http.dart';
import 'package:ab_pharmacy/Modal/Coupon.dart';
import 'package:ab_pharmacy/Modal/OrderDetail.dart';
import 'package:ab_pharmacy/Modal/Payment.dart';
import 'package:ab_pharmacy/Modal/Region.dart';
import 'package:ab_pharmacy/Modal/Township.dart';
import 'package:ab_pharmacy/Modal/User.dart';
import 'package:ab_pharmacy/Screen/Cart.dart';
import 'package:ab_pharmacy/Modal/Order.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OrderProvider with ChangeNotifier {
  List<Payment> _payments = [];
  List<Payment> get payments {
    return [..._payments];
  }

  List<Region> _regions = [];
  List<Region> get regions {
    return [..._regions];
  }

  List<Township> _townships = [];
  List<Township> get townships {
    return [..._townships];
  }

  File? slip;
  int? selectedPaymentId;
  String? address;
  Township? selectedTownship;
  Region? selectedRegion;

  LatLng? location;
  Coupon? coupon;
  bool isCheckingPromoCode = false;
  Future<Map<String, dynamic>> checkCouponCode(
    String token,
    String code,
  ) async {
    isCheckingPromoCode = true;
    notifyListeners();
    final data = await Http.getDate('/check/coupon/$code', bearerToken: token);

    if (data['status']) {
      coupon = Coupon.fromJson(data['message']);
      isCheckingPromoCode = false;
      notifyListeners();
      return {
        'status': true,
        'message': 'Congratulations! You get promotion code.'
      };
    }
    coupon = null;
    isCheckingPromoCode = false;
    notifyListeners();
    return {'status': false, 'message': data['message']};
  }

  void changeLocation(LatLng loca) {
    location = loca;
    notifyListeners();
  }

  void changeSelectedPayementId(int id) {
    selectedPaymentId = id;
    notifyListeners();
  }

  Future<void> fetchPayemnts() async {
    final data = await Http.getDate('/payments');

    if (data['status']) {
      final jsonList = data['data'] as List;
      _payments = [];
      jsonList.map((e) => _payments.add(Payment.fromJson(e))).toList();
      notifyListeners();
    }

    fetchRegions();
  }

  void addSlip(File value) {
    slip = value;
    notifyListeners();
  }

  void changeAddress(String township) {
    address = township;
    notifyListeners();
  }

  void changeSelectedTownship(Township township) {
    selectedTownship = township;
    notifyListeners();
  }

  void changeSelectedRegion(Region region) async {
    _townships = [];
    selectedRegion = region;
    await fetchTownships(region.regionId);

    notifyListeners();
  }

  Future<void> fetchRegions() async {
    if (regions.isNotEmpty) {
      return;
    }

    final data = await Http.getDate('/regions');
    if (data['status']) {
      final jsonList = data['data'] as List;
      _regions = [];
      jsonList.map((e) => _regions.add(Region.fromJson(e))).toList();
      notifyListeners();
    }
  }

  Future<void> fetchTownships(int regionId) async {
    final data = await Http.getDate('/region/$regionId/township');
    if (data['status']) {
      final jsonList = data['data'] as List;
      _townships = [];
      jsonList.map((e) => _townships.add(Township.fromJson(e))).toList();
      print(townships);
      notifyListeners();
    }
  }

  bool isOrdering = false;
  Future<Map<String, dynamic>> order(
    String token,
    User userData,
  ) async {
    isOrdering = true;
    notifyListeners();

    // second order api
    final Map<String, String> data = {
      'name': userData.name,
      'phone': userData.credentials,
      'address': address!,
      'user_id': userData.id.toString(),
      'township_id': selectedTownship!.townshipId.toString(),
      'coupon_id': coupon != null ? coupon!.id.toString() : '',
      'payment_id':
          selectedPaymentId != null ? selectedPaymentId!.toString() : '',
      'note': '-',
      'latitude': location!.latitude.toString(),
      'longitude': location!.longitude.toString()
    };

    final responsFromOrder = await OrderNow(data, token);
    if (!responsFromOrder) {
      return {'status': false, 'message': 'ERROR OCCUR WHEN ORDERING'};
    }

    coupon = null;
    isOrdering = false;
    slip = null;
    notifyListeners();
    return {'status': true, 'message': 'Successfully Ordered!'};
  }

  Future<bool> OrderNow(Map<String, String> data, String bearerToken) async {
    final getUrl = Uri.parse('${Http.coreUrl}/order');
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };

    final orderData = jsonEncode(data);
    try {
      final request = http.MultipartRequest('POST', getUrl);

      request.fields.addAll(data);
      if (!selectedTownship!.cod) {
        request.files
            .add(await http.MultipartFile.fromPath('slip', slip!.path));
      }
      request.headers.addAll(customHeaders);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var decodedBody = jsonDecode(responseBody);
      if (response.statusCode == 200 && decodedBody['status']) {
        return true;
      }
      print(responseBody);
      return false;
    } catch (err) {
      return false;
    }
  }

  List<Order> orders = [];
  late int page = 0;
  late bool isNoOrderAnyMore = false;
  Future<void> getOrdersDatas(String token, {isLoadMore = false}) async {
    if (!isLoadMore) {
      orders = [];
      isNoOrderAnyMore = false;
      page = 1;
    }
    final data = await Http.getDate('/order?page=${page}', bearerToken: token);
    if (data == null) return;
    print(data);
    if (data['status']) {
      if ((data['data'] as List).isEmpty) {
        isNoOrderAnyMore = true;
        notifyListeners();
        return;
      }
      data['data'].map((e) => orders.add(Order.fromJson(e))).toList();
      page++;
      notifyListeners();
    }
  }

  late OrderDetail orderDetail;

  Future<bool> fetchorderProducts(String id, String token) async {
    isOrdering = true;
    notifyListeners();
    final data = await Http.getDate('/order/$id', bearerToken: token);
    if (data == null) return false;
    if (data['status']) {
      orderDetail = OrderDetail.fromJson(data['data'][0]);
      notifyListeners();
    }

    isOrdering = false;
    notifyListeners();

    return true;
  }
}
