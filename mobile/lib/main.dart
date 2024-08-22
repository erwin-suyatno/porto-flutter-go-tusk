import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/presentation/bloc/user/user_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:d_session/d_session.dart';

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
        BlocProvider(create: (context) => UserCubit(),)
      ], 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true).copyWith(
          primaryColor: AppColor.primary,
          colorScheme: ColorScheme.light(
            primary: AppColor.primary,
            secondary: AppColor.secondary
          ),
          scaffoldBackgroundColor: AppColor.scaffold,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            surfaceTintColor: AppColor.primary,
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          dialogTheme: DialogTheme(
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
               if (snapshot.data == null) return const Scaffold(); //login
               User user = User.formJson(Map.from(snapshot.data!));
               context.read<UserCubit>().update(user);
               if (user.role == "Admin") return const Scaffold(); //homeadmin
               return const Scaffold(); //home employee
              }
            );
          },
          AppRouting.addEmployee: (context) => const Scaffold(), //add employee
          AppRouting.addTask: (context) => const Scaffold(), //add task
          AppRouting.detailTask: (context) => const Scaffold(), //detail task
          AppRouting.listTask: (context) => const Scaffold(), //list task
          AppRouting.login: (context) => const Scaffold(), //login Page
          AppRouting.monitorEmployee: (context) => const Scaffold(), //monitor employee
          AppRouting.profile: (context) => const Scaffold(), //profile
        },
        ),
      );
  }
    
}