import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final List<Map<String, dynamic>> _myPosts = [
    {
      'crop': 'বোরো ধান',
      'quantity': '৫০০ কেজি',
      'price': '৩৮',
      'location': 'বাগমারা, রাজশাহী',
      'date': '১০ অক্টোবর',
      'status': 'সক্রিয়',
      'views': '১২',
      'calls': '৩',
    },
    {
      'crop': 'গোল আলু',
      'quantity': '২০০ কেজি',
      'price': '৩০',
      'location': 'বাগমারা, রাজশাহী',
      'date': '০৫ অক্টোবর',
      'status': 'সক্রিয়',
      'views': '৮',
      'calls': '১',
    },
    {
      'crop': 'পাকা টমেটো',
      'quantity': '১৫০ কেজি',
      'price': '৪৫',
      'location': 'বাগমারা, রাজশাহী',
      'date': '০১ অক্টোবর',
      'status': 'মেয়াদ শেষ',
      'views': '২৫',
      'calls': '৭',
    },
  ];

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'পোস্ট মুছবেন?',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'আপনি কি "${_myPosts[index]['crop']}" পোস্টটি মুছে ফেলতে চান?',
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('না', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _myPosts.removeAt(index));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('মুছুন', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
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
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'আমার পোস্ট',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'আপনার প্রকাশিত ফসল বিক্রির তালিকা',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),

            // Summary Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _buildStatCard('মোট পোস্ট', '${_myPosts.length}', Icons.article_outlined),
                  SizedBox(width: 12.w),
                  _buildStatCard(
                    'সক্রিয়',
                    '${_myPosts.where((p) => p['status'] == 'সক্রিয়').length}',
                    Icons.check_circle_outline_rounded,
                  ),
                  SizedBox(width: 12.w),
                  _buildStatCard(
                    'মোট কল',
                    _myPosts.fold(0, (sum, p) => sum + int.parse(p['calls'].toString().replaceAll('৳', ''))).toString(),
                    Icons.phone_in_talk_rounded,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Posts List
            Expanded(
              child: _myPosts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article_outlined, size: 60.sp, color: const Color(0xFFD1D5DB)),
                          SizedBox(height: 12.h),
                          Text(
                            'কোনো পোস্ট নেই',
                            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _myPosts.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final post = _myPosts[index];
                        final isActive = post['status'] == 'সক্রিয়';
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        post['crop'],
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFFDCFCE7)
                                              : const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          post['status'],
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                            color: isActive ? primaryGreen : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () => _confirmDelete(index),
                                    icon: Icon(Icons.delete_outline_rounded,
                                        color: Colors.red.shade400, size: 22.sp),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${post['quantity']} · ৳${post['price']}/কেজি · ${post['location']}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF4B5563),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Icon(Icons.visibility_outlined,
                                      size: 14.sp, color: const Color(0xFF9CA3AF)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${post['views']} ভিউ',
                                    style: TextStyle(
                                        fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                                  ),
                                  SizedBox(width: 14.w),
                                  Icon(Icons.phone_in_talk_rounded,
                                      size: 14.sp, color: const Color(0xFF9CA3AF)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${post['calls']} কল',
                                    style: TextStyle(
                                        fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                                  ),
                                  const Spacer(),
                                  Text(
                                    post['date'],
                                    style: TextStyle(
                                        fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18.sp, color: primaryGreen),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
