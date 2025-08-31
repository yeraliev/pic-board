import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/core/navigation_bar/navigation_bar.dart';
import 'package:pic_board/core/theme/theme_provider.dart';
import 'package:pic_board/core/widgets/loading_dialog.dart';
import 'package:pic_board/features/auth/presentation/pages/sign_up_page.dart';
import 'package:pic_board/features/auth/presentation/pages/verification.dart';
import 'package:pic_board/features/board/presentation/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Provider.of<ThemeProvider>(context).themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (LoadingDialog().dialogVisible) {
                LoadingDialog.hide(context);
              }
              if(snapshot.hasError) {
                return Scaffold(
                  body: SafeArea(child: Center(child: Text('Something went wrong!'),))
                );
              }
              if (snapshot.connectionState ==ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator(),),
                );
              } else {
                if (snapshot.hasData) {
                  if (snapshot.data!.emailVerified == true) {
                    return CustomBar();
                  }
                  return EmailVerificationPage();
                } else {
                  return SignUpPage();
                }
              }
            }
          ),
        );
      }
    );
  }
}
