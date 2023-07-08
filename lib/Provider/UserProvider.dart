import 'dart:convert';
import 'dart:io';

import 'package:ab_pharmacy/Helper/Http.dart';
import 'package:ab_pharmacy/Modal/AppInfomation.dart';
import 'package:ab_pharmacy/Modal/User.dart';
import 'package:ab_pharmacy/Provider/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User? userData;
  late String? token = '';
  late bool isLoading = false;
  AppInfomation? appInfomation;
  UserProvider(Map? data) {
    if (data != null) {
      userData = data['user'];
      token = data['token'];
      notifyListeners();
    }
  }

  Future<void> fetchAppInfomation() async {
    final data = await Http.getDate('/app/detail');

    if (data['status']) {
      appInfomation = AppInfomation.fromJson(data['data']);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> Register(Map<String, dynamic> data) async {
    final getUrl = Uri.parse('${Http.coreUrl}/register');
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    isLoading = true;

    final user = jsonEncode(data);
    try {
      final data = await http.post(getUrl, headers: customHeaders, body: user);
      print(data.body);

      if (data.statusCode == 200 && jsonDecode(data.body)['status']) {
        final json = jsonDecode(data.body);
        isLoading = false;
        return {
          'status': true,
          'message': 'Login Now',
        };
      }

      isLoading = false;

      return {'status': false, 'message': 'SOMETHING WAS WRONG'};
    } catch (err) {
      isLoading = false;
      return {'status': false, 'message': err.toString()};
    }
  }

  Future<Map<String, dynamic>> Login(Map<String, dynamic> data) async {
    final getUrl = Uri.parse('${Http.coreUrl}/login');
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    isLoading = true;
    notifyListeners();
    final user = jsonEncode(data);
    try {
      final data = await http.post(getUrl, headers: customHeaders, body: user);
      print(data.statusCode);
      if (data.statusCode == 200 && jsonDecode(data.body)['status']) {
        final json = jsonDecode(data.body);
        userData = User.fromJson(json['user']);
        token = json['token'];
        isLoading = false;

        //store on local
        AuthManager.setUserAndToken(json['token'], User.fromJson(json['user']));

        return {
          'status': true,
          'message': 'Successfully Login',
        };
      }

      isLoading = false;
      notifyListeners();
      return {'status': false, 'message': 'SOMETHING WAS WRONG'};
    } catch (err) {
      isLoading = false;
      notifyListeners();
      return {'status': false, 'message': err.toString()};
    }
  }

  Future<Map<String, dynamic>> profileUpdate(Map rawData) async {
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final url = Uri.parse(Http.coreUrl + "/change/profile");
    final data = jsonEncode(rawData);
    final response = await http.post(url, headers: customHeaders, body: data);
    final json = jsonDecode(response.body);

    if (json['status']) {
      userData!.name = rawData['name'];
      userData!.credentials = rawData['credentials'];
      notifyListeners();
      return {'status': true, 'message': json['message']};
    }

    return {'status': false, 'message': 'FAILED!'};
  }

  Future<Map<String, dynamic>> changeImage(File image) async {
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final url = Uri.parse(Http.coreUrl + "/change/profile");

    final request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath('photo', image.path));

    request.headers.addAll(customHeaders);
    final send = await request.send();
    final response = await send.stream.bytesToString();

    final json = jsonDecode(response);
    if (json['status'] == 'success') {
      userData!.photo = json['data']['photo'];
      notifyListeners();
      return {'status': true, 'message': json['message']};
    }

    return {'status': false, 'message': 'FAILED!'};
  }

  Future<Map<String, dynamic>> logOut() async {
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final url = Uri.parse(Http.coreUrl + "/logout");
    final response = await http.post(url, headers: customHeaders);
    final json = jsonDecode(response.body);
    if (json['status']) {
      token = '';
      userData = null;

      AuthManager.removeUserAndToken();
      notifyListeners();
      return {'status': true, 'message': "Loggout!"};
    }


    return {'status': false, 'message': 'FAILED!'};
  }
}
