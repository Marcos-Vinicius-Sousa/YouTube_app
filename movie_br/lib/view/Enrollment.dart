import 'package:flutter/material.dart';

class Enrollment extends StatefulWidget {
  const Enrollment({Key? key}) : super(key: key);

  @override
  State<Enrollment> createState() => _EnrollmentState();
}

class _EnrollmentState extends State<Enrollment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          "Inscrição",
          style: TextStyle(
              fontSize: 25
          ),
        ),
      ),
    );
  }
}
