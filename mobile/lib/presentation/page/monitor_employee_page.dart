import 'package:flutter/material.dart';
import 'package:mobile/data/models/user.dart';

class MonitorEmployeePage extends StatefulWidget {
  const MonitorEmployeePage({super.key, required this.employee});

  final User employee;
  
  @override
  State<MonitorEmployeePage> createState() => _MonitorEmployeePageState();
}

class _MonitorEmployeePageState extends State<MonitorEmployeePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}