
  import 'dart:convert';
  import 'package:AIMS_MOBILE/common/theme_provider.dart';
  import 'package:AIMS_MOBILE/features/Authentication/Screens/LoginScreen/LoginScreen.dart';
  import 'package:AIMS_MOBILE/utils/device/device_utility.dart';
  import 'package:AIMS_MOBILE/utils/theme/theme.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:provider/provider.dart';
  import 'utils/helper/helper_functions.dart';
  import 'package:http/http.dart' as http;


  class App extends StatefulWidget {
    const App({super.key});

    @override
    State<App> createState() => _AppState();
  }

  class _AppState extends State<App> with WidgetsBindingObserver{
    final baseUrl = 'http://192.168.10.142:5001';
    bool isLoggedIn = false;
    String sessionId = '';

    @override
    initState() {
      super.initState();
      WidgetsBinding.instance.addObserver(this);
      loadLoadingState();
    }

    void loadLoadingState() async {
      isLoggedIn = await HelperFunctions.getLoginState();
      sessionId = await HelperFunctions.retrieveSession();
      setState(() {});
    }

    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) async {
      super.didChangeAppLifecycleState(state);
      if (state == AppLifecycleState.detached) {
         final sessionId = await HelperFunctions.retrieveSession();
         try{
           final jsonResponse = await http.post(
               Uri.parse('$baseUrl/api/v1/disposeUser'),
               headers: {"Content-Type":"application/json"},
               body: jsonEncode({"sessionId": sessionId})
           );

           if(jsonResponse.statusCode == 200){
             final response = await jsonDecode(jsonResponse.body);
             if(response['status'].toLowerCase() != 'error') {
               setState(() {
                 isLoggedIn = false;
               });
               HelperFunctions.showAlert('LOGOUT', 'Logout Successful !');

             } else{
               HelperFunctions.showAlert("LOGOUT", response['message']);
             }
           } else {
             HelperFunctions.showAlert("LOGOUT", 'Error in logging out !');
           }

         } catch(e){
           bool isConnected = await DeviceUtils.isConnected();
           if(!isConnected) {
             HelperFunctions.showAlert('AIMS MOBILE', 'Please Connect to Internet Connection');
           }
           else {
             HelperFunctions.showAlert('AIMS MOBILE', 'An error occurred while logging out ! Please retry again.');
           }
         }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.theme,
              theme: FAppTheme.lightTheme,
              darkTheme: FAppTheme.darkTheme,
              home: const LoginScreen()
            );
          }
      );
    }
  }