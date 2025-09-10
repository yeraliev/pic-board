import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pic_board/features/auth/presentation/widgets/auth_button.dart';

import '../../../../core/snackbar/custom_snackbar.dart';

class PostCaptionPage extends StatefulWidget {
  File image;
  PostCaptionPage({super.key, required this.image});

  @override
  State<PostCaptionPage> createState() => _CaptionPageState();
}

class _CaptionPageState extends State<PostCaptionPage> {
  TextEditingController captionController = TextEditingController();
  String imageURL = "";

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      String imageDownloadUrl = "";
      Reference ref = FirebaseStorage.instance.ref().child("posts/${DateTime.now().millisecondsSinceEpoch}.png");
      await ref.putFile(image);
      imageDownloadUrl = await ref.getDownloadURL();
      setState(() {
        imageURL  = imageDownloadUrl;
      });
    } catch (e) {
      print(e.toString());
      CustomSnackBar().showSnackBar(
        context,
        text: 'Failed to change the avatar!',
        type: 'error',
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      fontWeight: FontWeight.w600
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
              child: AuthButton(title: 'Post', onPressed: () {}),
            )
          ],
        ),
      ),
    );
  }
}
