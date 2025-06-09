import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/core/snackbar/custom_snackbar.dart';
import 'package:pic_board/core/widgets/loading_dialog.dart';
import 'package:pic_board/features/auth/presentation/pages/sign_up_page.dart';
import 'package:pic_board/features/board/presentation/pages/home_page.dart';
import 'package:pic_board/main.dart';

import '../../data/services/auth_service.dart';
import '../../domain/use_cases/validator_auth.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      LoadingDialog.show(context);
      final userCredential = await AuthService().signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );
      LoadingDialog.hide(context);

      if (AuthService().currentUser != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      }
    } on FirebaseAuthException catch (e) {
      LoadingDialog.hide(context);
      print(e.code);
      final errorMessages = {
        'invalid-email': 'Invalid email format.',
        'wrong-password': 'Wrong password. Try again.',
        'user-not-found': 'No user found for that email.',
        'user-disabled': 'This user account is disabled.',
        'too-many-requests': 'Too many attempts. Try again later.',
        'invalid-credential': 'Invalid credentials. Try signing in again.',
      };

      final message = errorMessages[e.code] ?? 'An error occurred: ${e.code}';
      CustomSnackBar().showSnackBar(context, text: message, type: 'error');
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
                      "Welcome back to PicBoard!",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 3.h,),
                    Text(
                      "Here you can sign in by entering your email and password.",
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSecondaryFixed
                      ),
                    ),
                    SizedBox(height: 30.h,),
                    AuthTextField(controller: emailController, hintText: 'Email', validator: (value) {return ValidatorAuth().validateEmail(value);}),
                    SizedBox(height: 16.h,),
                    AuthTextField(controller: passwordController, hintText: 'Password', isPassword: true, validator: (value) {return ValidatorAuth().validatePassword(value);}),
                    SizedBox(height: 24.h,),
                    AuthButton(title: 'Sign in', onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await signIn();
                      } else {
                        CustomSnackBar().showSnackBar(context, text: 'Write required credentials!', type: 'error');
                      }
                      print('sign in');
                    }),
                    SizedBox(height: 4.h,),
                    Center(
                      child: Wrap(
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                              },
                              child: Text(
                                "Sign up.",
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
