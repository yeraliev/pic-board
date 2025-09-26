import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AddPostViewModel extends ChangeNotifier {
  List<AssetEntity> _mediaList = [];
  AssetEntity? _selectedMedia;
  bool _isLoading = false;

  List<AssetEntity> get mediaList => _mediaList;
  AssetEntity? get selectedMedia => _selectedMedia;
  bool get isLoading => _isLoading;

  void setSelectedMedia(AssetEntity media) {
    _selectedMedia = media;
    notifyListeners();
  }

  Future<void> loadGallery() async {
    _isLoading = true;
    notifyListeners();
    try {
      final permitted = await PhotoManager.requestPermissionExtend();
      if (!permitted.isAuth) return;

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
      );

      if (albums.isEmpty) return;
      final recent = albums.first;
      final media = await recent.getAssetListPaged(page: 0, size: 200);


      _mediaList = media;
      if (media.isNotEmpty) _selectedMedia = media.first;
      notifyListeners();
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}