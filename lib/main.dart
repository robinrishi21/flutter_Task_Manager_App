import 'package:flutter/material.dart';
import 'package:task_manager_app/screens/HomePage.dart';

void main() {
  runApp(const Todo(
  ));
}

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
