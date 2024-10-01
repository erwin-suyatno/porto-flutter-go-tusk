import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/presentation/bloc/employee/employee_bloc.dart';
import 'package:mobile/presentation/bloc/list_task/list_task_bloc.dart';
import 'package:mobile/presentation/bloc/login/login_cubit.dart';
import 'package:mobile/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:mobile/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:mobile/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:mobile/presentation/bloc/user/user_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:d_session/d_session.dart';
import 'package:mobile/presentation/page/add_employee_page.dart';
import 'package:mobile/presentation/page/add_task_page.dart';
import 'package:mobile/presentation/page/detail_task_page.dart';
import 'package:mobile/presentation/page/home_admin_page.dart';
import 'package:mobile/presentation/page/home_employee_page.dart';
import 'package:mobile/presentation/page/list_task_page.dart';
import 'package:mobile/presentation/page/login_page.dart';
import 'package:mobile/presentation/page/monitor_employee_page.dart';
import 'package:mobile/presentation/page/profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((onValue){
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      
      providers: [
        BlocProvider(create: (context) => UserCubit(),),
        BlocProvider(create: (context) => LoginCubit(),),
        BlocProvider(create: (context) => NeedReviewBloc(),),
        BlocProvider(create: (context) => EmployeeBloc(),),
        BlocProvider(create: (context) => StatEmployeeCubit(),),
        BlocProvider(create: (context) => ProgressTaskBloc(),),
      ], 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true).copyWith(
          primaryColor: AppColor.primary,
          colorScheme: const ColorScheme.light(
            primary: AppColor.primary,
            secondary: AppColor.secondary
          ),
          scaffoldBackgroundColor: AppColor.scaffold,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: const AppBarTheme(
            surfaceTintColor: AppColor.primary,
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )
          ),
          popupMenuTheme: const PopupMenuThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          dialogTheme: const DialogTheme(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white
          ),
        ),
        initialRoute: AppRouting.home,
        routes: {
          AppRouting.home: (context) {
            return FutureBuilder(
              future: DSession.getUser(), 
              builder: (context, snapshot) {
               if (snapshot.data == null) return const LoginPage(); //login
               User user = User.formJson(Map.from(snapshot.data!));
               context.read<UserCubit>().update(user);
               if (user.role == "Admin") return const HomeAdminPage(); //homeadmin
               return const HomeEmployeePage(); //home employee
              }
            );
          },
          AppRouting.addEmployee: (context) => const AddEmployeePage(), //add employee
          AppRouting.addTask: (context) {
            User employee = ModalRoute.of(context)!.settings.arguments as User;
            return AddTaskPage(employee: employee);
          }, //add task
          AppRouting.detailTask: (context) {
            int id = ModalRoute.of(context)!.settings.arguments as int;
            return DetailTaskPage(id: id);
          }, //detail task
          AppRouting.listTask: (context) {
            Map data = ModalRoute.of(context)!.settings.arguments as Map;
            return BlocProvider(
              create: (context) => ListTaskBloc(),
              child: ListTaskPage(status: data['status'], employee: data['employee']));
          }, //list task
          AppRouting.login: (context) => const LoginPage(), //login Page
          AppRouting.monitorEmployee: (context) {
            User employee = ModalRoute.of(context)!.settings.arguments as User;
            return MonitorEmployeePage(employee: employee);
          }, //monitor employee
          AppRouting.profile: (context) => const ProfilePage(), //profile
        },
        ),
      );
  }
    
}