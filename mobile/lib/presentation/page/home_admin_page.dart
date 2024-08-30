import 'package:d_button/d_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_info.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:mobile/common/enums.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/source/user_source.dart';
import 'package:mobile/presentation/bloc/employee/employee_bloc.dart';
import 'package:mobile/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:mobile/presentation/bloc/user/user_cubit.dart';
import 'package:mobile/presentation/widgets/failed_ui.dart';
import 'package:d_info/d_info.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  getNeedReview() {
    context.read<NeedReviewBloc>().add(OnFetchNeedReview());
  }

  getEmployee() {
    context.read<EmployeeBloc>().add(OnFetchEmployee());
  }
  
  deleteEmployee(User employee) {
    DInfo.dialogConfirmation(
      context, 
      'Delete', 
      "Yes to confirm").then((bool?yes) {
        if(yes??false) {
          UserSource.delete(employee.id!).then((success) {
            if(success) {
              AppInfo.success(context, 'Delete employee success');
              getEmployee();
            } else {
              AppInfo.failed(context, 'Delete employee failed');
            }
          });
        }
      });
  }
  refresh() {
    getNeedReview();
    getEmployee();
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
                child: buildButtonAddEmployee(),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => refresh(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Gap(20), 
                  buildNeedReview(),
                  const Gap(20), 
                  buildEmployee(),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget buildEmployee() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Employee',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, fontSize: 18)),
      BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is EmployeeFailed) {
            return const FailedUi(
              margin: EdgeInsets.only(top: 20),
              message: 'Something went wrong',
            );
          }
          if (state is EmployeeLoad) {
            List<User> employees = state.employees;
            if (employees.isEmpty) {
              return const FailedUi(
                margin: EdgeInsets.only(top: 20),
                icon: Icons.list, 
                message: 'No need to be reviewed',
              );
            }
            return ListView.builder(
              itemCount: employees.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              itemBuilder: (context, index) {
                User employee = employees[index];
                return buildItemEmployee(employee);
              },
            );
          }
          return const SizedBox.shrink();
        },
      )
    ]);
  }
  
  Widget buildItemEmployee(User employee) {
    return Container(
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
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/profile.png',
              width: 50,
              height: 50,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  employee.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, 
                      fontSize: 20,
                      color: AppColor.textTitle),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'Monitor') {
                Navigator.pushNamed(
                  context, 
                  AppRouting.monitorEmployee, 
                  arguments: employee).then((value) => refresh());
              }
              if (value == 'Delete') {
                deleteEmployee(employee);
              }
            },
            itemBuilder: (context) => [
            'Monitor',
            'Delete',
          ].map((e) {
            return PopupMenuItem(value: e, child: Text(e));
          }).toList())
        ],
      ),
    );
  }

  Widget buildNeedReview() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Need to be Reviewed',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, fontSize: 18)),
      BlocBuilder<NeedReviewBloc, NeedReviewState>(
        builder: (context, state) {
          if (state.requestStatus == RequestStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.requestStatus == RequestStatus.failed) {
            return const FailedUi(
              margin: EdgeInsets.only(top: 20),
              message: 'Something went wrong',
            );
          }
          if (state.requestStatus == RequestStatus.success) {
            List<Task> tasks = state.tasks;
            if (tasks.isEmpty) {
              return const FailedUi(
                margin: EdgeInsets.only(top: 20),
                icon: Icons.list, 
                message: 'No need to be reviewed',
              );
            }
            return Column(
              children: List.generate(tasks.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: buildItemNeedReview(tasks[index]),
                );
              }),
            );
          }
          return const SizedBox.shrink();
        },
      )
    ]);
  }

  Widget buildItemNeedReview(Task task) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouting.detailTask, arguments: task.id),
      child: Container(
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
        padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                'assets/profile.png',
                width: 50,
                height: 50,
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    task.user?.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: AppColor.textTitle,),
                  ),
                  const Gap(20),
                  Text(
                    DateFormat('dd MMM yyyy').format(task.dueDate ?? DateTime.now(),),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColor.textBody,),
                  ),
                ],
              ),
            ),
            const Icon(Icons.navigate_next)
          ],
        ),
      ),
    );
  }

  Widget buildButtonAddEmployee() {
    return DButtonElevation(
        onClick: () {
          Navigator.pushNamed(context, AppRouting.addEmployee).then(
            (value) {
              refresh();
            },
          );
        },
        height: 40,
        radius: 12,
        elevation: 4,
        mainColor: Colors.white,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
            ),
            Gap(4),
            Text('Add new Employee'),
          ],
        ));
  }

  Widget buildHeader() {
    return Container(
      alignment: Alignment.topCenter,
      height: 150,
      color: AppColor.primary,
      margin: EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRouting.profile).then(
                (value) {
                  // refresh data
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
          Gap(10),
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
