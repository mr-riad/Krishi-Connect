import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_constants.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/di.dart';
import '../../models/forum_models.dart';
import '../../services/api_service.dart';

class FarmerCommunityScreen extends StatefulWidget {
  const FarmerCommunityScreen({super.key});

  @override
  State<FarmerCommunityScreen> createState() => _FarmerCommunityScreenState();
}

class _FarmerCommunityScreenState extends State<FarmerCommunityScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _api = KrishiApiService.instance;

  /// Tabs: (Bengali label, API post_type value or null for 'all')
  static const List<(String, String?)> _tabs = [
    ('সব', null),
    ('প্রশ্ন', 'question'),
    ('অভিজ্ঞতা', 'experience'),
  ];

  int _selectedTab = 0;
  List<ForumPost> _posts = [];
  bool _loading = false;
  String? _error;
  bool _posting = false;
  bool _showForm = false;
  String _selectedPostType = 'question';
  final TextEditingController _postController = TextEditingController();

  String get _currentUserId =>
      appData.read(kKeyUserID)?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final postType = _tabs[_selectedTab].$2;
      final res = await _api.getForumPosts(postType: postType, limit: 50);
      final posts = res
          .map((e) => ForumPost.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _posts = posts;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'পোস্ট লোড করতে সমস্যা হয়েছে।\n$e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    // Optimistic update
    setState(() {
      _posts[index] = post.withToggledLike(_currentUserId);
    });
    try {
      await _api.toggleForumLike(post.id);
      // Refresh the post from server for accurate count
      final res = await _api.getForumPost(post.id);
      final updated = ForumPost.fromJson(res);
      if (mounted) {
        setState(() {
          _posts[index] = updated;
        });
      }
    } catch (_) {
      // Roll back on error
      if (mounted) {
        setState(() {
          _posts[index] = post;
        });
      }
    }
  }

  Future<void> _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      await _api.createForumPost({
        'text': text,
        'post_type': _selectedPostType,
      });
      _postController.clear();
      setState(() {
        _showForm = false;
        _posting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('পোস্ট প্রকাশিত হয়েছে!'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      await _loadPosts();
    } catch (e) {
      if (mounted) {
        setState(() => _posting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('পোস্ট করতে সমস্যা হয়েছে: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showComments(ForumPost post) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => _CommentsSheet(post: post, api: _api),
    );
  }

  Future<void> _reportPost(ForumPost post) async {
    final reasons = ['স্প্যাম', 'অসৌজন্যমূলক', 'মিথ্যা তথ্য', 'অন্যান্য'];
    String? chosen;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('পোস্ট রিপোর্ট করুন'),
        content: StatefulBuilder(
          builder: (ctx2, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((r) {
              return RadioListTile<String>(
                value: r,
                groupValue: chosen,
                title: Text(r),
                onChanged: (v) => setLocal(() => chosen = v),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: chosen == null
                ? null
                : () async {
                    Navigator.pop(ctx);
                    try {
                      await _api.reportForumPost(post.id, chosen!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('রিপোর্ট পাঠানো হয়েছে।')),
                        );
                      }
                    } catch (_) {}
                  },
            child: const Text(
              'রিপোর্ট করুন',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Padding(
              padding: EdgeInsets.only(right: 16.w, top: 12.h),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'F-12 · কৃষক',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryGreen,
                    ),
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'কৃষক কমিউনিটি',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedTab == index;
                  return InkWell(
                    onTap: () {
                      if (_selectedTab != index) {
                        setState(() => _selectedTab = index);
                        _loadPosts();
                      }
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? primaryGreen : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        _tabs[index].$1,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),

            // New Post Form
            if (_showForm)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: primaryGreen.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post type toggle
                    Row(
                      children: [
                        Text(
                          'পোস্টের ধরন:',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        _typeChip('প্রশ্ন', 'question'),
                        SizedBox(width: 8.w),
                        _typeChip('অভিজ্ঞতা', 'experience'),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _postController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'আপনার প্রশ্ন বা অভিজ্ঞতা লিখুন...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _posting ? null : _submitPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: _posting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'প্রকাশ করুন',
                                style: TextStyle(fontSize: 13.sp),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

            // Posts
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showForm = !_showForm),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        icon: Icon(_showForm ? Icons.close : Icons.edit_rounded),
        label: Text(
          'নতুন পোস্ট',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value) {
    final selected = _selectedPostType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPostType = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected ? primaryGreen : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey),
              SizedBox(height: 12.h),
              Text(
                'পোস্ট লোড করা যায়নি',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: _loadPosts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 52.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'কোনো পোস্ট নেই। প্রথম পোস্ট করুন!',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: primaryGreen,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _posts.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final post = _posts[index];
          final isLiked = post.isLikedBy(_currentUserId);
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: const Color(0xFFF0FDF4),
                      child: Icon(
                        Icons.person_rounded,
                        color: primaryGreen,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post.authorName ?? 'কৃষক',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              if (post.authorUpazila != null) ...[
                                SizedBox(width: 6.w),
                                Text(
                                  '· ${post.authorUpazila}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            post.relativeTime,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Post type badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: post.postType == 'question'
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        post.postTypeBn,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: post.postType == 'question'
                              ? const Color(0xFFD97706)
                              : primaryGreen,
                        ),
                      ),
                    ),
                    // Report button
                    IconButton(
                      onPressed: () => _reportPost(post),
                      icon: Icon(
                        Icons.flag_outlined,
                        size: 16.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  post.text,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(index),
                      child: Row(
                        children: [
                          Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18.sp,
                            color: isLiked ? Colors.red : const Color(0xFF9CA3AF),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${post.likes} পছন্দ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.w),
                    GestureDetector(
                      onTap: () => _showComments(post),
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 18.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${post.commentCount} মন্তব্য',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Comments Bottom Sheet ─────────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final ForumPost post;
  final KrishiApiService api;

  const _CommentsSheet({required this.post, required this.api});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  static const Color primaryGreen = AppColors.primaryGreen;

  List<ForumComment> _comments = [];
  bool _loading = true;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.getForumComments(widget.post.id);
      final comments = res
          .map((e) => ForumComment.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _comments = comments;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await widget.api.addForumComment(widget.post.id, text);
      _commentCtrl.clear();
      await _loadComments();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মন্তব্য করতে সমস্যা হয়েছে।')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'মন্তব্য',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            const Divider(),
            // Comments
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? Center(
                          child: Text(
                            'এখনো কোনো মন্তব্য নেই',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          itemCount: _comments.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, i) {
                            final c = _comments[i];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14.r,
                                  backgroundColor: const Color(0xFFF0FDF4),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: primaryGreen,
                                    size: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            c.authorName ?? 'কৃষক',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            c.relativeTime,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        c.text,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
            // Comment Input
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: InputDecoration(
                        hintText: 'মন্তব্য লিখুন...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: _submitting ? null : _addComment,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: _submitting
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
