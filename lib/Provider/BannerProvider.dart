import 'package:ab_pharmacy/Helper/Http.dart';
import 'package:ab_pharmacy/Modal/Category.dart';
import 'package:flutter/material.dart';

class BannerProvider with ChangeNotifier {
  late List<String> _banners = [];

  List<String> get banners {
    return [..._banners];
  }

  Future<void> fetchBanners() async {
    final data = await Http.getDate('/banners');
    if (_banners.isNotEmpty) {
      notifyListeners();
      return;
    }

    if (data['status']) {
      final json = data['data'] as List;
      if (json.isNotEmpty) {
        _banners = [];
        json.map((e) => _banners.add(e)).toList();
        notifyListeners();
      }
    }
  }

  late List<Category> _categories = [];

  List<Category> get categories {
    return [..._categories];
  }

  Future<void> fetchCategories() async {
    final data = await Http.getDate('/categories');
    if (categories.isNotEmpty) {
      return;
    }
    if (data['status']) {
      final json = data['data'] as List;
      if (json.isNotEmpty) {
        _categories = [];
        json.map((e) => _categories.add(Category.fromJson(e))).toList();
        notifyListeners();
      }
    }
  }
}
