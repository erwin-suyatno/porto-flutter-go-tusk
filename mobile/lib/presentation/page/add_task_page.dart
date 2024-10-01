import 'package:d_button/d_button.dart';
import 'package:d_input/d_input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_info.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/source/task_source.dart';
import 'package:mobile/presentation/widgets/app_button.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key, required this.employee});
  final User employee;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final dueDate = DateTime.now().obs;
  final edtTitle = TextEditingController();
  final edtDescription = TextEditingController();

  addNewTask() {
    TaskSource.addTask(edtTitle.text, edtDescription.text, dueDate.string, widget.employee.id!).then((value) {
      var (success, message) = value;
      if(success) {
        AppInfo.success(context, message);
      } else {
        AppInfo.failed(context, message);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, 
        title: const Text("Add new Task"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DInput(
            controller: edtTitle, 
            title: 'Title',
            hint: 'Title', 
            fillColor: Colors.white,
            radius: BorderRadius.circular(20),
          ),
          const Gap(20),
          DInput(
            controller: edtDescription, 
            title: 'Description',
            hint: 'Description', 
            fillColor: Colors.white,
            minLine: 5,
            maxLine: 5,
            radius: BorderRadius.circular(20),
          ),
          const Gap(16),
          Row(
            children: [
              DButtonBorder(
                onClick: () async {
                  showDatePicker(
                    context: context, 
                    firstDate: DateTime.now(), 
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  ).then((pickedDate) {
                    if(pickedDate == null) return;
                    showTimePicker(
                      context: context, 
                      initialTime: TimeOfDay.now(),
                    ).then((pickedTime) {
                      if(pickedTime == null) return;
                      dueDate.value = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute
                      );
                    });
                  });
                },
                radius: 8,
                borderColor: AppColor.primary, 
                disableColor: Colors.white,
                child: Text('Due Date'),
              ),
              const Gap(20),
              Obx(() {
                return Text(
                  DateFormat('d MMM yyyy, H:mm').format(dueDate.value)
                );
              }),
            ],
          ),
          const Gap(20),
          AppButton.primary('Add', () {
            addNewTask();
          })
          
        ],
      )
    );
  }
}