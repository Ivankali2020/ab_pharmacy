import 'package:ab_pharmacy/Widgets/BannerWidget.dart';
import 'package:ab_pharmacy/Widgets/DottedBorder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Provider/OrderProvider.dart';
// import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // final id = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
        actions: [
          IconButton(
              onPressed: () => mapBox(context),
              icon: const Icon(Icons.pin_drop))
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, value, child) {
          final detail = value.orderDetail;
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "User Info",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            "Date : ${detail.date}",
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Name'),
                          Text(
                            " ${detail.deliveryName} ",
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Phone'),
                          Text(
                            " ${detail.deliveryPhone} ",
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Address'),
                          Text(
                            " ${detail.shippingAddress} ",
                            softWrap: true,
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status'),
                          Text(
                            " ${detail.status} ",
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      detail.paymentMethod.photo != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Prepaid'),
                                CachedNetworkImage(
                                  alignment: Alignment.center,
                                  imageUrl:
                                      value.orderDetail.paymentMethod.photo!,
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                  placeholder: (context, url) => const Center(
                                    child:
                                        Loading('..', double.infinity, 30, 9),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('COD'),
                                Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              detail.products.isEmpty
                  ? const Center(
                      child: Text('No Products Found'),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: detail.products.length,
                          itemBuilder: (context, i) {
                            return Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black26, width: 0.5),
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                title: Text(detail.products[i].name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    detail.products[i].discountPrice == 0
                                        ? Text(
                                            'Price : ${(detail.products[i].price).toString()} ks',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          )
                                        : Text(
                                            'Price : ${(detail.products[i].discountPrice).toString()} ks',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                    Text(
                                      'Category : ${detail.products[i].category}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        'Total : ${detail.products[i].totalPrice.toString()} Ks'),
                                    Text(
                                        "x ${detail.products[i].quantity.toString()} qty"),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
              Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          "Order Summary",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text(
                            " ${detail.totalPrice - detail.deliveryFees} Ks",
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery'),
                          Text(
                            " ${detail.deliveryFees} Ks",
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      detail.couponAmount != 0
                          ? Padding(
                            padding: const EdgeInsets.only(bottom:10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Coupoon Amount '),
                                  Text(
                                    "- ${detail.couponAmount} Ks",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                ],
                              ),
                          )
                          : Container(),
                      DottedBorder(
                          strokeWidth: 1,
                          color: Theme.of(context).colorScheme.secondary,
                          child: Container(
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              " ${detail.totalPrice - detail.couponAmount} Ks",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<dynamic> mapBox(BuildContext context) {
  return showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.surface,
    context: context,
    builder: (context) {
      return Column(
        children: [
          const MapWidget(),
          Consumer<OrderProvider>(
            builder: (context, value, child) {
              return value.orderDetail.cancelRefund.photo != null
                  ? Expanded(
                      child: Column(
                        children: [
                          Container(
                              margin:const EdgeInsets.all(10),
                              child: Text(
                                  value.orderDetail.cancelRefund.message!)),
                          value.orderDetail.cancelRefund.photo != null
                              ? CachedNetworkImage(
                                  alignment: Alignment.center,
                                  imageUrl:
                                      value.orderDetail.cancelRefund.photo!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  placeholder: (context, url) => const Center(
                                    child: Loading(
                                        'Fetch..', double.infinity, 50, 10),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Container(),
                        ],
                      ),
                    )
                  : Container();
            },
          )
        ],
      );
    },
  );
}

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _customInfoWindowController.googleMapController = controller;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller!.dispose();
    _customInfoWindowController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Marker MakerMake(
        OrderProvider value, BuildContext context, LatLng location) {
      return Marker(
        markerId:const MarkerId('location'),
        position: location,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
              Container(
                padding:const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'ယခု ပြထားသော နေရာအား ပို့ဆောင်ပေးပါမည်',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        '${value.orderDetail.shippingAddress},',
                        style: const TextStyle(fontSize: 10),
                      )
                    ]),
              ),
              location);
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            width: double.infinity,
            height: 300,
            child: Consumer<OrderProvider>(
              builder: (context, value, child) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(value.orderDetail.latitude),
                        double.parse(value.orderDetail.longitude)),
                    zoom: 18,
                  ),
                  markers: Set.of({
                    MakerMake(
                        value,
                        context,
                        LatLng(double.parse(value.orderDetail.latitude),
                            double.parse(value.orderDetail.longitude)))
                  }),
                  mapToolbarEnabled: true,
                  onMapCreated: onMapCreated,
                );
              },
            ),
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            width: 280,
            height: 80,
            offset: 40,
          ),
        ],
      ),
    );
  }
}
