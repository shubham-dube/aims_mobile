import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Center(
        child: Text('Coming Soon', style: Theme.of(context).textTheme.headlineLarge,),
      ),
    );
  }
}
