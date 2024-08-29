import 'package:flutter/material.dart';

class DetailTaskPage extends StatefulWidget {
  const DetailTaskPage({super.key, required this.id});
  final int id;

  @override
  State<DetailTaskPage> createState() => _DetailTaskPageState();
}

class _DetailTaskPageState extends State<DetailTaskPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}