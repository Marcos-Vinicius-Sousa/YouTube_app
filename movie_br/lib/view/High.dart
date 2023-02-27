import 'package:flutter/material.dart';

class High extends StatefulWidget {
  const High({Key? key}) : super(key: key);

  @override
  State<High> createState() => _HighState();
}

class _HighState extends State<High> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          "Em Alta",
          style: TextStyle(
              fontSize: 25
          ),
        ),
      ),
    );
  }
}
