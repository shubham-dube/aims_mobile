import '../../../common/theme_provider.dart';
import '../Community/Screens/CommunityScreen.dart';
import '../ViewCourses/Screens/HomeScreen/HomeScreen.dart';
import '../Clubs/Screens/ClubsMain/ClubsMain.dart';
import '../Services/Screens/ServicesScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class BottomNavBarController extends StatefulWidget {
  const BottomNavBarController({super.key, required this.sessionId, required this.userName});
  final String sessionId;
  final String userName;

  @override
  State<BottomNavBarController> createState() => _BottomNavBarController();
}

class _BottomNavBarController extends State<BottomNavBarController> {
  int _currentIndex = 0;
  String baseUrl = "http://192.168.1.9:5001";

  @override
  void initState() {
    super.initState();
  }

  dynamic getScreen(index){
    switch(index){
      case 0: return HomeScreen(sessionId: widget.sessionId, userName: widget.userName,);
      case 1: return const LearningScreen();
      case 2: return const ServicesScreen();
      case 3: return const CommunityScreen();
      default: return HomeScreen(sessionId: widget.sessionId, userName: widget.userName,);
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),

      body: getScreen(_currentIndex),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Provider.of<ThemeProvider>(context).isDark ? const Color(0xFF000811):Colors.white,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: !Provider.of<ThemeProvider>(context).isDark ? const Color(0xFF000811):Colors.white,
        type: BottomNavigationBarType.fixed,

        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },

        items:const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            label: 'Clubs',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.group_solid),
          //   label: 'Classmates',
          // ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}