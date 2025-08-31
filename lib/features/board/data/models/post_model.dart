import 'package:flutter/foundation.dart';
import 'package:pic_board/features/board/domain/entities/post.dart';

class PostModel extends Post {
  PostModel({required super.title, required super.caption, required super.image_url, required super.like_count});
  
}