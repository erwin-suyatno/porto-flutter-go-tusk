import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/presentation/bloc/list_task/list_task_bloc.dart';
import 'package:mobile/presentation/widgets/failed_ui.dart';

class ListTaskPage extends StatefulWidget {
  const ListTaskPage({super.key, required this.status, required this.employee});
  final String status;
  final User employee;

  @override
  State<ListTaskPage> createState() => _ListTaskPageState();
}

class _ListTaskPageState extends State<ListTaskPage> {

  refresh() {
    context.read<ListTaskBloc>().add(OnFetchListTask(widget.employee.id!, widget.status));
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          header(),
          Expanded(
            child: buildListTask(),
          )
        ],),
    );
  }

  Widget buildListTask() {
    return BlocBuilder<ListTaskBloc, ListTaskState>(
      builder: (BuildContext context, ListTaskState state) { 
        if (state is ListTaskLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ListTaskFailed) {
          return FailedUi(
            message: state.message,
          );
        }
        if (state is ListTaskLoaded) {
          List<Task> tasks = state.tasks;
          if (tasks.isEmpty) {
            return const FailedUi(
              message: 'There is no task',
              icon: Icons.list,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = tasks[index];
                return buildItemTask(task);
              },
            ),
          );
        }
        return const SizedBox.shrink();
       },
    );
  }

  Widget buildItemTask(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month, 
                color: AppColor.textBody, size: 20,
              ),
              const Gap(10),
              Text(
                DateFormat('d MMM').format(task.createdAt!), 
                style: const TextStyle(color: AppColor.textBody, fontSize: 12),
              ),
            ],
          )
          ,const Gap(12),
          Text(
            task.title??'', 
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColor.textTitle, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            task.description??'', 
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textBody, 
              fontSize: 12),
          ),
          const Gap(16),
          DButtonBorder(
            onClick: () {
              Navigator.pushNamed(context, AppRouting.detailTask, arguments: task.id);
            },
            mainColor: Colors.white70,
            radius: 16,
            borderColor: AppColor.scaffold, 
            child: const Text(
              'Open', 
              style: TextStyle(
                color: AppColor.textTitle,
                fontSize: 14,
                fontWeight: FontWeight.bold
                ),)),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(20, 50, 20, 4),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.status, 
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
                )
              ),
          ),
          Positioned(
            left: 8,
            bottom: 0,
            top: 0,
            child: UnconstrainedBox(
              child: DButtonFlat(
                width: 36,
                height: 36,
                radius: 12,
                mainColor: Colors.white,
                onClick: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColor.primary,
                )
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            top: 0,
            child: Chip(
              side: BorderSide.none,
              label: Text(
                widget.employee.name??'', 
                style: const TextStyle(
                  color: AppColor.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
                )
              )
            )
          ),
        ]),
    );
  }
}