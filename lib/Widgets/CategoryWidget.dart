import 'package:ab_pharmacy/Provider/BannerProvider.dart';
import 'package:ab_pharmacy/Provider/ProductProvider.dart';
import 'package:ab_pharmacy/Screen/Search.dart';
import 'package:ab_pharmacy/Widgets/BannerWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 5,
      child: FutureBuilder(
        future: Provider.of<BannerProvider>(context, listen: false)
            .fetchCategories(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Loading('Loading', double.infinity, 155, 20),
            );
          }

          if (snapShot.connectionState == ConnectionState.done) {
            final categories = Provider.of<BannerProvider>(context).categories;

            return categories.isEmpty
                ? const Center(
                    child: Loading('No Categories', double.infinity, 100, 20))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    itemCount: categories.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      final category = categories[i];
                      return Container(
                        width: 150,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          overlayColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.secondaryContainer),
                          splashColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => subCategoryModalBottomSheet(
                              context, category.name, category.subCategories),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: category.photo,
                                    fit: BoxFit.contain,
                                    width: 90,
                                    height: 90,
                                    placeholder: (context, url) => const Center(
                                      child: Loading(
                                          'Fetch..', double.infinity, 50, 10),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),

                                FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(fontSize: 13),
                                    ),)
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
          }
          return const Center(
              child: Loading('Loading', double.infinity, 155, 20));
        },
      ),
    );
  }
}

Future<dynamic> subCategoryModalBottomSheet(
    BuildContext context, String categoryName, List subcategories) {
  return showModalBottomSheet(
    backgroundColor: Theme.of(context).colorScheme.surface,
    context: context,
    builder: (context) {
      return Container(
        height: 400,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                categoryName.toUpperCase(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            subcategories.isEmpty
                ? const Center(child: Text('No Sub Categories Found'))
                : Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.only(top: 10),
                      itemCount: subcategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 50,
                              mainAxisSpacing: 8),
                      itemBuilder: (context, i) {
                        return Container(
                           decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    offset:const Offset(3, 3),
                                    blurRadius: 0,
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              overlayColor: MaterialStateProperty.all(
                                  Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer),
                              splashColor: Theme.of(context)
                                  .colorScheme
                                  .secondary,
                              onTap: () {
                                Provider.of<ProductProvider>(context, listen: false)
                                    .addBrandId(subcategories[i].id.toString());
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const SearchScreen()));
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,

                                child: FittedBox(
                                  child: Text(subcategories[i].name),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      );
    },
  );
}
