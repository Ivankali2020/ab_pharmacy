import 'package:ab_pharmacy/Helper/Http.dart';
import 'package:ab_pharmacy/Modal/Meta.dart';
import 'package:ab_pharmacy/Modal/Products.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  Meta? meta;
  List<Product> _products = [];
  List<Product> get products {
    return [..._products];
  }

  bool isLoadingProducts = false;
  bool isNotDataProducts = false;

  Future<void> fetchProducts({
    bool isLoadMore = false,
    String? keyword,
  }) async {
    if (_products.isNotEmpty) {
      return;
    }
    final data = await Http.getDate('/products');
    isLoadingProducts = true;
    notifyListeners();

    if (data['status']) {
      final products = data['data'] as List;
      if (!isLoadMore) {
        _products = [];
      }
      if (products.isNotEmpty) {
        products.map((e) => _products.add(Product.fromJson(e))).toList();
        meta = Meta.fromJson(data['meta']);
        notifyListeners();
      } else {
        isNotDataProducts = true;
        notifyListeners();
      }

      isLoadingProducts = false;
    } else {
      throw data['message'];
    }
  }

  void addSearchProduct() {
    brandId = null;
    isNotDataProducts = false;
    _searchProducts = products;
    notifyListeners();
  }

  List<Product> _searchProducts = [];
  List<Product> get searchProducts {
    return [..._searchProducts];
  }

  String? brandId;
  late bool noMoreProduct = false;

  void addBrandId(String id) {
    _searchProducts = [];
    meta!.currentPage = 0;
    brandId = id;
    search();
  }

  Future<void> loadMore({String? keyword}) async {
    final data = await Http.getDate(
        '/products?sub_category_id=${brandId ?? " "}&keyword=${keyword ?? " "}&page=${meta!.currentPage + 1}');

    if (data['status']) {
      final List dataList = data['data'] as List;
      dataList.map((e) => _searchProducts.add(Product.fromJson(e))).toList();
      dataList.map((e) => _products.add(Product.fromJson(e))).toList();
      meta = Meta.fromJson(data['meta']);
      notifyListeners();
    }
  }

  Future<void> search({String? keyword}) async {
    isLoadingProducts = true;
    notifyListeners();
    if (keyword != null) {
      meta!.currentPage = 0;
      _searchProducts = [];
    }
    final data = await Http.getDate(
        '/products?sub_category_id=${brandId ?? " "}&keyword=${keyword ?? " "}&page=${meta!.currentPage + 1}');
    print(
        '/products?sub_category_id=${brandId ?? " "}&keyword=${keyword ?? " "}&page=${meta!.currentPage + 1}');

    if (data['status']) {
      final List dataList = data['data'] as List;
      dataList.map((e) {
        _searchProducts.add(Product.fromJson(e));
      }).toList();
      meta = Meta.fromJson(data['meta']);
      isLoadingProducts = false;
      notifyListeners();
    }
  }
}
