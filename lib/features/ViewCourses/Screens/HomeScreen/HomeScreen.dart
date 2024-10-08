import 'dart:convert';

import 'package:AIMS_MOBILE/common/theme_model.dart';
import 'package:AIMS_MOBILE/common/theme_provider.dart';
import 'package:AIMS_MOBILE/features/Authentication/Screens/LoginScreen/LoginScreen.dart';
import 'package:AIMS_MOBILE/features/ViewCourses/Screens/MyCourses/MyCourses.dart';
import 'package:AIMS_MOBILE/features/ViewCourses/Screens/MyGradesScreen/MyGradesScreen.dart';
import 'package:AIMS_MOBILE/utils/constants/image_strings.dart';
import 'package:AIMS_MOBILE/utils/device/device_utility.dart';
import 'package:AIMS_MOBILE/utils/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.sessionId, required this.userName});
  final String sessionId;
  final String userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController queryController = TextEditingController();
  final baseUrl = 'http://192.168.113.121:5001';

  @override
  void initState() {
    super.initState();
  }
  final academic = [
    'assets/images/a1.png',
    'assets/images/a2.png',
    'assets/images/a3.png'
  ];
  final academicTexts = [
    'My Courses',
    'My Grades',
    'All Courses'
  ];

  dynamic getScreen(index){
    switch(index){
      case 0: return MyCourses(sessionId: widget.sessionId);
      case 1: return MyGradesScreen(sessionId: widget.sessionId, studentName: widget.userName,);
      case 2: return MyCourses(sessionId: widget.sessionId);
      default: return MyCourses(sessionId: widget.sessionId);
    }
  }
  void showLogoutConfirmation() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('LOGOUT'),
            content: const Text('Do you really want to logout ?'),
            actions: [
              TextButton(
                  onPressed: ()=> Navigator.of(context).pop(),
                  child: const Text('CANCEL')
              ),
              TextButton(
                  onPressed: (){
                    logOut();
                  },
                  child: const Text('YES')
              )
            ],
          );
        }
    );
  }


  void logOut() async {
      try{
        final jsonResponse = await http.post(
            Uri.parse('$baseUrl/api/v1/disposeUser'),
            headers: {"Content-Type":"application/json"},
            body: jsonEncode({"sessionId": widget.sessionId})
        );

        if(jsonResponse.statusCode == 200){
          final response = jsonDecode(jsonResponse.body);
          if(response['status'].toLowerCase() != 'error') {

            HelperFunctions.saveLoginState(false, widget.sessionId);
            HelperFunctions.shiftToScreen(context, const LoginScreen());
            HelperFunctions.showAlert('LOGOUT', 'Logout Successful !');

          } else{
            HelperFunctions.showAlert("LOGOUT", response['message']);
          }
        } else {
          HelperFunctions.showAlert("LOGOUT", 'Error in logging out !');
        }

      } catch(e){
        print(e);
        bool isConnected = await DeviceUtils.isConnected();
        if(!isConnected) {
          HelperFunctions.showAlert('AIMS MOBILE', 'Please Connect to Internet Connection');
        }
        else {
          HelperFunctions.showAlert('AIMS MOBILE', 'An error occurred while logging out ! Please retry again.');
        }
      }
  }

  final curriculum = [
    'assets/images/c3.png',
    'assets/images/c1.webp',
    'assets/images/c2.webp'
  ];

  final curriculumTexts = [
    'Time Table',
    'Curriculum',
    'Calendar'
  ];

  final people = [
    'assets/images/faculty.png',
    'assets/images/p1.png'
  ];

  final peopleTexts = [
    'Faculties',
    'Students'
  ];

  final wishes = [
    "Good Morning",
    "Good Afternoon",
    "Good Evening",
    "Good Night",
  ];

  String getWish(){
    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;
    if(hour<12 && hour>=5) {
      return wishes[0];
    }
    if(hour<17 && hour>=12) {
      return wishes[1];
    }
    if(hour<19 && hour>=17) {
      return wishes[2];
    }
    else {
      return wishes[3];
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
            GestureDetector(
                onTap: (){
                  setState(() {
                    Provider.of<ThemeModel>(context, listen: false).toggleTheme();
                  });
                },
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Provider.of<ThemeProvider>(context).isDark ? const Icon( Icons.light_mode_outlined, color: Colors.white,): const Icon(Icons.dark_mode_outlined)
                    ),
                    Text(Provider.of<ThemeProvider>(context).isDark ?'Light Mode':'Dark Mode', style: !Provider.of<ThemeProvider>(context).isDark ?const TextStyle(color: Color(
                        0xFF18215B)): const TextStyle(color: Colors.white)),
                    Expanded(
                        child: TextButton(
                          onPressed: () {
                            showLogoutConfirmation();
                          },
                          child: const Text('Logout'),
                        )
                    )
                  ],
                )
            ),
            const SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getWish(), style: TextStyle(fontSize: 24,
                          color: !Provider.of<ThemeProvider>(context).isDark ?const Color(
                              0xFF18215B):
                          const Color(0xFFFFFFFF))),
                      Text(widget.userName, style: Theme.of(context).textTheme.bodyMedium,)
                    ],
                  ),

                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage(FImages.profileImage),
                        fit: BoxFit.contain
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                          0xFF000434):Colors.white, width: 4)
                    ),
                  )
                ],
              ),

            const SizedBox(height: 30,),

            Text('Academic', style: Theme.of(context).textTheme.headlineSmall,),

            const SizedBox(height: 30,),

            SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: academic.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    width: 115,
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                          0xFF000811):
                      Colors.white,
                      border: Border.all(
                        color: Colors.black12,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 70,
                            child: Image.asset(academic[index])
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(academicTexts[index], style: Theme.of(context).textTheme.bodySmall,),
                        ),
                        SizedBox(
                          height: 30,
                          width: 80,
                          child: ElevatedButton(
                              onPressed: (){
                                HelperFunctions.navigateToScreen(context, getScreen(index));
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0, // no elevation
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('View', style: TextStyle(fontSize: 12),),
                                  Icon(Icons.fast_forward_rounded)
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30,),

            Text('Time Table & Curriculum', style: Theme.of(context).textTheme.headlineSmall,),

            const SizedBox(height: 30,),

            SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: curriculum.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    width: 115,
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                            0xFF000811):
                        Colors.white,
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                            height: 70,
                            child: Image.asset(curriculum[index])
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(curriculumTexts[index], style: Theme.of(context).textTheme.bodySmall,),
                        ),
                        SizedBox(
                          height: 30,
                          width: 80,
                          child: ElevatedButton(
                              onPressed: (){
                                // HelperFunctions.navigateToScreen(context, SubCategoryScreen(category: todoListext[index], moduleNo: index+1));
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0, // no elevation
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('View', style: TextStyle(fontSize: 12),),
                                  Icon(Icons.fast_forward_rounded)
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30,),

            Text('People', style: Theme.of(context).textTheme.headlineSmall,),

            const SizedBox(height: 30,),

            SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: people.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    width: 115,
                    decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                            0xFF000811):
                        Colors.white,
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                            height: 70,
                            child: Image.asset(people[index])
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(peopleTexts[index], style: Theme.of(context).textTheme.bodySmall,),
                        ),
                        SizedBox(
                          height: 30,
                          width: 80,
                          child: ElevatedButton(
                              onPressed: (){
                                // HelperFunctions.navigateToScreen(context, SubCategoryScreen(category: todoListext[index], moduleNo: index+1));
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0, // no elevation
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('View', style: TextStyle(fontSize: 12),),
                                  Icon(Icons.fast_forward_rounded)
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
