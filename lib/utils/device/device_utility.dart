import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:intl/intl.dart';

class DeviceUtils {
  // Method to get platform information
  static String getPlatform() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isFuchsia) {
      return 'Fuchsia';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'MacOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else {
      return 'Unknown';
    }
  }

  static Future<Map<String, String>> getDeviceInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Map<String, String> deviceInfo = {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'platform': getPlatform(),
    };
    return deviceInfo;
  }

  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  static bool validateEmail(String email) {
    final RegExp regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email);
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  static bool isLandscapeOrientation(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    if(orientation==Orientation.landscape){
      return true;
    }
    return false;
  }

  static bool isPortraitOrientation(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom != 0;
  }

  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

}
