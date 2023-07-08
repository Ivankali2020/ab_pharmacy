import 'package:ab_pharmacy/Provider/AuthManager.dart';
import 'package:ab_pharmacy/Provider/CartProvider.dart';
import 'package:provider/provider.dart';

import '../Widgets/BannerWidget.dart';
import '../main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CheckoutSuccess extends StatelessWidget {
  const CheckoutSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
            onPressed: () async {
              final  token = await AuthManager.getToken();
              Provider.of<CartProvider>(context, listen: false)
                  .fetchCarts(token!, isRefresh: true);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const Main(title: 'WELCOME'),
                  ),
                  (route) => false);
            },
            child: const Icon(Icons.home)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl:
                      'https://cdn3d.iconscout.com/3d/premium/thumb/deliveryman-riding-scooter-5349139-4466371.png',
                  fit: BoxFit.contain,
                  width: 300,
                  placeholder: (context, i) {
                    return Container(
                      alignment: Alignment.center,
                      height: 300,
                      width: 200,
                      child: const CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Shimmer.fromColors(
                enabled: true,
                baseColor: Theme.of(context).colorScheme.secondaryContainer,
                highlightColor: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Text(
                    'Thanks for shopping with us',
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.bebasNeue(fontSize: 15, letterSpacing: 3),
                  ),
                ),
              ),
            ],
          ),
          const Text(
            'The fastest way delivering to your location',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
