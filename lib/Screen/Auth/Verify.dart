import 'dart:io';

import 'package:ab_pharmacy/Provider/UserProvider.dart';
import 'package:ab_pharmacy/Screen/Auth/Register.dart';
import 'package:ab_pharmacy/Widgets/SnackBarWidget.dart';
import 'package:ab_pharmacy/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class Verify extends StatefulWidget {
  Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  bool _obscureText = true;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Future<void> submit(BuildContext context) async {
  //   if (!_key.currentState!.validate()) {
  //     return;
  //   }
  //   final Map<String, dynamic> data = {
  //     'credentials': userPhone.text,
  //     'password': userPassword.text,
  //     'fcm_token_key': 'HELLO',
  //   };
  //   final response =
  //       await Provider.of<UserProvider>(context, listen: false).Login(data);

  //   ///what is i don't know for suggestion only
  //   if (!context.mounted) return;
  //   if (response['status'] == true) {
  //     snackBarWidget(context, response['message']);
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //           builder: (context) => const Main(
  //             title: 'WELCOME',
  //           ),
  //         ),
  //         (route) => false);
  //   } else {
  //     snackBarWidget(context, 'SOMETHING WAS WRONG!');
  //   }
  // }

  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
    );


    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Center(
                child: CachedNetworkImage(
                  colorBlendMode: BlendMode.overlay,
                  imageUrl:
                      'https://cdn3d.iconscout.com/3d/premium/thumb/verify-security-2870306-2386774.png',
                  placeholder: (context, url) => Container(
                      width: 350,
                      height: 300,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator()),
                  width: 350,
                  height: 300,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 35),
              child: Text(
                'Verify Code',
                style: GoogleFonts.nunito(fontSize: 20),
              ),
            ),
            Form(
              key: _key,
              child: SizedBox(
                child: Pinput(
                  length: 5,
                  controller: controller,
                  focusNode: focusNode,
                  separator: Container(
                    height: 64,
                    width: 1,
                    color: Colors.white,
                  ),
                  forceErrorState: showError,
                  errorText: 'Error',
                  defaultPinTheme: defaultPinTheme,
                  showCursor: true,
                  onCompleted: (pin) {
                    setState(() => showError = pin != '55555');
                  },
                  errorPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ) ,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Register()),
                  (route) => false,
                )
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                alignment: Alignment.bottomRight,
                child: const Text(
                  'Resend Code',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container SubmitButton(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary,
            offset: Offset(5, 5),
            blurRadius: 0,
            spreadRadius: 0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          overlayColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.surfaceVariant),
          splashColor: Theme.of(context).colorScheme.secondaryContainer,
          onTap: () => {},
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            child: Consumer<UserProvider>(builder: (context, value, child) {
              return value.isLoading
                  ? CircularProgressIndicator()
                  : const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 18),
                    );
            }),
          ),
        ),
      ),
    );
  }
}
