import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/features/auth/domain/use_cases/validator_auth.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_text_field.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          "Change password",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Write your old and new password.",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.onSurface
                ),
              ),
              SizedBox(height: 10.h,),
              AuthTextField(
                controller: currentPasswordController,
                hintText: 'Current password',
                validator: (value) {
                  return ValidatorAuth().validatePassword(value);
                },
                isPassword: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
