import 'package:ab_pharmacy/Modal/Products.dart';
import 'package:ab_pharmacy/Provider/AuthManager.dart';
import 'package:ab_pharmacy/Provider/CartProvider.dart';
import 'package:ab_pharmacy/Screen/Auth/Login.dart';
import 'package:ab_pharmacy/Widgets/BannerWidget.dart';
import 'package:ab_pharmacy/Widgets/SnackBarWidget.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Screen/Cart.dart' as CartScreen;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final _controller = PageController();

    Future<void> addToCartFunction(
        BuildContext context, Product product) async {
      final token = await AuthManager.getToken();
      if (token == '') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => Login(name: '', password: '')),
          (route) => false,
        );
      }
      final Map<String, dynamic> response =
          await Provider.of<CartProvider>(context, listen: false)
              .addToCart(product, token!);

      if (response['status']) {
        snackBarWidget(context, response['message']);
      } else {
        print(response);
        snackBarWidget(context, response['message']);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ImageSlider(_controller, context),
            Positioned(
              left: 0,
              top: 5,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(CupertinoIcons.chevron_left),
              ),
            ),
            Positioned(
              right: 0,
              top: 5,
              child: IconButton(
                onPressed: () {},
                icon: Icon(CupertinoIcons.cart),
              ),
            ),
            AddToCart(context, addToCartFunction),
          ],
        ),
      ),
    );
  }

  Padding ImageSlider(PageController _controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            margin: EdgeInsets.only(top: 50),
            width: double.infinity,
            height: 300,
            child: PageView.builder(
              controller: _controller,
              itemCount: product.photos.length,
              itemBuilder: (context, i) {
                return BannerImageWidget(
                  photo: product.photos[i],
                );
              },
            ),
          ),
          Center(
            child: SmoothPageIndicator(
              controller: _controller,
              count: product.photos.length,
              effect: ExpandingDotsEffect(
                dotWidth: 6,
                dotHeight: 5,
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Color.fromARGB(255, 240, 240, 240),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProductName(context),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CategoryBrand(),
          ),
          const SizedBox(
            height: 15,
          ),
          HtmlWidget(product.detail),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Positioned AddToCart(BuildContext context, Function addToCartFunction) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 70,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: const Border(
                top: BorderSide(color: Color.fromARGB(255, 232, 232, 232)))),
        width: double.infinity,
        // color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Minmun Quantity',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text(
                      product.MOQ.toString(),
                      style: GoogleFonts.bebasNeue(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 2,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const Text(
                      ' QTY',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
            Row(
              children: [
                goToCartButton(context),
                AddToCartButton(context, addToCartFunction),
              ],
            )
          ],
        ),
      ),
    );
  }

  Material AddToCartButton(BuildContext context, Function addToCartFunction) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        overlayColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer),
        splashColor: Theme.of(context).colorScheme.secondaryContainer,
        onTap: () => addToCartFunction(context, product),
        child: Container(
          width: 150,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.zero,
                topLeft: Radius.circular(0),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8)),
          ),
          child: Consumer<CartProvider>(
            builder: (context, value, child) {
              return value.isAdding
                  ? Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    )
                  : Text(
                      'Add to Cart'.toUpperCase(),
                    );
            },
          ),
        ),
      ),
    );
  }

  InkWell goToCartButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      overlayColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.tertiaryContainer),
      focusColor: Theme.of(context).colorScheme.tertiaryContainer,
      splashColor: Theme.of(context).colorScheme.secondaryContainer,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CartScreen.Cart()),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.zero,
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(0)),
        ),
        child: const Icon(CupertinoIcons.cart),
      ),
    );
  }

  Column CategoryBrand() {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Container(
            width: double.infinity,
            // padding: EdgeInsets.symmetric(horizontal: 20),
            height: 35,
            alignment: Alignment.centerLeft,
            // decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey),
            //     borderRadius: BorderRadius.circular(8)),
            child: Text(
              "Category : ${product.categoryName.toUpperCase()}",
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Container(
            width: double.infinity,
            height: 35,
            // padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            // decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey),
            //     borderRadius: BorderRadius.circular(8)),
            child: Text(
              "SubCategory : ${product.brandName.toUpperCase()}",
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Selling Unit',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  product.sellingUnit,
                  style: TextStyle(fontSize: 13),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Packing Size',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  product.packingSize,
                  style: TextStyle(fontSize: 13),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  Row ProductName(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              product.name,
              style: GoogleFonts.bebasNeue(fontSize: 22, letterSpacing: 2),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Made In ${product.madeIn}",
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).colorScheme.primary),
            ),
            // const SizedBox(
            //   height: 5,
            // ),
            // Text(
            //   product.brandName.toUpperCase(),
            //   style: TextStyle(fontSize: 13),
            // ),
          ],
        ),
        product.discountPrice != 0
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 10),
                    child: Text(
                      product.price.toString() + ' Ks',
                      style: const TextStyle(
                          color: Colors.redAccent,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      product.discountPrice.toString() + ' Ks',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  product.price.toString() + ' Ks',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
      ],
    );
  }
}
