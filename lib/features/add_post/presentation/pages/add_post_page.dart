import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pic_board/features/add_post/presentation/pages/caption_page.dart';

import '../../../../core/snackbar/custom_snackbar.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<AssetEntity> mediaList = [];
  AssetEntity? selectedMedia;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );

    if (albums.isEmpty) return;
    final recent = albums.first;
    final media = await recent.getAssetListPaged(page: 0, size: 200);

    setState(() {
      mediaList = media;
      if (media.isNotEmpty) selectedMedia = media.first;
    });
  }

  Widget _buildPreview() {
    if (selectedMedia == null) {
      return Container(
        height: 300.h,
        color: Colors.black12,
        child: const Center(child: Text("No media selected")),
      );
    }

    // Request a reasonably large thumbnail for preview
    return FutureBuilder<Uint8List?>(
      future: selectedMedia!.thumbnailDataWithSize(const ThumbnailSize(1080, 1080)),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(snapshot.data!, fit: BoxFit.cover),
                if (selectedMedia!.type == AssetType.video)
                  const Center(
                    child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70),
                  ),
              ],
            ),
          );
        }
        return Container(
          height: 300.h,
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (_, index) {
        final media = mediaList[index];
        return GestureDetector(
          onTap: () => setState(() => selectedMedia = media),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [
          TextButton(
            onPressed: _goToCaptionPage,
            child: const Text("Next", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPreview(),
            _buildGalleryGrid(),
          ],
        ),
      ),
    );
  }
}
