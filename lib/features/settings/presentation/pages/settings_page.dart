import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';
import 'package:pic_board/features/settings/presentation/pages/change_password.dart';
import 'package:pic_board/features/settings/presentation/pages/edit_name.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../main.dart';
import '../../../auth/data/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Future<void> signOut() async {
    try {
      LoadingDialog.show(context);

      await AuthService().signOut();

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
      }
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          "Settings",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h,),
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                "Edit account",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _buildSettingsSection(title: 'Edit name', icon: Icons.drive_file_rename_outline_sharp, iconColor: Colors.blue ,onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditName()));
            }),
            _buildDivider(),
            _buildSettingsSection(title: 'Change password', icon: Icons.lock_sharp, iconColor: Colors.red ,onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));
            }),
            _buildDivider(),
            _buildSettingsSection(title: 'Change avatar', icon: Icons.image, iconColor: Colors.green ,onTap: () {}),
            Divider(color: Colors.grey.shade300, thickness: 0.3,),
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                "App theme",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _buildSettingsSection(title: 'Dark Mode', icon: Icons.dark_mode_rounded, iconColor: Colors.blue, trailing: _buildDarkModeSwitch()),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: AuthButton(title: 'Sign out', onPressed: signOut)
        )
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return Switch.adaptive(
        activeColor: Theme.of(context).colorScheme.primary,
        value: Provider.of<ThemeProvider>(context).themeMode==darkMode,
        onChanged: (value) {
          Provider.of<ThemeProvider>(context, listen: false).changeToDarkMode();
        }
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback?  onTap,
    required Color iconColor
  }) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(15.r)
          ),
          padding: EdgeInsets.all(8.w),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.w,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
        child: Divider(color: Colors.grey.shade300, thickness: 0.2, height: 0,)
    );
  }
}
