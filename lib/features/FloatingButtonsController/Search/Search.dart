import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: (){},
        child: const Icon(CupertinoIcons.search),
      ),
    );
  }
}
