import 'package:flutter/material.dart';
import 'package:mobile/common/app_color.dart';

class AppInfo {
  static success(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.approved,
      ),
    );
  }

  static failed(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.rejected,
      ),
    );
  }
}