import 'package:flutter/material.dart';
import 'package:mobile/data/models/user.dart';

class ListTaskPage extends StatefulWidget {
  const ListTaskPage({super.key, required this.status, required this.employee});
  final String status;
  final User employee;

  @override
  State<ListTaskPage> createState() => _ListTaskPageState();
}

class _ListTaskPageState extends State<ListTaskPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}