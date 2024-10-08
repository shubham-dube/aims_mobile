import 'dart:convert';
import 'package:AIMS_MOBILE/common/theme_provider.dart';
import 'package:AIMS_MOBILE/utils/device/device_utility.dart';
import 'package:AIMS_MOBILE/utils/helper/helper_functions.dart';
import 'package:AIMS_MOBILE/utils/http/http_client.dart';
import 'package:AIMS_MOBILE/utils/http/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  TextEditingController queryController = TextEditingController();
  var learningCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    getFinanceCategories();
    super.initState();
  }

  void getFinanceCategories() async {
    setState(() {
      isLoading = true;
    });

    try{
      final responses = await FHttpHelper.get(sectionUrl);

      if(responses['jsonResponse'].statusCode == 200){
        setState(() {
          learningCategories = jsonDecode(responses['responseBody']);
          isLoading = false;
        });
      }
      else {
        setState(() {
          isLoading = false;
        });
        if(await DeviceUtils.isConnected()){
          HelperFunctions.showAlert("Learning", "An error occurred!\nPlease Retry Again.");
        } else {
          HelperFunctions.showAlert("Learning", "Please Connect to the Internet !\nYou are offline.");
        }
      }
    } catch(e){
      print(e);
      HelperFunctions.showAlert("Learning", "Internal Server Error Occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/laptopMoney.png'),
                ),
                const SizedBox(width: 30,),
                Expanded(child: Text("Let's learn more with AI based learning", style: Theme.of(context).textTheme.bodyMedium,)),

              ],
            ),

            const SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: DeviceUtils.getScreenSize(context).width*0.8,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                          0xFF000811):
                      Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: TextField(
                    controller: queryController,
                    decoration: InputDecoration(
                        hintText: 'Search Module',
                        suffixIcon: IconButton(
                          icon: const Icon(CupertinoIcons.search),
                          onPressed: () {},
                        ),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                        errorBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                        focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                        errorStyle: const TextStyle(fontSize: 0)
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Modules', style: Theme.of(context).textTheme.headlineSmall,),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                      onPressed: (){
                        getFinanceCategories();
                      },
                      icon:  isLoading? const SizedBox(height: 13,width: 13, child: CircularProgressIndicator(strokeWidth: 2,color: Colors.white,)):const Icon(Icons.refresh)),
                )
              ],
            ),

            const SizedBox(height: 30,),

            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: DeviceUtils.isLandscapeOrientation(context)? 4:2,
                childAspectRatio: 1,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: learningCategories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    // HelperFunctions.navigateToScreen(context, SubCategoryScreen(category: learningCategories[index]['name'], moduleNo: (index+1),));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 14,bottom: 14),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Provider.of<ThemeProvider>(context).isDark ?[Colors.primaries[index % Colors.primaries.length].shade900,Colors.primaries[(learningCategories.length-index) % Colors.primaries.length].shade900]:
                        [Colors.primaries[index % Colors.primaries.length].shade400,Colors.primaries[(learningCategories.length-index) % Colors.primaries.length].shade400],
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          width: 50,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                                  0xFF000811):
                              Colors.white,
                              shape: BoxShape.circle
                          ),
                          child: Center(child: Text((index+1).toString(), style: Theme.of(context).textTheme.bodySmall,)),
                        ),

                        Container(
                          width: 120,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 20,left: 12),
                          decoration: BoxDecoration(
                            color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                                0xFF000811):
                            Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text(learningCategories[index]['name']?? "", style: Theme.of(context).textTheme.bodySmall,)),
                        )

                      ],
                    ),
                  ),
                );
              },
            ),


          ],
        ),
      ),
    );
  }
}
