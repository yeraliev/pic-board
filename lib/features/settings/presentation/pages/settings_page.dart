import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pic_board/core/snackbar/custom_snackbar.dart';
import 'package:pic_board/features/auth/presentation/pages/sign_in_page.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';
import 'package:pic_board/features/settings/presentation/pages/change_password.dart';
import 'package:pic_board/features/settings/presentation/pages/edit_name.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation_bar/navigation_bar.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> signOut() async {
    try {
      LoadingDialog.show(context);

      await AuthService().signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
      }
      print(e.message);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);

      if (image != null) {
        LoadingDialog.show(context);
        await _uploadImageToFirebase(File(image.path));
        LoadingDialog.hide(context);
      } else {
        return;
      }
    } catch (e) {
      print(e.toString());
      LoadingDialog.hide(context);
      CustomSnackBar().showSnackBar(
        context,
        text: 'Failed to pick the image!',
        type: 'error',
      );
    }
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      String imageDownloadUrl = "";
      final compressedImage = await _compressImage(image);
      Reference ref = FirebaseStorage.instance.ref().child("avatars/${DateTime.now().millisecondsSinceEpoch}.png");
      await ref.putFile(compressedImage);
      imageDownloadUrl = await ref.getDownloadURL();
      await changeAvatar(imageDownloadUrl);
    } catch (e) {
      print(e.toString());
      CustomSnackBar().showSnackBar(
        context,
        text: 'Failed to change the avatar!',
        type: 'error',
      );
    }
  }

  Future<File> _compressImage(File image) async {
    final bytes = await image.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) throw Exception("Could not decode image");

    img.Image resized = originalImage;
    if (originalImage.width > 1024 || originalImage.height > 1024) {
      resized = img.copyResize(
        originalImage,
        width: originalImage.width > originalImage.height ? 1024 : null,
        height: originalImage.height > originalImage.width ? 1024 : null,
      );
    }

    final compressedBytes = img.encodeJpg(resized, quality: 70);

    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  Future<void> changeAvatar(String url) async {
    try {
      await AuthService().changeAvatar(avatarPath: url);
      Navigator.pop(context);
      CustomSnackBar().showSnackBar(
        context,
        text: 'Avatar changed successfully!',
        type: 'success',
      );
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
      CustomSnackBar().showSnackBar(
        context,
        text: 'Failed to change avatar, try again!',
        type: 'error',
      );
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                "Edit account",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _buildSettingsSection(
              title: 'Edit name',
              icon: Icons.drive_file_rename_outline_sharp,
              iconColor: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditName()),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsSection(
              title: 'Change password',
              icon: Icons.lock_sharp,
              iconColor: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePassword()),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsSection(
              title: 'Change avatar',
              icon: Icons.image,
              iconColor: Colors.green,
              onTap: () => _showImageSourcePicker(),
            ),
            Divider(color: Colors.grey.shade300, thickness: 0.3),
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                "App theme",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _buildSettingsSection(
              title: 'Dark Mode',
              icon: Icons.dark_mode_rounded,
              iconColor: Colors.blue,
              trailing: _buildDarkModeSwitch(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: AuthButton(title: 'Sign out', onPressed: signOut),
        ),
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return Switch.adaptive(
      activeColor: Theme.of(context).colorScheme.primary,
      value: Provider.of<ThemeProvider>(context).themeMode == darkMode,
      onChanged: (value) {
        Provider.of<ThemeProvider>(context, listen: false).changeToDarkMode();
      },
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, color: Colors.white, size: 20.w),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
      child: Divider(color: Colors.grey.shade300, thickness: 0.2, height: 0),
    );
  }

  Future<void> _showImageSourcePicker() async {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return CupertinoActionSheet(
            title: Text('Choose the source'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: Text('Gallery'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: Text('Camera'),
              ),
            ],
          );
        },
      );
    } else {
      return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          );
        },
      );
    }
  }
}
