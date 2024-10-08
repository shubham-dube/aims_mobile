import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static void showSnackBar(String message){
    ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text(message)),
    );
  }

  static void showAlert(String title, String message) {
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: ()=> Navigator.of(context).pop(),
                  child: const Text('OK')
              )
            ],
          );
        }
    );
  }

  static void saveLoginState(bool isLoggedIn, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    print("sessionId on Saving : $sessionId");
    prefs.setBool('isLoggedIn', isLoggedIn);
    prefs.setString('sessionId', sessionId);
  }

  static Future<String> retrieveSession() async {
    final prefs = await SharedPreferences.getInstance();
    String sessionId = prefs.getString('sessionId') ?? "";
    print("sessionId on getting : $sessionId");
    return sessionId;
  }

  static Future<bool> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }

  static void navigateToScreen(BuildContext context, dynamic screen){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen)
    );
  }

  static void shiftToScreen(BuildContext context, dynamic screen){
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen)
    );
  }


  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static Future<bool> isDarkMode()async {
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    return isDarkMode;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getFormattedDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];

    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(i, i + rowSize > widgets.length ? widgets.length - i : rowSize);
      wrappedList.add(Row(children: rowChildren));
    }

    return wrappedList;
  }


}