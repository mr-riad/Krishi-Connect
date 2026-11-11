import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class FarmerCommunityScreen extends StatefulWidget {
  const FarmerCommunityScreen({super.key});

  @override
  State<FarmerCommunityScreen> createState() => _FarmerCommunityScreenState();
}

class _FarmerCommunityScreenState extends State<FarmerCommunityScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  int _selectedTab = 0;
  final List<String> _tabs = ['সব', 'প্রশ্ন', 'অভিজ্ঞতা'];

  final List<Map<String, dynamic>> _posts = [
    {
      'farmer': 'মো: আলম',
      'upazila': 'তানোর',
      'text': 'এই মৌসুমে ধানে বাদামি গাছ ফড়িং দেখা যাচ্ছে। কেউ কি ভালো সমাধান জানেন?',
      'likes': 12,
      'comments': 5,
      'type': 'প্রশ্ন',
      'time': '২ ঘণ্টা আগে',
      'liked': false,
    },
    {
      'farmer': 'রহিমা বেগম',
      'upazila': 'গোদাগাড়ী',
      'text': 'গত বছর শীতকালীন সবজি চাষে ভালো ফলন পেয়েছিলাম। মিশ্র চাষ পদ্ধতিতে খরচ কমিয়েছি।',
      'likes': 34,
      'comments': 8,
      'type': 'অভিজ্ঞতা',
      'time': '৫ ঘণ্টা আগে',
      'liked': true,
    },
    {
      'farmer': 'করিম মিয়া',
      'upazila': 'পবা',
      'text': 'আলুতে লেট ব্লাইট রোগ হলে কোন কীটনাশক দিতে হবে? কতটুকু দিতে হবে?',
      'likes': 7,
      'comments': 12,
      'type': 'প্রশ্ন',
      'time': '১ দিন আগে',
      'liked': false,
    },
    {
      'farmer': 'জামাল উদ্দিন',
      'upazila': 'মোহনপুর',
      'text': 'ড্রিপ সেচ পদ্ধতিতে টমেটো চাষ করে এবার দ্বিগুণ ফলন পেয়েছি। পানির অপচয়ও অনেক কমেছে।',
      'likes': 58,
      'comments': 15,
      'type': 'অভিজ্ঞতা',
      'time': '২ দিন আগে',
      'liked': false,
    },
    {
      'farmer': 'নাসিমা খাতুন',
      'upazila': 'বাগমারা',
      'text': 'সার দেওয়ার সঠিক সময় কোনটা? বোরো মৌসুমে সেচ কতটুকু দিতে হবে?',
      'likes': 9,
      'comments': 4,
      'type': 'প্রশ্ন',
      'time': '৩ দিন আগে',
      'liked': false,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 0) return _posts;
    return _posts.where((p) => p['type'] == _tabs[_selectedTab]).toList();
  }

  bool _showForm = false;
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
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
                separatorBuilder: (context, index) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedTab == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedTab = index),
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
                        _tabs[index],
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

            // New Post Form (if shown)
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _postController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'আপনার প্রশ্ন বা অভিজ্ঞতা লিখুন...',
                        hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _showForm = false);
                        _postController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('পোস্ট প্রকাশিত হয়েছে!'),
                            backgroundColor: primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text('প্রকাশ করুন', style: TextStyle(fontSize: 13.sp)),
                    ),
                  ],
                ),
              ),

            // Posts
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _filtered.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final post = _filtered[index];
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
                              child: Icon(Icons.person_rounded, color: primaryGreen, size: 18.sp),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        post['farmer'],
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '· ${post['upazila']}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    post['time'],
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: post['type'] == 'প্রশ্ন'
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                post['type'],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: post['type'] == 'প্রশ্ন'
                                      ? const Color(0xFFD97706)
                                      : primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          post['text'],
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
                              onTap: () {
                                setState(() {
                                  post['liked'] = !(post['liked'] as bool);
                                  if (post['liked'] as bool) {
                                    post['likes'] = (post['likes'] as int) + 1;
                                  } else {
                                    post['likes'] = (post['likes'] as int) - 1;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    post['liked'] as bool
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 18.sp,
                                    color: post['liked'] as bool
                                        ? Colors.red
                                        : const Color(0xFF9CA3AF),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${post['likes']} পছন্দ',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Icon(Icons.comment_outlined, size: 18.sp, color: const Color(0xFF9CA3AF)),
                            SizedBox(width: 4.w),
                            Text(
                              '${post['comments']} মতবা',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
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
}
