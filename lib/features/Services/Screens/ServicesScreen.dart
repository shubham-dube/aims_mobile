import 'package:flutter/material.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Center(
        child: Text('Coming Soon', style: Theme.of(context).textTheme.headlineLarge,),
      ),
    );
  }
}
