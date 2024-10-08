import 'package:AIMS_MOBILE/features/Authentication/Screens/LoginScreen/LoginScreen.dart';
import 'package:get/get.dart';
import 'JWT_Token.dart';
import '../../../utils/http/routes.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/helper/helper_functions.dart';


class AuthService {
  Future<void> signup(Map<String,dynamic> data) async {
    final response = await FHttpHelper.post(signupUrl, data);

    if(response['statusCode'] == 200 || response['status']){
      HelperFunctions.shiftToScreen(Get.context!,const LoginScreen());
      HelperFunctions.showAlert("Sign Up", "User Registration Successfully. Please Login");
    }
    else {
      HelperFunctions.showAlert("Sign Up", "User Registration Failed!\n Please Retry Again");
    }
  }

  Future<void> login(Map<String,dynamic> data) async {
    final response = await FHttpHelper.post(loginUrl, data);

    if (response['statusCode'] == 200 || response['status']) {
      TokenService().storeToken(response['token']);
      // HelperFunctions.shiftToScreen(Get.context!,const BottomNavBarController());
      HelperFunctions.showAlert("Log in", "User Logged In Successfully");

    } else {
      HelperFunctions.showAlert("Log in", response['message']);
    }

  }
}