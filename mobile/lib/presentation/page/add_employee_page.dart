import 'package:d_input/d_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:mobile/common/app_info.dart';
import 'package:mobile/data/source/user_source.dart';
import 'package:mobile/presentation/widgets/app_button.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  @override
  Widget build(BuildContext context) {
    final edtName = TextEditingController();
    final edtEmail = TextEditingController();

    addNewEmployee() {
      UserSource.addEmployee(edtName.text, edtEmail.text).then((value) {
        var (success, message) = value;
        if(success) {
          AppInfo.success(context, message);
        } else {
          AppInfo.failed(context, message);
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("Add Employee"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DInput(
            controller: edtName, 
            hint: 'Name', 
            fillColor: Colors.white,
            radius: BorderRadius.circular(20)),
          const Gap(20),
          DInput(
            controller: edtEmail, 
            hint: 'Email', 
            fillColor: Colors.white,
            radius: BorderRadius.circular(20)),
          const Gap(20),
          AppButton.primary('Add', () {
            addNewEmployee();
          })
        ])
    );
  }
}