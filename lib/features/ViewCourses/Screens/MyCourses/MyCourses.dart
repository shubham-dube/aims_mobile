import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:AIMS_MOBILE/common/theme_provider.dart';
import 'package:AIMS_MOBILE/utils/device/device_utility.dart';
import 'package:AIMS_MOBILE/utils/helper/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCourses extends StatefulWidget {
  const MyCourses({super.key, required this.sessionId});
  final String sessionId;

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  TextEditingController queryController = TextEditingController();
  final bool _isOpen = false;
  bool isLoading = false;
  Map<String, List> coursesData = {};
  Map<String, List> filteredCoursesData = {};

  String baseUrl = "http://192.168.113.121:5001";

  @override
  void initState() {
    fetchCourses();
    queryController.addListener(_filterCourses);
    super.initState();
  }

  void fetchCourses() async {
    setState(() {
      isLoading = true;
    });

    var reqBody = {
      "sessionId": widget.sessionId
    };

    try{
      var jsonResponse = await http.post(
          Uri.parse('$baseUrl/api/v1/getCourseHistory'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(reqBody)
      );

      if(jsonResponse.statusCode == 200){
        final response  = jsonDecode(jsonResponse.body);

        if(response['status'].toLowerCase() == "error"){
          setState(() {
            isLoading = false;
          });
           return HelperFunctions.showAlert('My Courses', response['message']);
        }

        for(int i=0;i<response['courses'].length;i++){
          final session = response['courses'][i]['hdrName'];
          if (coursesData[session] == null) {
            coursesData[session] = [];
          }
          coursesData[session]!.add(response['courses'][i]);
        }

        setState(() {
          filteredCoursesData = Map.from(coursesData);
          isLoading = false;

        });

      } else {
        setState(() {
          isLoading = false;
        });
        HelperFunctions.showAlert("AIMS MOBILE", 'Error in fetching Courses\n Please Login Again.');
      }
    } catch (e){
      print(e);
      setState(() {
        isLoading = false;
      });
      bool isConnected = await DeviceUtils.isConnected();
      if(!isConnected) {
        HelperFunctions.showAlert('AIMS MOBILE', 'Please Connect to Internet Connection');
      }
      else {
        HelperFunctions.showAlert('AIMS MOBILE', 'An error occurred while fetching courses ! Please retry again.');
      }
    }
  }

  void _filterCourses() {
    String query = queryController.text.toLowerCase();
    print(query);

    if (query.isNotEmpty) {
      setState(() {
        filteredCoursesData = Map.from(coursesData);  // Reset the filtered list to the full list
      });
    } else {
      Map<String, List> tempFilteredCourses = {};

      coursesData.forEach((key, list) {
        List tempFiltered = list.where((course) {
          bool matchesCourse = course['courseName'].toLowerCase().contains(query);
          bool matchesTeacher = course['instructorName'].toLowerCase().contains(query);
          return matchesCourse && matchesTeacher;
        }).toList();

        // Only add the filtered list if it's not empty
        if (tempFiltered.isNotEmpty) {
          tempFilteredCourses[key] = tempFiltered;
        }
      });

      setState(() {
        filteredCoursesData = tempFilteredCourses;
      });
    }
  }


  @override
  void dispose() {
    queryController.removeListener(_filterCourses);
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> keyList = coursesData.keys.toList();
    int count = -1;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("All Courses", style: Theme.of(context).textTheme.headlineLarge,),
                  const SizedBox(width: 10,),
                  SizedBox(
                    height: 90,
                      child: Image.asset('assets/logo/courses.png')
                  )
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
                          hintText: 'Search anything',
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

              const SizedBox(height: 20,),

              isLoading
                  ? const LinearProgressIndicator(color: Colors.blue)
                  : Column(
                children: keyList.map((key) {
                  count++;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$key ${(count==0)? "- Running Courses": ""}', style: Theme.of(context).textTheme.headlineSmall,),
                      const SizedBox(height: 20,),
                      ListView.builder(
                        shrinkWrap: true, // Limit ListView to its content size
                        physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scroll
                        itemCount: filteredCoursesData[key]?.length,
                        itemBuilder: (context, index) {
                          final courses = filteredCoursesData[key];
                          return CourseWidget(course: {
                            "name": courses?[index]['courseName'],
                            "credits": courses?[index]['credits'],
                            "regType": courses?[index]['courseRegTypeDesc'],
                            "code": courses?[index]['courseCd'],
                            "coordinator": courses?[index]['instructorName'],
                            "grade": courses?[index]['gradeDesc'],
                            "electiveType": courses?[index]['courseElectiveTypeDesc']
                          });
                        },
                      ),
                      const SizedBox(height: 20,),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseWidget extends StatefulWidget {
  const CourseWidget({super.key, required this.course});
  final Map<String, dynamic> course;

  @override
  State<CourseWidget> createState() => _CourseWidgetState();
}

class _CourseWidgetState extends State<CourseWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(15),
      width: DeviceUtils.getScreenSize(context).width,
      decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context).isDark ? const Color(
              0xFF000811):
          Colors.white,
          border: Border.all(color: Colors.black12, width: 1),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(widget.course['name'],
                  style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),),
              )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Container(
                padding: const EdgeInsets.all(5),
                // width: DeviceUtils.getScreenSize(context).width*0.3,
                decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                        0xFF000811):
                    Colors.white,
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(3)
                ),
                child: Column(
                  children: [
                    Text("Grade", style: Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(color: Colors.black45))),
                    Text(widget.course['grade'], style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(5),
                // width: DeviceUtils.getScreenSize(context).width*0.3,
                decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                        0xFF000811):
                    Colors.white,
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(3)
                ),
                child: Column(
                  children: [
                    Text("Credits", style: Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(color: Colors.black45))),
                    Text(widget.course['credits'], style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(5),
                // width: DeviceUtils.getScreenSize(context).width*0.3,
                decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                        0xFF000811):
                    Colors.white,
                    border: Border.all(
                      color: Colors.black12,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(3)
                ),
                child: Column(
                  children: [
                    Text("Code", style: Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(color: Colors.black45))),
                    Text(widget.course['code'], style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),

              SizedBox(
                height: 30,
                width: 105,
                child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _isOpen =  !_isOpen;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // no elevation
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(_isOpen? 'Hide Details':'View Details', style: const TextStyle(fontSize: 12),),
                        Icon(_isOpen? CupertinoIcons.arrow_up_circle :CupertinoIcons.arrow_down_circle, size: 18,)
                      ],
                    )
                ),
              )
            ],
          ),

          Visibility(visible: _isOpen, child: const SizedBox(height: 5,)),

          Visibility(
            visible: _isOpen,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: DeviceUtils.getScreenSize(context).width,
                decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                        0xFF000811):
                    Colors.white,
                ),
                child: Column(
                  children: [

                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                              0xFF000811):
                          Colors.white,
                          border: Border.all(color: Colors.black12, width: 1),
                          borderRadius: BorderRadius.circular(3)
                      ),
                      child: Row(children: [
                        Expanded(child: Text("Coordinator Name", style: Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(color: Colors.black45)))),
                        Expanded(child: Text(widget.course['coordinator'], style: Theme.of(context).textTheme.bodySmall)),
                      ],),
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                              0xFF000811):
                          Colors.white,
                          border: Border.all(color: Colors.black12, width: 1),
                          borderRadius: BorderRadius.circular(3)
                      ),
                      child: Row(children: [
                        Expanded(child: Text("Reg Type", style: Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(color: Colors.black45)))),
                        Expanded(child: Text(widget.course['regType'], style: Theme.of(context).textTheme.bodySmall)),
                      ],),
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Provider.of<ThemeProvider>(context).isDark ? const Color(
                              0xFF000811):
                          Colors.white,
                          border: Border.all(color: Colors.black12, width: 1),
                          borderRadius: BorderRadius.circular(3)
                      ),
                      child: Row(children: [
                        Expanded(child: Text("Elective Type", style: Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(color: Colors.black45)))),
                        Expanded(child: Text(widget.course['electiveType'], style: Theme.of(context).textTheme.bodySmall)),
                      ],),
                    ),


                  ],
                )
            ),
          ),

        ],
      ),
    );
  }
}


class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );
    _animation2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _animation3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1, curve: Curves.easeOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _animation1,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 5),
        FadeTransition(
          opacity: _animation2,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 5),
        FadeTransition(
          opacity: _animation3,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}