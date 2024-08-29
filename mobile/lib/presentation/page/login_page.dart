import 'package:d_input/d_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_info.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:mobile/common/enums.dart';
import 'package:mobile/presentation/bloc/login/login_cubit.dart';
import 'package:mobile/presentation/bloc/user/user_cubit.dart';
import 'package:mobile/presentation/widgets/app_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final edtEmail = TextEditingController();
    final edtPassword = TextEditingController();
    return Scaffold(
      body: ListView(padding: const EdgeInsets.all(0), children: [
        buildHeader(),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            DInput(
              controller: edtEmail,
              fillColor: Colors.white,
              radius: BorderRadius.circular(20),
              hint: 'Email',
            ),
            const SizedBox(
              height: 20,
            ),
            DInputPassword(
              controller: edtPassword,
              fillColor: Colors.white,
              radius: BorderRadius.circular(20),
              hint: 'Password',
            ),
            const SizedBox(
              height: 20,
            ),
            BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state.requestStatus == RequestStatus.failed) {
                  AppInfo.failed(context, 'Login Failed');
                }
                if (state.requestStatus == RequestStatus.success) {
                  AppInfo.success(context, 'Login Success');
                  Navigator.pushNamed(context, AppRouting.home);
                }
              },
              builder: (context, state) {
                if (state.requestStatus == RequestStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return AppButton.primary('Sign In', () {
                  context.read<LoginCubit>().clickLogin(edtEmail.text, edtPassword.text);
                });
              },
            ),
          ]),
        )
      ]),
    );
  }

  AspectRatio buildHeader() {
    return AspectRatio(
      aspectRatio: 0.9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            bottom: 100,
            child: Image.asset(
              'assets/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
              top: 200,
              bottom: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ])),
              )),
          Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  RichText(
                      text: TextSpan(
                    text: 'Monitoring\n',
                    style: TextStyle(
                      color: AppColor.defaultText,
                      fontSize: 30,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'With ',
                      ),
                      TextSpan(
                        text: 'Tusk ',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ))
                ],
              ))
        ],
      ),
    );
  }
}
