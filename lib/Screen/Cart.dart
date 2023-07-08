import 'package:ab_pharmacy/Provider/AuthManager.dart';
import 'package:ab_pharmacy/Provider/CartProvider.dart';
import 'package:ab_pharmacy/Provider/OrderProvider.dart';
import 'package:ab_pharmacy/Provider/UserProvider.dart';
import 'package:ab_pharmacy/Screen/Auth/Login.dart';
import 'package:ab_pharmacy/Screen/Checkout.dart';
import 'package:ab_pharmacy/Widgets/BannerWidget.dart';
import 'package:ab_pharmacy/Widgets/DottedBorder.dart';
import 'package:ab_pharmacy/Widgets/DropDownWidget.dart';
import 'package:ab_pharmacy/Widgets/SnackBarWidget.dart';
import 'package:ab_pharmacy/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Modal/Cart.dart' as ModalCart;

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCarts();
    Provider.of<OrderProvider>(context, listen: false).fetchPayemnts();
  }

  Future<void> fetchCarts() async {
    final token = await AuthManager.getToken();
    if (token != null) {
      Provider.of<CartProvider>(context, listen: false).fetchCarts(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: [
          IconButton(
              onPressed: () async {
                final token = await AuthManager.getToken();
                Provider.of<CartProvider>(context, listen: false)
                    .fetchCarts(token!, isRefresh: true);
              },
              icon: const Icon(Icons.refresh_outlined))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CartItems(),
          Consumer<UserProvider>(
            builder: (context, value, child) {
              return value.token!.isNotEmpty
                  ? const CheckoutNow()
                  : const LoginButtonWidget();
            },
          ),
        ],
      ),
    );
  }
}

class LoginButtonWidget extends StatelessWidget {
  const LoginButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        overlayColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer),
        splashColor: Theme.of(context).colorScheme.secondaryContainer,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Login(
                name: '',
                password: '',
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // color: ,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Login'.toUpperCase(),
          ),
        ),
      ),
    );
  }
}

class CartItems extends StatefulWidget {
  const CartItems({
    super.key,
  });

  @override
  State<CartItems> createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems> {
  Future<void> deleteCart(int cartId, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          icon: Icon(
            Icons.delete_outline_sharp,
            size: 80,
            color: Theme.of(context).colorScheme.secondary,
            weight: 1,
          ),
          content: const Text('Cart will be delete. You can not be revert!'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () async {
                final token = await AuthManager.getToken();
                Provider.of<CartProvider>(context, listen: false)
                    .deleteCart(cartId, token!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  TextEditingController _controller = TextEditingController();
  Future<void> _search() async {
    if (_controller.text.isEmpty) {
      snackBarWidget(context, 'ကုဒ် ရိုက်ထည့်ပါ');
      return;
    }
    final token = await AuthManager.getToken();
    final response = await Provider.of<OrderProvider>(context, listen: false)
        .checkCouponCode(token!, _controller.text);

    if (response['status']) {
      snackBarWidget(context, response['message']);
    } else {
      snackBarWidget(context, response['message']);
    }
      _controller.text = '';
  }

  Future<void> _refreshCart() async {
    final token = await AuthManager.getToken();
    Provider.of<CartProvider>(context, listen: false)
        .fetchCarts(token!, isRefresh: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Consumer<CartProvider>(
        builder: (context, value, child) {
          return value.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : value.carts.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              'https://cdn3d.iconscout.com/3d/free/thumb/free-empty-cart-3543011-2969398.png',
                          placeholder: (context, i) => Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                          width: 300,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const Loading('Empty Cart', double.infinity, 100, 20)
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshCart,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: value.carts.length + 1,
                        itemBuilder: (context, i) {
                          if (i == value.carts.length) {
                            return SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 200,
                                      height: 40,
                                      padding: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextField(
                                        controller: _controller,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _controller.text = '';
                                                });
                                              },
                                              icon: const Icon(
                                                  Icons.close_outlined)),
                                          hintText:
                                              'အသုံးပြုမည့် ကုဒ် ရိုက်ထည့်ပါ',
                                          hintStyle:
                                              const TextStyle(fontSize: 13),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: _search,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      child: Consumer<OrderProvider>(
                                        builder: (context, value, child) {
                                          return value.isCheckingPromoCode
                                              ?  Container(
                                                width: 25,
                                                height: 25,
                                                alignment: Alignment.center,
                                                  child:
                                                     const CircularProgressIndicator(
                                                    strokeWidth: .9,
                                                  ),
                                                )
                                              : const Text('APPLY');
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                          final cart = value.carts[i];
                          return Container(
                            height: 90,
                            margin: const EdgeInsets.only(bottom: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            child: Stack(children: [
                              ListTile(
                                leading: CachedNetworkImage(
                                  imageUrl: cart.product.photos[0],
                                  placeholder: (context, i) => Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  ),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                                title: Text(
                                  cart.product.name,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: GoogleFonts.bebasNeue(
                                      fontSize: 18, letterSpacing: 2),
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 5),
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                          // border: Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                            cart.product.brandName
                                                .toUpperCase(),
                                            style: TextStyle(fontSize: 10)),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 2),
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                          // border: Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          "Made In ${cart.product.madeIn}",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: ActionCart(cart, context),
                              ),
                              Positioned(
                                top: -8,
                                left: -8,
                                child: IconButton(
                                  onPressed: () => deleteCart(cart.id, context),
                                  icon: Icon(
                                    Icons.close,
                                    size: 15,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              )
                            ]),
                          );
                        },
                      ),
                    );
        },
      ),
    );
  }

  Container ActionCart(ModalCart.Cart cart, BuildContext context) {
    Future<void> updateQuantity(int isIncrement) async {
      if (isIncrement == 0) {
        if (cart.product.MOQ >= cart.quantity) {
          snackBarWidget(
              context, 'Miminum Amount of Quantity is ${cart.product.MOQ} qty');
          return;
        }
      }
      final token = await AuthManager.getToken();
      Provider.of<CartProvider>(context, listen: false)
          .updateCart(cart.id, isIncrement, token!);
    }

    return Container(
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cart.product.discountPrice != 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        "${cart.product.price.toString()} ",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        "${cart.product.discountPrice.toString()} ks",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5),
                  child: Text(
                    cart.product.price.toString() + ' Ks',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // minus
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.tertiaryContainer),
                  focusColor: Theme.of(context).colorScheme.tertiaryContainer,
                  splashColor: Theme.of(context).colorScheme.secondaryContainer,
                  onTap: () => updateQuantity(0),
                  child: Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      CupertinoIcons.minus,
                      size: 15,
                    ),
                  ),
                ),

                //quanity
                Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    child: cart.isLoading
                        ? Container(
                            width: 15,
                            height: 15,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1,
                            ))
                        : Text(cart.quantity.toString())),

