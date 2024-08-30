import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/data/models/user.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key, required this.employee});
  final User employee;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.primary,
        child: const Center(
          child: Text('Add Task Page'),
        ),
      ),
    );
  }
}