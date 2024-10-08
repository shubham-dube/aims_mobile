import 'package:AIMS_MOBILE/utils/device/device_utility.dart';
import '../../../utils/http/routes.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/helper/helper_functions.dart';


class DataFetchingService {

  Future<Map<String,dynamic>> getFinanceCategories() async {
    final responses = await FHttpHelper.get(sectionUrl);

    if(responses['jsonResponse'].statusCode == 200){
      return responses['responseBody'];
    }
    else {
      if(await DeviceUtils.isConnected()){
        HelperFunctions.showAlert("Learning", "An error occurred!\nPlease Retry Again.");
      } else {
        HelperFunctions.showAlert("Learning", "Please Connect to the Internet !\nYou are offline.");
      }
      return {"status": "error"};

    }
  }

}