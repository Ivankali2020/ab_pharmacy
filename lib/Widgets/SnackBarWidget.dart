 import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarWidget(BuildContext context,String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }