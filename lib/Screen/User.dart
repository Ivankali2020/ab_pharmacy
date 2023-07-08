import 'dart:io';

import 'package:ab_pharmacy/Provider/UserProvider.dart';
import 'package:ab_pharmacy/Screen/Auth/Login.dart';
import 'package:ab_pharmacy/Screen/Auth/Verify.dart';
import 'package:ab_pharmacy/Screen/Order.dart';
import 'package:ab_pharmacy/Widgets/SnackBarWidget.dart';
import 'package:ab_pharmacy/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class User extends StatefulWidget {
  User({Key? key}) : super(key: key);

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController userPhone = TextEditingController();
  TextEditingController userName = TextEditingController();

  Future<void> submit(context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Map<String, dynamic> data = {
      'name': userName.text,
      'credentials': userPhone.text,
    };

    final response = await Provider.of<UserProvider>(context, listen: false)
        .profileUpdate(data);

    ///what is i don't know for suggestion only
    if (response['status'] == true) {
      snackBarWidget(context, response['message']);
      Navigator.of(context).pop();
    } else {
      snackBarWidget(context, 'SOMETHING WAS WRONG!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchAppInfomation();
  }

  @override
  Widget build(BuildContext context) {
    // getTokenAndUser();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    Future<void> _logout() async {
      final Map<String, dynamic> response =
          await Provider.of<UserProvider>(context, listen: false).logOut();

      if (response['status']) {
        snackBarWidget(context, response['message']);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Main(title: 'title')));
      } else {
        snackBarWidget(context, response['message']);
      }
    }

    Future<void> _changeImage(context) async {
      final picker = ImagePicker();
      final data = await picker.pickImage(source: ImageSource.gallery);

      if (data != null) {
        final response = Provider.of<UserProvider>(context, listen: false)
            .changeImage(File(data.path));
      }
    }

    Future<void> _showModalBox(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text('Profile Edit'),
            content: Form(
              key: _formKey,
              child: Container(
                height: 250,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: userName,
                        scrollPadding: const EdgeInsets.all(10),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(14),
                          labelText: 'User Name',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                        ),
                        validator: (value) {
                          if (value == '') {
                            return 'Required';
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: userPhone,
                        scrollPadding: EdgeInsets.all(10),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(14),
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                        ),
                        validator: (value) {
                          if (value == '') {
                            return 'Required Phone';
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        overlayColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.surfaceVariant),
                        splashColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        onTap: () => submit(context),
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 3),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Verify()));
              },
              icon: Icon(Icons.code))
        ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Consumer<UserProvider>(
                            builder: (context, value, child) {
                              return CachedNetworkImage(
                                imageUrl: value.userData != null
                                    ? value.userData!.photo
                                    : 'https://cdn3d.iconscout.com/3d/premium/thumb/person-6877458-5638294.png',
                                placeholder: (context, i) =>
                                    const CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      userProvider.token == ''
                          ? Container()
                          : Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () => _changeImage(context),
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                    ],
                  ),
                  Consumer<UserProvider>(
                    builder: (context, value, child) {
                      return value.userData == null
                          ? InkWell(
                              borderRadius: BorderRadius.circular(8),
                              overlayColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.surfaceVariant),
                              splashColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
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
                                width: 150,
                                height: 35,
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
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.userData!.name,
                                  style: GoogleFonts.bebasNeue(
                                      fontSize: 25, letterSpacing: 3),
                                ),
                                Text(
                                  value.userData!.credentials,
                                  style: GoogleFonts.bebasNeue(
                                      fontSize: 25, letterSpacing: 3),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  overlayColor: MaterialStateProperty.all(
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant),
                                  splashColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  onTap: () => _showModalBox(context),
                                  child: Container(
                                    width: 100,
                                    height: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      // color: ,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Edit'.toUpperCase(),
                                    ),
                                  ),
                                )
                              ],
                            );
                    },
                  )
                ],
              ),
              userProvider.token == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            overlayColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.surfaceVariant),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const Order()));
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
                                'Orders'.toUpperCase(),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            overlayColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.surfaceVariant),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            onTap: _logout,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                // color: ,
                                border: Border.all(
                                    color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Log out'.toUpperCase(),
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          SocialMedia()
        ],
      ),
    );
  }
}

class SocialMedia extends StatelessWidget {
  const SocialMedia({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, value, chid) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              overlayColor: MaterialStateProperty.all(Colors.lightBlueAccent),
              splashColor: Colors.blueAccent,
              onTap: () async {
                if (value.appInfomation != null) {
                  if (value.appInfomation!.messagerId == null) {
                    return;
                  }
                  final url = Uri.parse(value.appInfomation!.messagerId!);

                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    print('Can not launch');
                  }
                  ;
                }
              },
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // color: ,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.facebook_outlined,
                        color: Colors.grey,
                      ),
                      Text(
                        'Facebook Page'.toUpperCase(),
                      ),
                    ],
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              overlayColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.surfaceVariant),
              splashColor: Theme.of(context).colorScheme.secondaryContainer,
              onTap: () async {
                if (value.appInfomation != null) {
                  if (value.appInfomation!.pageId == null) {
                    return;
                  }
                  final url = Uri.parse(value.appInfomation!.pageId!);

                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    print('Can not launch');
                  }
                  ;
                }
              },
              child: Container(
                width: double.infinity,
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // color: ,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.messenger_outlined,
                      color: Colors.grey,
                    ),
                    Text(
                      'Messenger'.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              overlayColor: MaterialStateProperty.all(Colors.lightBlueAccent),
              splashColor: Colors.lightBlue,
              onTap: () async {
                if (value.appInfomation != null) {
                  if (value.appInfomation!.phone == null) {
                    return;
                  }
                  final url = Uri.parse(value.appInfomation!.phone!);

                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    print('Can not launch');
                  }
                  ;
                }
              },
              child: Container(
                width: double.infinity,
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // color: ,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.wechat_outlined,
                      color: Colors.grey,
                    ),
                    Text(
                      'Viber'.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 45,
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // color: ,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YAddress'.toUpperCase(),
                  ),
                  value.appInfomation != null
                      ? Text(value.appInfomation!.address!)
                      : CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
