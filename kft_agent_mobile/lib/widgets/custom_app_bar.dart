import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

PreferredSizeWidget getAppBar(
    {required IconData? iconData, required String? title}) {
  return AppBar(
    leading: const SizedBox(),
    backgroundColor: Colors.white,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    title: IntrinsicWidth(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title ?? '',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff555555),
            ),
          ),
          const SizedBox(width: 10),
          if (iconData != null)
            Icon(
              iconData,
              size: 19.sp,
              color: const Color(0xff999999),
            ),
        ],
      ),
    ),
    centerTitle: true,
  );
}
