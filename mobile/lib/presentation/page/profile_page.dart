import 'package:d_info/d_info.dart';
import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mobile/common/app_color.dart';
import 'package:mobile/common/app_routing.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/presentation/bloc/user/user_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          appBar(),
          buildHeader(),
          const Gap(20),
          buildItemMenu(Icons.edit, 'Edit Profile', () {}),
          buildItemMenu(Icons.settings, 'Settings', () {}),
          buildItemMenu(Icons.feedback, 'FeedBack', () {}),
          buildItemMenu(Icons.password, 'Update Password', () {}),
          buildItemMenu(Icons.logout, 'Logout', () {
            DInfo.dialogConfirmation(
              context, 
              "Logout", 
              "Yes to confirm")
            .then((yes) {
              if(yes??false) {
                DSession.removeUser();
                context.read<UserCubit>().update(User());
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  AppRouting.login, 
                  (route) => route.settings.name == AppRouting.home,
                );
              }
            });
          }),
          const Gap(20),
        ],
      ),
    );
  }

  Widget buildItemMenu(IconData icon, String title, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon, 
                color: AppColor.primary
                ),
            ),
            const Gap(20),
      
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColor.textTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColor.primary),
          ],
        ),
      ),
    );
  }
  Widget buildHeader() {
    return Stack(
      children: [
        Container(
          height: 140,
          color: AppColor.primary,
          margin: const EdgeInsets.only(bottom: 60),
        ),
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<UserCubit, User>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      state.name??'',
                      style: const TextStyle(
                          color: AppColor.textTitle,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                    ),
                    Text(
                      state.email??'',
                      style: const TextStyle(
                          color: AppColor.textBody,
                          fontSize: 14,
                          fontWeight: FontWeight.w300
                        ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black38,
                  offset: Offset(0, 4),
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(120),
              child: Image.asset(
                'assets/profile.png', 
                height: 120, 
                width: 120, 
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Profile'),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BackButton(
              color: Colors.white,
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Colors.white))
          ],
        ),
      ),
    );
  }
}
