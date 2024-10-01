import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:mobile/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:mobile/presentation/bloc/user/user_cubit.dart';
import 'package:mobile/presentation/widgets/failed_ui.dart';

class HomeEmployeePage extends StatefulWidget {
  const HomeEmployeePage({super.key});
  
  @override
  State<HomeEmployeePage> createState() => _HomeEmployeePageState();
}

class _HomeEmployeePageState extends State<HomeEmployeePage> {

  late User user;
  refresh() {
    user = context.read<UserCubit>().state;
    context.read<StatEmployeeCubit>().fetchStatistic(user.id!);
    context
      .read<ProgressTaskBloc>()
      .add(OnFetchProgressTasks(user.id!));
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
          Stack(
            children: [
              buildHeader(),
              Positioned(
                right: 50,
                left: 50,
                bottom: 0,
                child: buildSearchTask(),
              ),
            ]
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => refresh(),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const Gap(16),
                  buildTaskMenu(),
                  const Gap(16),
                  buildProgressTask(),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressTask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Task', 
          style: TextStyle(
            color: AppColor.textTitle, 
            fontSize: 20, 
            fontWeight: FontWeight.bold)),
        const Gap(12),
        BlocBuilder<ProgressTaskBloc, ProgressTaskState>(
          builder: (context, state) {
            if (state is ProgressTaskLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is ProgressTaskFailed) {
              return FailedUi(
                message: state.message,
              );
            }
            if (state is ProgressTaskLoaded) {
              List<Task>? tasks = state.tasks;
              if (tasks.isEmpty) {
                return const FailedUi(
                  icon: Icons.list,
                  message: 'There is no progress',
                );
              }
              return ListView.builder(
                itemCount: tasks.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  Task task = tasks[index];
                  return buildItemProgressTask(task);
                },
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget buildItemProgressTask(Task task) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouting.detailTask, arguments: task.id),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 0, right: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 8,
              decoration: const BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    task.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, 
                        fontSize: 20,
                        color: AppColor.textTitle),
                  ),
                  Text(
                    dateByStatus(task),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat( 
                        fontSize: 12,
                        color: AppColor.textBody),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                iconByStatus(task),
                width: 28,
                height: 28,
              ),
            )
          ],
        )
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
                buildItemTaskMenu('assets/queue_bg.png', 'Queue', state['Queue']),
                buildItemTaskMenu('assets/review_bg.png', 'Review', state['Review']),
                buildItemTaskMenu('assets/approved_bg.png', 'Approved', state['Approved']),
                buildItemTaskMenu('assets/rejected_bg.png', 'Rejected', state['Rejected']),
              ],
              );
          },
        )
      ],
    );
  }

  Widget buildItemTaskMenu(String asset, String title, int total) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRouting.listTask,
          arguments: {
            'status': title,
            'employee': user,
          } 
        ).then((value) =>
          refresh()
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(asset), 
            fit: BoxFit.cover,
          )
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
            const Gap(8),
            Text(
              '$total tasks', 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchTask() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColor.textTitle),
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Task...',
                hintStyle: TextStyle(color: AppColor.textTitle),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      alignment: Alignment.topCenter,
      height: 150,
      color: AppColor.primary,
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRouting.profile).then(
                (value) {
                  refresh();
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                'assets/profile.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<UserCubit, User>(
                  builder: (context, state) {
                    return Text(
                      'Hello, ${state.name ?? ''}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary),
                DateFormat('d MMM yyyy').format(DateTime.now())),
          )
        ],
      ),
    );
  }
}