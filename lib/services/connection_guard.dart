import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config.dart';

class ConnectionGuard {
  /// True if the Supabase host can be reached.
  static Future<bool> isOnline() async {
    try {
      final host = Uri.parse(AppConfig.supabaseUrl).host;
      final result = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<void> closeApp() async {
    if (Platform.isAndroid) {
      await SystemNavigator.pop();
    } else {
      exit(0); // Windows, macOS, Linux
    }
  }

  /// Shows a message, then closes the app after 3 seconds.
  static Future<void> exitWithMessage(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('No internet connection'),
        content: Text('This app needs internet. It will close now.'),
      ),
    );
    await Future.delayed(const Duration(seconds: 3));
    await closeApp();
  }
}
