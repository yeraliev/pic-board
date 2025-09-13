import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/core/snackbar/custom_snackbar.dart';
import 'package:pic_board/features/auth/data/services/auth_service.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';
import 'package:pic_board/main.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _timer;
  bool _canResend = true;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    try {
      _sendVerificationEmail();
      _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified) {
          _timer?.cancel();
          if (!mounted) return;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MyApp()));
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        _timer?.cancel();
        if (!mounted) return;
        CustomSnackBar().showSnackBar(context, text: 'Your account has been disabled.', type: 'error');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _canResend && !user.emailVerified) {
        await user.sendEmailVerification();
        if (!mounted) return;
        setState(() {
          _canResend = false;
          _secondsRemaining = 60;
        });

        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            if (_secondsRemaining > 0) {
              _secondsRemaining--;
            } else {
              _canResend = true;
              timer.cancel();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You can resend the email now!'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          });
        });
      }
    } catch (e) {
      print("Error sending verification email: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService().currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We sent an email verification link to $userEmail',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5.h),
            if (_secondsRemaining != 0) Text('Resend in $_secondsRemaining, wait...'),
            SizedBox(height: 25.h),
            AuthButton(
              title: _canResend ? 'Resend' : 'Wait...',
              onPressed: _canResend ? _sendVerificationEmail : () {},
            ),
          ],
        ),
      ),
    );
  }
}
