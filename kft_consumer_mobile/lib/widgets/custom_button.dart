import 'package:flutter/material.dart';
import 'package:kft_consumer_mobile/lib.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double? width;
  final double? height;
  final Widget? child;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 7.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child ??
            Text(
              text!,
              style: TextStyle(color: textColor),
            ),
      ),
    );
  }
}
