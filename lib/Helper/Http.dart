import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Http {
  static const coreUrl = 'https://yoeyar.whalemyanmar.com/public/api';

  static Future getDate(String url, {String? bearerToken}) async {
    final getUrl = Uri.parse(Http.coreUrl + url);
    final Map<String, String> customHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (bearerToken != null) {
      customHeaders['Authorization'] = 'Bearer $bearerToken';
    }
    print(bearerToken);
    try {
      final data = await http.get(
        getUrl,
        headers: customHeaders,
      );

      final json = jsonDecode(data.body);

      if (data.statusCode == 200 || data.statusCode == 400) {
        return json;
      }
      print(json);
      return {'status': false, 'message': 'Expired Token Time!'};
    } catch (err) {
      print(err);
    }
  }
}
