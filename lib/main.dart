import 'package:ab_pharmacy/Provider/AuthManager.dart';
import 'package:ab_pharmacy/Provider/BannerProvider.dart';
import 'package:ab_pharmacy/Provider/CartProvider.dart';
import 'package:ab_pharmacy/Provider/Connection.dart';
import 'package:ab_pharmacy/Provider/NavProvider.dart';
import 'package:ab_pharmacy/Provider/OrderProvider.dart';
import 'package:ab_pharmacy/Provider/ProductProvider.dart';
import 'package:ab_pharmacy/Provider/UserProvider.dart';
import 'package:ab_pharmacy/colors_schedume.g.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await AuthManager.getUserAndToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Connection()),
        ChangeNotifierProvider.value(value: OrderProvider()),
        ChangeNotifierProvider.value(value: UserProvider(data)),
      ],
      child: const MyApp(),
    ),
  );
}

class Main extends StatefulWidget {
  const Main({super.key, required this.title});
  final String title;

  @override
  State<Main> createState() => _MainState();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BannerProvider()),
        ChangeNotifierProvider(create: (context) => NavProvider()),
        // ChangeNotifierProxyProvider<UserProvider, ProductProvider>(
        //     create: (context) => ProductProvider(''),
        //     update: (context, userProvider, productProvider) {
        //       final token = userProvider.token;
        //       return ProductProvider(token!);
        //     }),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        home: const Main(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavProvider>(context);
    return Scaffold(
      body:navProvider.pages[navProvider.activeIndex]['page'],
      bottomNavigationBar: NavigationBar(
        selectedIndex: navProvider.activeIndex,
        destinations: [
          ...navProvider.pages
              .map(
                (e) => NavigationDestination(
                  icon: Icon(e['icon']),
                  selectedIcon: Icon(e['active_icon'],
                      color: Theme.of(context).colorScheme.primary),
                  label: e['name'],
                  tooltip: e['name'],
                ),
              )
              .toList()
        ],
        height: 75,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) {
          navProvider.changeIndex(value);
        },
      ),
    );
  }
}
