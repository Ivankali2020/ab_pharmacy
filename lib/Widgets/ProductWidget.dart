import 'package:ab_pharmacy/Modal/Products.dart';
import 'package:ab_pharmacy/Provider/ProductProvider.dart';
import 'package:ab_pharmacy/Screen/Order.dart';
import 'package:ab_pharmacy/Screen/ProductDetail.dart';
import 'package:ab_pharmacy/Widgets/BannerWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    super.key,
  });

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<ProductProvider>(context, listen: false).loadMore();
        print('loadMore');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void detailPage(Product product) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProductDetail(product: product)));
    }

    return FutureBuilder(
      future:
          Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Loading('Loading', double.infinity, 155, 20),
          );
        }

        if (snapShot.connectionState == ConnectionState.done) {
          final prodcuts = Provider.of<ProductProvider>(context).products;
          return prodcuts.isEmpty
              ? const Center(
                  child: Loading('No Products', double.infinity, 100, 20))
              : GridView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: prodcuts.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.7),
                  itemBuilder: (context, i) {
                    if (i == prodcuts.length) {
                      return Provider.of<ProductProvider>(context,
                                  listen: false)
                              .isNotDataProducts
                          ? const Center(
                              child: Text('Catch All Product!'),
                            )
                          : const Loading('Fetching Data', double.infinity, 50, 12);
                    }
                    final product = prodcuts[i];
                    return ProductItem(product: product);
                  },
                );
        }
        return const Center(
            child: Loading('Loading', double.infinity, 155, 20));
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  ProductItem({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.primary,
              offset: Offset(5, 5),
              blurRadius: 0,
              spreadRadius: 0)
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProductDetail(product: product)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: CachedNetworkImage(
                alignment: Alignment.center,
                imageUrl: product.photos[0],
                fit: BoxFit.cover,
                width: 120,
                height: 120,
                placeholder: (context, url) => const Center(
                  child: Loading('Fetch..', double.infinity, 50, 10),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            // Text(
            //   product.categoryName,
            //   style: const TextStyle(letterSpacing: 2, fontSize: 10),
            // ),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                product.brandName,
                style: const TextStyle(letterSpacing: 2, fontSize: 10),
              ),
            ),
            Text(product.name),
            product.discountPrice == 0
                ? Text(
                    product.price.toString() + ' ks',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  )
                : Row(
                    children: [
                      Text(
                        product.price.toString(),
                        style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        product.discountPrice.toString() + ' ks',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
            Container(
              alignment: Alignment.bottomRight,
              child: Text(
                "MOQ : ${product.MOQ} qty",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
