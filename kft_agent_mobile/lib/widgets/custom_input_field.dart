import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomInputField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final TextInputAction? textInputAction;

  const CustomInputField({
    super.key,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
    this.onChanged,
    this.leadingIcon,
    this.trailingIcon,
    this.textInputAction,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      shadowColor: Colors.black12.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: TextFormField(
        controller: widget.controller,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        obscureText: _obscureText,
        validator: widget.validator,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          labelStyle: const TextStyle(color: Colors.black26),
          prefixIcon: widget.leadingIcon != null
              ? Icon(
                  widget.leadingIcon,
                  color: Colors.black26,
                  size: 20.sp,
                )
              : null,
          suffixIcon: widget.trailingIcon != null
              ? Icon(
                  widget.trailingIcon,
                  color: Colors.grey,
                  size: 20.sp,
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1.h),
          ),
        ),
      ),
    );
  }
}
