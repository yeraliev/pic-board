import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/features/auth/data/services/auth_service.dart';
import 'package:pic_board/features/auth/domain/use_cases/validator_auth.dart';
import 'package:pic_board/features/auth/presentation/pages/sign_in_page.dart';
import 'package:pic_board/features/auth/presentation/pages/verification.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_text_field.dart';

import '../../../../core/snackbar/custom_snackbar.dart';
import '../../../../core/widgets/loading_dialog.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signUp() async {
    try {
      LoadingDialog.show(context);
      final userCredential = await AuthService().signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );
      LoadingDialog.hide(context);

      User? user = userCredential.user;

      if(user!=null) {
        await user.updateDisplayName(nameController.text.trim());
        await user.reload();
        print(user.displayName);
        print(userCredential);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => EmailVerificationPage()));
    } on FirebaseAuthException catch (e) {
      LoadingDialog.hide(context);
      final errorMessages = {
        'email-already-in-use': 'This email is already registered.',
        'invalid-email': 'Invalid email address.',
        'operation-not-allowed': 'Email/password accounts are not enabled.',
        'weak-password': 'Password is too weak. Please use a stronger one.',
      };

      final errorMessage = errorMessages[e.code] ?? 'Sign up failed: ${e.code}';
      CustomSnackBar().showSnackBar(context, text: errorMessage, type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to PicBoard!",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 3.h,),
                    Text(
                      "Here you can sign up by entering your name, email and password.",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSecondaryFixed
                      ),
                    ),
                    SizedBox(height: 30.h,),
                    AuthTextField(controller: nameController, hintText: 'Name', validator: (value) {return ValidatorAuth().validateName(value);}),
                    SizedBox(height: 16.h,),
                    AuthTextField(controller: emailController, hintText: 'Email', validator: (value) {return ValidatorAuth().validateEmail(value);}),
                    SizedBox(height: 16.h,),
                    AuthTextField(controller: passwordController, hintText: 'Password', isPassword: true, validator: (value) {return ValidatorAuth().validatePassword(value);}),
                    SizedBox(height: 24.h,),
                    AuthButton(title: 'Sign up', onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signUp();
                        } else {
                          CustomSnackBar().showSnackBar(context, text: 'Write required credentials!', type: 'error');
                        }
                        print('sign up');
                      },
                    ),
                    SizedBox(height: 4.h,),
                    Center(
                      child: Wrap(
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
                            },
                            child: Text(
                              "Sign in.",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700
                              ),
                            )
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
