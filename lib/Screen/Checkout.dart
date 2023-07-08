import 'dart:io';

import 'package:ab_pharmacy/Modal/User.dart';
import 'package:ab_pharmacy/Provider/AuthManager.dart';
import 'package:ab_pharmacy/Provider/CartProvider.dart';
import 'package:ab_pharmacy/Provider/OrderProvider.dart';
import 'package:ab_pharmacy/Provider/UserProvider.dart';
import 'package:ab_pharmacy/Screen/CheckoutSuccess.dart';
import 'package:ab_pharmacy/Widgets/BannerWidget.dart';
import 'package:ab_pharmacy/Widgets/DottedBorder.dart';
import 'package:ab_pharmacy/Widgets/SnackBarWidget.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class Checkoout extends StatefulWidget {
  const Checkoout({super.key});

  @override
  State<Checkoout> createState() => _CheckooutState();
}

class _CheckooutState extends State<Checkoout> {
  late LatLng _kMapCenter = LatLng(19.018255973653343, 72.84793849278007);

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickImage = await picker.pickImage(source: ImageSource.gallery);

    if (!context.mounted) return;
    if (pickImage != null) {
      Provider.of<OrderProvider>(context, listen: false)
          .addSlip(File(pickImage.path));
    }
  }

  GoogleMapController? _controller;
  late CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _customInfoWindowController.googleMapController = controller;
  }

  late Set<Marker> _maker = {};

  Future<void> _createPin(LatLng latLng) async {
    _customInfoWindowController.hideInfoWindow!();
    Provider.of<OrderProvider>(context, listen: false).changeLocation(latLng);
    _maker = {};
  }

  Location location = new Location();

  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Future<void> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    if(_locationData != null){
      _controller!.animateCamera(CameraUpdate.newLatLng(LatLng(_locationData!.latitude!, _locationData!.longitude!)));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _customInfoWindowController.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  height: 200,
                  child: Consumer<OrderProvider>(
                    builder: (context, value, child) {
                      return GoogleMap(
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: value.location == null
                              ? _kMapCenter
                              : value.location!,
                          zoom: 15,
                        ),
                        markers: value.location == null
                            ? Set.of({})
                            : Set.of({MakerMake(value, context)}),
                        mapToolbarEnabled: true,
                        onCameraMove: (position) {
                          _customInfoWindowController.onCameraMove!();
                        },
                        onMapCreated: onMapCreated,
                        onTap: (value) => _createPin(value),
                        cameraTargetBounds: CameraTargetBounds.unbounded,
                      );
                    },
                  ),
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  width: 250,
                  height: 80,
                  offset: 40,
                ),
              ],
            ),
            Expanded(
                child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                CouponCard(
                  height: 550,
                  curvePosition: 450,
                  curveRadius: 25,
                  borderRadius: 15,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  firstChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: UserInformationAndOrderSummary(),
                  ),
                  secondChild: DottedBorder(
                    strokeWidth: 1,
                    color: Theme.of(context).colorScheme.surface,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: OrderNowButton(context),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Consumer<OrderProvider>(
                  builder: (context, value, child) {
                    return value.selectedTownship!.cod
                        ? Container()
                        : InkWell(
                            borderRadius: BorderRadius.circular(8),
                            overlayColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.surfaceVariant),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            onTap: selectImage,
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text(
                                'Select Payment Slip',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                  },
                ),
                Consumer<OrderProvider>(builder: (context, value, child) {
                  return value.slip != null
                      ? Container(
                          width: double.infinity,
                          height: 500,
                          margin: const EdgeInsets.only(top: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(value.slip!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container();
                }),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Marker MakerMake(OrderProvider value, BuildContext context) {
    return Marker(
      markerId: MarkerId('location'),
      position: value.location!,
      onTap: () {
        _customInfoWindowController.addInfoWindow!(
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'ယခု ပြထားသော နေရာအား ပို့ဆောင်ပေးပါမည်',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      '${value.selectedTownship!.regionName},${value.selectedTownship!.townshipName},${value.address!},',
                      style: const TextStyle(fontSize: 10),
                    )
                  ]),
            ),
            value.location!);
      },
    );
  }

  Column OrderNowButton(BuildContext context) {
    void submit() async {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (orderProvider.location == null) {
        snackBarWidget(context, 'You Need To Pin Your Location on Map!');
        return;
      }
      if (!orderProvider.selectedTownship!.cod && orderProvider.slip == null) {
        snackBarWidget(context, 'You Need To Prepaid!');
        return;
      }

      final data = await AuthManager.getUserAndToken();
      final user = data!['user'];
      final response = await orderProvider.order(data['token'], user);

      if (!response['status']) {
        snackBarWidget(context, response['message']);
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CheckoutSuccess()),
          (route) => false);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            overlayColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.surfaceVariant),
            splashColor: Theme.of(context).colorScheme.secondaryContainer,
            onTap: submit,
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // color: ,
                border:
                    Border.all(color: Theme.of(context).colorScheme.surface),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Consumer<OrderProvider>(
                builder: (context, value, child) {
                  return value.isOrdering
                      ? const Center(
                          child: Loading('Sending data to databases',
                              double.infinity, 50, 15),
                        )
                      : Text(
                          'Order Now'.toUpperCase(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        );
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Column UserInformationAndOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'User Infomation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('User Name'),
            Consumer<UserProvider>(
              builder: (context, value, child) {
                return value.userData != null
                    ? Text(value.userData!.name.toString())
                    : Text('');
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Phone'),
            Consumer<UserProvider>(
              builder: (context, value, child) {
                return value.userData != null
                    ? Text(value.userData!.credentials.toString())
                    : Text('');
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Region'),
            Consumer<OrderProvider>(
              builder: (context, value, child) {
                return value.selectedTownship != null
                    ? Text(value.selectedTownship!.regionName.toString())
                    : Text('');
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Township'),
            Consumer<OrderProvider>(
              builder: (context, value, child) {
                return value.selectedTownship != null
                    ? Text(value.selectedTownship!.townshipName.toString())
                    : Text('');
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Address'),
            Consumer<OrderProvider>(
              builder: (context, value, child) {
                return value.address != null
                    ? Text(value.address.toString())
                    : Text('');
              },
            ),
          ],
        ),
        const Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'Order Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Delivery Duration '),
            Consumer<OrderProvider>(
              builder: (context, value, child) {
                return value.selectedTownship != null
                    ? Text(
                        value.selectedTownship!.duration.toString() + ' Days')
                    : Text('0');
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cash On Delivery '),
            Consumer<OrderProvider>(
              builder: (context, value, child) {
                return value.selectedTownship != null
                    ? value.selectedTownship!.cod
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.error,
                          )
                    : Container();
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Coupon Code '),
            Consumer<OrderProvider>(
              builder: (context, value, child) {
                return value.coupon != null
                    ? Text(value.coupon!.code.toString())
                    : const Text('-');
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Delivery Services '),
            Consumer<OrderProvider>(
              builder: (context, value, child) {
                return value.selectedTownship != null
                    ? Text(value.selectedTownship!.fees.toString())
                    : const Text('0');
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total  ',
            ),
            Consumer2<CartProvider, OrderProvider>(
              builder: (context, value, orderValue, child) {
                return Text(
                  "${(value.total + (orderValue.selectedTownship != null ? orderValue.selectedTownship!.fees : 0) - (orderValue.coupon != null ? orderValue.coupon!.amount : 0))}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
