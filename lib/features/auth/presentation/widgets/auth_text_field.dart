import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  const AuthTextField({super.key, required this.controller, required this.hintText, this.isPassword = false, required this.validator});

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _visiblePassword = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      obscureText: _visiblePassword,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface
        ),
        suffixIcon: widget.isPassword ? IconButton(onPressed: () {
          if (!mounted) return;
          setState(() {
            _visiblePassword = !_visiblePassword;
          });
        }, icon: Icon(
            _visiblePassword ? Icons.visibility_off : Icons.visibility,
            size: 20.w,
          )
        )
            : null,
      ),
    );
  }
}
