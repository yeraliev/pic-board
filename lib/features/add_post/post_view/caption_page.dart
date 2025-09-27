import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pic_board/core/widgets/loading_dialog.dart';
import 'package:pic_board/features/auth/data/services/auth_service.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';
import '../../../core/snackbar/custom_snackbar.dart';

class PostCaptionPage extends StatefulWidget {
  File image;
  PostCaptionPage({super.key, required this.image});

  @override
  State<PostCaptionPage> createState() => _CaptionPageState();
}

class _CaptionPageState extends State<PostCaptionPage> {
  TextEditingController captionController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

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

  Future<void> _posting(String photoURL) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception("Not logged in");
      }


      final caption = captionController.text.trim();

      final docData = {
        "userId": user.uid,
        "imageUrl": photoURL,
        "caption": caption,
        "likes": 0,
        "likedBy": [],
        "timestamp": DateTime.now(),
      };

      final docRef = await _firestore.collection("posts").add(docData);

    } catch (e, stackTrace) {
      if (mounted) {
        CustomSnackBar().showSnackBar(
          context,
          text: 'Failed to upload post!',
          type: 'error',
        );
      }
      rethrow;
    }
  }

  Future<void> _uploadImageToFirebase(File image) async {
    LoadingDialog.show(context);
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception("Not logged in");

      final compressedImage = await _compressImage(image);

      String imageDownloadUrl = "";
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("posts/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await ref.putFile(compressedImage);
      imageDownloadUrl = await ref.getDownloadURL();
      await _posting(imageDownloadUrl);

      await compressedImage.delete();

      CustomSnackBar().showSnackBar(
        context,
        text: 'Your image posted!',
        type: 'success',
      );
      Navigator.pop(context);
    } catch (e) {
      log(e.toString());
      CustomSnackBar().showSnackBar(
        context,
        text: 'Failed to upload post!',
        type: 'error',
      );
    } finally {
      LoadingDialog.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: const Text('New Post'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          children: [
            Image.file(
              widget.image,
              fit: BoxFit.cover,
              height: 300.w,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h,),
                  TextField(
                    controller: captionController,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                    decoration: InputDecoration(
                      hintText: 'Caption',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600
                      ),
                      icon: Icon(
                        Icons.closed_caption_off,
                        size: 30.r,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              )
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 20.h),
              child: AuthButton(title: 'Post', onPressed: () => _uploadImageToFirebase(widget.image)),
            )
          ],
        ),
      ),
    );
  }
}