                //add quantity
                InkWell(
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.tertiaryContainer),
                  focusColor: Theme.of(context).colorScheme.tertiaryContainer,
                  splashColor: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => updateQuantity(1),
                  child: Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: const Icon(
                      CupertinoIcons.add,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CheckoutNow extends StatelessWidget {
  const CheckoutNow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(
          top: BorderSide(
            color: Color.fromARGB(255, 232, 232, 232),
          ),
        ),
      ),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 5,
              ),
              Consumer2<CartProvider, OrderProvider>(
                builder: (context, cart, order, child) {
                  return Row(
                    children: [
                      Text(
                        (cart.total -
                                (order.coupon != null
                                    ? order.coupon!.amount
                                    : 0))
                            .toString(),
                        style: GoogleFonts.bebasNeue(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 2,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const Text(
                        ' Ks',
                        style: TextStyle(color: Colors.grey),
                      ),
                      order.coupon != null
                          ? Container(
                              width: 60,
                              height: 25,
                              margin: const EdgeInsets.only(left: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(5)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              child: Text(
                                order.coupon!.code,
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            )
                          : Container(),
                    ],
                  );
                },
              )
            ],
          ),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: Consumer<CartProvider>(builder: (context, value, child) {
                  return value.carts.isEmpty
                      ? InkWell(
                          borderRadius: BorderRadius.circular(8),
                          overlayColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.surfaceVariant),
                          splashColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const Main(
                                      title: 'AB SHOP',
                                    )));
                          },
                          child: Container(
                            width: 150,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // color: ,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Get Products'.toUpperCase(),
                            ),
                          ),
                        )
                      : InkWell(
                          borderRadius: BorderRadius.circular(8),
                          overlayColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.surfaceVariant),
                          splashColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          onTap: () => checkoutBox(context),
                          child: Container(
                            width: 150,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // color: ,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Checkout Now'.toUpperCase(),
                            ),
                          ),
                        );
                }),
              ),
            ],
          )
        ],
      ),
    );
  }
}

