library;

/// Models for Module 3: Community Forum (forum.py router)

// ═══════════════════════════════════════════════════════════
// FORUM POST
// ═══════════════════════════════════════════════════════════

class ForumPost {
  final String id;
  final String postType; // question | experience
  final String text;
  final String authorId;
  final String? authorName;
  final String? authorUpazila;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final List<String> mediaUrls;
  final bool isDeleted;
  final String createdAt;

  const ForumPost({
    required this.id,
    required this.postType,
    required this.text,
    required this.authorId,
    this.authorName,
    this.authorUpazila,
    required this.likes,
    required this.likedBy,
    required this.commentCount,
    required this.mediaUrls,
    required this.isDeleted,
    required this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as String? ?? '',
      postType: json['post_type'] as String? ?? 'question',
      text: json['text'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String?,
      authorUpazila: json['author_upazila'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      likedBy: (json['liked_by'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      mediaUrls: (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  /// Post type label in Bengali
  String get postTypeBn => postType == 'question' ? 'প্রশ্ন' : 'অভিজ্ঞতা';

  /// Relative time string from ISO date
  String get relativeTime {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${_toBnNumber(diff.inMinutes)} মিনিট আগে';
      if (diff.inHours < 24) return '${_toBnNumber(diff.inHours)} ঘণ্টা আগে';
      if (diff.inDays < 30) return '${_toBnNumber(diff.inDays)} দিন আগে';
      return createdAt.split('T').first;
    } catch (_) {
      return createdAt.split('T').first;
    }
  }

  static String _toBnNumber(int num) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String s = num.toString();
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(en[i], bn[i]);
    }
    return s;
  }

  /// Whether the given userId has liked this post
  bool isLikedBy(String userId) => likedBy.contains(userId);

  /// Returns a copy with toggled like for a given userId
  ForumPost withToggledLike(String userId) {
    final alreadyLiked = likedBy.contains(userId);
    final newLikedBy = List<String>.from(likedBy);
    if (alreadyLiked) {
      newLikedBy.remove(userId);
    } else {
      newLikedBy.add(userId);
    }
    return ForumPost(
      id: id,
      postType: postType,
      text: text,
      authorId: authorId,
      authorName: authorName,
      authorUpazila: authorUpazila,
      likes: alreadyLiked ? likes - 1 : likes + 1,
      likedBy: newLikedBy,
      commentCount: commentCount,
      mediaUrls: mediaUrls,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FORUM COMMENT
// ═══════════════════════════════════════════════════════════

class ForumComment {
  final String id;
  final String postId;
  final String authorId;
  final String? authorName;
  final String text;
  final bool isDeleted;
  final String createdAt;

  const ForumComment({
    required this.id,
    required this.postId,
    required this.authorId,
    this.authorName,
    required this.text,
    required this.isDeleted,
    required this.createdAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String?,
      text: json['text'] as String? ?? '',
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  String get relativeTime {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}মি আগে';
      if (diff.inHours < 24) return '${diff.inHours}ঘ আগে';
      return '${diff.inDays}দ আগে';
    } catch (_) {
      return '';
    }
  }
}
