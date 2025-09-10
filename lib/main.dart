import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/core/navigation_bar/navigation_bar.dart';
import 'package:pic_board/core/theme/theme_provider.dart';
import 'package:pic_board/core/widgets/loading_dialog.dart';
import 'package:pic_board/features/auth/presentation/pages/sign_up_page.dart';
import 'package:pic_board/features/auth/presentation/pages/verification.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme.dart';
import 'features/auth/data/providers/user_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Provider.of<ThemeProvider>(context).themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (LoadingDialog().dialogVisible) {
                LoadingDialog.hide(context);
              }

              if (snapshot.hasError) {
                return const Scaffold(
                  body: SafeArea(
                    child: Center(child: Text('Something went wrong!')),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  if (snapshot.data!.emailVerified) {
                    return const CustomBar();
                  }
                  return const EmailVerificationPage();
                } else {
                  return const SignUpPage();
                }
              }

              // fallback
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
      },
    );
  }
}
