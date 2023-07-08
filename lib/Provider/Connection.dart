import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class Connection with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    _connectivity.onConnectivityChanged.listen((event) => updateConnection);
  }

  bool status = false;

  void updateConnection(ConnectivityResult connection) {
    print(connection);
    if (connection == ConnectivityResult.none) {
      status = false;
    }
    status = true;
  }
}