Future<dynamic> checkoutBox(BuildContext context) {
  Future<void> addressBox() async {
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    TextEditingController userAddress = TextEditingController();
    userAddress.text =
        Provider.of<OrderProvider>(context, listen: false).address ?? '';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: 300,
          child: AlertDialog(
            iconPadding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            icon: Icon(
              Icons.pin_drop_outlined,
              size: 50,
              color: Theme.of(context).colorScheme.secondary,
              weight: 1,
            ),
            content: SizedBox(
              height: 260,
              width: double.infinity,
              child: Column(
                children: [
                  RegionDropDown(),
                  const SizedBox(
                    height: 15,
                  ),
                  TownshipDropDown(),
                  const SizedBox(
                    height: 15,
                  ),
                  Form(
                    key: _key,
                    child: TextFormField(
                      maxLines: 3,
                      controller: userAddress,
                      scrollPadding: const EdgeInsets.all(10),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(14),
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      validator: (value) {
                        if (value == '') {
                          return 'Required Address';
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () async {
                  if (!_key.currentState!.validate()) {
                    return;
                  }
                  Provider.of<OrderProvider>(context, listen: false)
                      .changeAddress(userAddress.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void payment() {
    final order = Provider.of<OrderProvider>(context, listen: false);
    if (order.selectedRegion == null ||
        order.selectedTownship == null ||
        order.address == null) {
      Navigator.of(context).pop();
      snackBarWidget(context, 'Need To Select Your Region And Townshiop');
      return;
    }
    if (order.selectedTownship!.cod == false &&
        order.selectedPaymentId == null) {
      Navigator.of(context).pop();
      snackBarWidget(context, 'You need to selected payment!');
      return;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Checkoout()));
  }

  return showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.surface,
    context: context,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 1, // Set the desired height factor (0.0 to 1.0)
        child: Container(
          height: 700,
          padding: const EdgeInsets.all(18.0),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              OrderConfrimText(),
              Payments(context),
              DeliText(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://cdn3d.iconscout.com/3d/premium/thumb/deliveryman-riding-scooter-5349139-4466371.png',
                          placeholder: (context, i) => Container(
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Icon(
                        Icons.pin_drop_outlined,
                        size: 25,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      Container(
                        width: 200,
                        margin:const EdgeInsets.only(left: 10),
                        child: Consumer<OrderProvider>(
                          builder: (context, value, child) {
                            return value.address != null &&
                                    value.selectedTownship != null
                                ? Text(
                                    "${value.selectedTownship!.regionName},${value.selectedTownship!.townshipName},${value.address}",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  )
                                : const Text(
                                    'Yangon, Bahan , Natmauk (2) st Rose 113',
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: addressBox,
                    icon: const Icon(Icons.edit_outlined),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: DottedBorder(
                  strokeWidth: .8,
                  color: Colors.black,
                  child: Container(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Services : '),
                  Consumer<OrderProvider>(
                    builder: (context, value, child) {
                      return value.selectedTownship != null
                          ? Text(value.selectedTownship!.fees.toString())
                          : Text('0');
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total : ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Consumer2<CartProvider, OrderProvider>(
                    builder: (context, value, orderValue, child) {
                      return Text(
                          "${(value.total + (orderValue.selectedTownship != null ? orderValue.selectedTownship!.fees : 0 ) - (orderValue.coupon != null ? orderValue.coupon!.amount : 0))}");
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                overlayColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.surfaceVariant),
                splashColor: Theme.of(context).colorScheme.secondaryContainer,
                onTap: payment,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // color: ,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Payment Now'.toUpperCase(),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

Container RegionDropDown() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12.0),
    child: DropdownButtonHideUnderline(
      child: Consumer<OrderProvider>(
        builder: (context, value, child) {
          return DropdownButton(
            borderRadius: BorderRadius.circular(8),
            dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
            value: value.selectedRegion,
            hint: const Text('Select Region'),
            onChanged: (va) {
              return value.changeSelectedRegion(va);
            },
            items: value.regions.isEmpty
                ? [
                    const DropdownMenuItem(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                    )
                  ]
                : value.regions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option.region),
                    );
                  }).toList(),
          );
        },
      ),
    ),
  );
}

Consumer<OrderProvider> TownshipDropDown() {
  return Consumer<OrderProvider>(
    builder: (context, value, child) {
      return value.townships.isEmpty
          ? SizedBox()
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                iconDisabledColor: Colors.black,
                borderRadius: BorderRadius.circular(8),
                dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
                value: value.selectedTownship,
                hint: const Text('Select Township'),
                onChanged: (va) {
                  return value.changeSelectedTownship(va);
                },
                items: value.townships.isEmpty
                    ? [
                        const DropdownMenuItem(
                          child: Text('Select Township'),
                        )
                      ]
                    : value.townships.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option.townshipName),
                        );
                      }).toList(),
              )),
            );
    },
  );
}

Padding DeliText() {
  return const Padding(
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    child: Text(
      'Delivery Address',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}

Padding OrderConfrimText() {
  return const Padding(
    padding: const EdgeInsets.only(bottom: 15.0),
    child: Text(
      'Order Confirmation',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}

SizedBox Payments(context) {
  return SizedBox(
    height: 160,
    child: Consumer<OrderProvider>(
      builder: (context, value, child) {
        return value.payments.isEmpty
            ? const Center(
                child: Loading('Payemnt Not Found!', double.infinity, 160, 20),
              )
            : ListView.builder(
                itemCount: value.payments.length,
                itemBuilder: (context, i) {
                  final payment = value.payments[i];
                  return Container(
                    height: 75,
                    width: double.infinity,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Provider.of<OrderProvider>(context)
                                  .selectedPaymentId ==
                              payment.id
                          ? Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.primary)
                          : Border.all(width: .5, color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ListTile(
                      enableFeedback: true,
                      focusColor:
                          Theme.of(context).colorScheme.tertiaryContainer,
                      splashColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      onTap: () {
                        Provider.of<OrderProvider>(context, listen: false)
                            .changeSelectedPayementId(payment.id);
                      },
                      leading: Container(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: payment.photo,
                            placeholder: (context, i) => Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            ),
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          payment.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      subtitle: Text(payment.account),
                      trailing: Consumer<OrderProvider>(
                        builder: (context, value, child) {
                          return value.selectedPaymentId == payment.id
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : Container(
                                  width: 10,
                                );
                        },
                      ),
                    ),
                  );
                });
      },
    ),
  );
}
