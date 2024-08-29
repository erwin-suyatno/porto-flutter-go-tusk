import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_color.dart';

class AppButton {
  static Widget primary(String title, VoidCallback? onClick) {
    return DButtonFlat(
      onClick: onClick,
      height: 46,
      mainColor: AppColor.primary,
      radius: 12,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),
        )
      );
  }
}