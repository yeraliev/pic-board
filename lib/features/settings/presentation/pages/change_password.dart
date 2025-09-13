import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/core/snackbar/custom_snackbar.dart';
import 'package:pic_board/features/auth/data/services/auth_service.dart';
import 'package:pic_board/features/auth/domain/use_cases/validator_auth.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_text_field.dart';

import '../../../../core/navigation_bar/navigation_bar.dart';
import '../../../auth/presentation/widgets/auth_button.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

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
              Form(
                key: _formKey,
                child: Column(
                children: [
                  AuthTextField(
                    controller: currentPasswordController,
                    hintText: 'Current password',
                    validator: (value) {
                      return ValidatorAuth().validatePassword(value);
                    },
                    isPassword: true,
                  ),
                  SizedBox(height: 10.h,),
                  AuthTextField(
                    controller: newPasswordController,
                    hintText: 'New password',
                    validator: (value) {
                      return ValidatorAuth().validatePassword(value);
                    },
                    isPassword: true,
                  ),
                ],
              )),
              Spacer(),
              isLoading ? Center(child: CircularProgressIndicator())
                  : AuthButton(
                  title: 'Save',
                  onPressed: () async {
                    if (!mounted) return;
                    setState(() {
                      isLoading = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      try {
                        String oldPassword = currentPasswordController.text.trim();
                        String newPassword = newPasswordController.text.trim();
                        AuthService().changePassword(password: oldPassword, newPassword: newPassword);
                        await AuthService().currentUser!.reload();
                        CustomSnackBar().showSnackBar(context, text: 'Password was successfully changed!', type: 'success');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => CustomBar(destination: 2)),
                              (Route<dynamic> route) => false,
                        );
                      } catch (e) {
                        print(e.toString());
                        CustomSnackBar().showSnackBar(context, text: 'Failed to change password, try later!', type: 'error');
                        if (!mounted) return;
                        setState(() {
                          isLoading = false;
                        });
                      }
                      if (!mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
