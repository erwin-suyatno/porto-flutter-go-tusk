import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/presentation/bloc/stat_employee/stat_employee_cubit.dart';

class MonitorEmployeePage extends StatefulWidget {
  const MonitorEmployeePage({super.key, required this.employee});

  final User employee;
  
  @override
  State<MonitorEmployeePage> createState() => _MonitorEmployeePageState();
}

class _MonitorEmployeePageState extends State<MonitorEmployeePage> {
  refresh() {
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         Container(
           color: AppColor.primary,
           height: 140,
         ),
         RefreshIndicator(
          onRefresh: () async => refresh(),
           child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
             children: [
              const Gap(16),
              buildHeader(),
              const Gap(24),
              buildAddTaskButton(),
              const Gap(16),
              buildTaskMenu(),
             ]
            ),
         )
        ],
      ),
    );
  }

  Widget buildTaskMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tasks', 
          style: TextStyle(
            color: AppColor.textTitle, 
            fontSize: 20, 
            fontWeight: FontWeight.bold)),
        const Gap(12),
        BlocBuilder<StatEmployeeCubit, Map>(
          builder: (context, state) {
            return GridView.count(
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2, 
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                Image.asset(
                  'assets/queue_bg.png',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/review_bg.png',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/approved_bg.png',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/rejected_bg.png',
                  fit: BoxFit.cover,
                ),
              ],
              );
          },
        )
      ],
    );
  }

  Widget buildAddTaskButton() {
    return DButtonElevation(
      height: 50,
      elevation: 4,
      onClick: () {
        Navigator.pushNamed(
          context, 
          AppRouting.addTask, 
          arguments: widget.employee).then((value) => refresh());
      }, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add),
          const Gap(4),
          const Text('Add new task'),
        ],
      ),
      mainColor: Colors.white,
      radius: 12,
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-12, 0),
          child: const BackButton(color: Colors.white,)
        ),
        Text(
          widget.employee.name??'', 
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
        const Spacer(),
        DButtonFlat(
          onClick: () {}, 
          child: const Text('reset password'),
          mainColor: Colors.white,
          radius: 12,)
      ],);
  }
}