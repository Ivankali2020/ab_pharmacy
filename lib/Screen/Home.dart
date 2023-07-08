import 'package:ab_pharmacy/Modal/Products.dart';
import 'package:ab_pharmacy/Provider/BannerProvider.dart';
import 'package:ab_pharmacy/Provider/ProductProvider.dart';
import 'package:ab_pharmacy/Screen/ProductDetail.dart';
import 'package:ab_pharmacy/Screen/Search.dart';
import 'package:ab_pharmacy/Widgets/BannerWidget.dart';
import 'package:ab_pharmacy/Widgets/CategoryWidget.dart';
import 'package:ab_pharmacy/Widgets/ProductWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BannerWidget(),
            const CategoryWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:15.0,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Pharmacy',
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Provider.of<ProductProvider>(context, listen: false)
                          .addSearchProduct();
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => SearchScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      child: Text(
                        'See more',
                        style: GoogleFonts.nunito(fontSize: 10),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Expanded(
              child: ProductWidget(),
            )
          ],
        ),
      ),
    );
  }
}
