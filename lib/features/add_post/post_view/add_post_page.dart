import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pic_board/features/add_post/post_viewmodel/add_post_viewmodel.dart';
import 'package:pic_board/features/add_post/presentation/pages/caption_page.dart';
import 'package:provider/provider.dart';

import '../../../../core/snackbar/custom_snackbar.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<AssetEntity> mediaList = [];
  AssetEntity? selectedMedia;

  Widget _buildPreview() {
    if (selectedMedia == null) {
      return Container(
        height: 300.h,
        color: Colors.black12,
        child: const Center(child: Text("No media selected")),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: selectedMedia!.thumbnailDataWithSize(const ThumbnailSize(500, 500)),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,   // was cover
                    gaplessPlayback: true, // helps with refresh
                  ),
                  if (selectedMedia!.type == AssetType.video)
                    const Center(
                      child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70),
                    ),
                ],
              ),
            );
          }
        }
        return Container(
          height: 300,
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: mediaList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (_, index) {
        final media = mediaList[index];
        return GestureDetector(
          onTap: () {
            if (!mounted) return;
            context.read<AddPostViewModel>().setSelectedMedia(media);
          },
          child: FutureBuilder<Uint8List?>(
            future: media.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              return Container(color: Colors.grey[300]);
            },
          ),
        );
      },
    );
  }

  void _goToCaptionPage() async {
    if (selectedMedia != null) {
      final file = await selectedMedia!.file;
      if (file != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostCaptionPage(image: File(file.path))));
      }
    }else {
      CustomSnackBar().showSnackBar(
        context,
        text: 'Choose the picture at first!',
        type: 'error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddPostViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _goToCaptionPage,
            child: const Text("Next", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          if(viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if(viewModel.mediaList != []){
            mediaList = viewModel.mediaList;
            selectedMedia = context.watch<AddPostViewModel>().selectedMedia;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildPreview(),
                _buildGalleryGrid(),
              ],
            ),
          );
        }
      ),
    );
  }
}
